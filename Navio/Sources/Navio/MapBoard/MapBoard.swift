//
//  MapBoard.swift
//  Navio
//
//  Created by 김민우 on 9/8/25.
//
import Foundation
import Combine
import ToolBox
import CoreLocation
import GooglePlaces

@MainActor
public final class MapBoard: Sendable, ObservableObject {
    // core
    public init(owner: Navio.ID) {
        self.owner = owner
        self.editorialSummaryByName = [:]
        self.detailByName = [:]
        MapBoardManager.register(self)
    }
    internal func delete() { MapBoardManager.unregister(self.id) }

    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID

    @Published public private(set) var currentLocation: Location? = nil
    @Published public private(set) var isUpdatingLocation: Bool = false
    private func setLocation(_ newLocation: Location?) { self.currentLocation = newLocation }

    @Published public internal(set) var likePlaces: [LikePlace.ID] = []
    @Published public internal(set) var recentPlaces: [RecentPlace.ID] = []

    @Published public var searchInput: String = ""
    @Published public internal(set) var searchPlaces: [SearchPlace.ID] = []
    @Published public internal(set) var editorialSummaryByName: [String: String] = [:]

    // 상세 스냅샷(값 타입만)
    @Published public internal(set) var detailByName: [String: PlaceDetail] = [:]

    public struct PlaceDetail: Sendable, Hashable {
        public let placeID: String
        public let name: String
        public let lat: Double
        public let lon: Double
        public let address: String
        public let phone: String
        public let website: String?
        public let rating: Double
        public let priceLevelRaw: Int
        public let types: [String]
        public let weekdayText: [String]
        public let editorialSummary: String?
        public let isOpenNow: Bool?
    }

    // action
    public func updateLocation() async {
        await LocationManager.shared.getUserAuthentication()
        await LocationManager.shared.fetchMyLocation()
        let currentLocation = await LocationManager.shared.location
        self.currentLocation = currentLocation
    }

    public func startUpdating() async {
        guard self.isUpdatingLocation == false else { return }
        let navio = self.id
        await LocationManager.shared.addHandler { newLocation in
            Task { await navio.ref?.setLocation(newLocation) }
        }
        await LocationManager.shared.startStreaming()
        self.isUpdatingLocation = true
    }
    public func stopUpdating() async {
        await LocationManager.shared.stopStreaming()
    }

    public func fetchLikePlaces() async {
        // capture ------------------------------------------------------------
        let boardRef = self.id
        let oldIDs = self.likePlaces

        // compute ------------------------------------------------------------
        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard

        let box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        let orderedNames = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? box.keys.sorted()

        // mutate -------------------------------------------------------------
        for id in oldIDs {
            guard let name = id.ref?.name else { continue }
            if orderedNames.contains(name) == false {
                id.ref?.delete()
            }
        }
        self.likePlaces = []
        for name in orderedNames {
            guard let rec = box[name] else { continue }
            let address = rec["address"] ?? ""
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.likePlaces.append(exist)
                continue
            }
            let data = PlaceData(
                name: name,
                imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: address,
                number: ""
            )
            let likeRef = LikePlace(owner: boardRef, data: data)
            self.likePlaces.append(likeRef.id)
        }
    }

    /// 최근 검색어 목록 재구성(MRU → 메모리 모델)
    @MainActor
    public func fetchRecentPlaces() async {
        // capture ------------------------------------------------------------
        let boardRef = self.id
        let oldIDs = self.recentPlaces

        // compute ------------------------------------------------------------
        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        let ordered: [String] = ((ud.array(forKey: keyMRU) as? [String]) ?? [])
            .prefix(10)
            .map { $0 }

        // mutate -------------------------------------------------------------
        for id in oldIDs {
            guard let query = id.ref?.name else { continue }
            if ordered.contains(query) == false { id.ref?.delete() }
        }
        self.recentPlaces = []
        for query in ordered {
            if let exist = oldIDs.first(where: { $0.ref?.name == query }) {
                self.recentPlaces.append(exist)
                continue
            }
            let data = PlaceData(
                name: query,
                imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: "",
                number: ""
            )
            let rec = RecentPlace(owner: boardRef, data: data)
            self.recentPlaces.append(rec.id)
        }
    }

    /// 검색 실행: 자동완성 → placeID[] → 상세 스냅샷 → 목록/상세 캐시 갱신
    @MainActor
    public func fetchSearchPlaces() async {
        // capture ------------------------------------------------------------
        let boardRef = self.id
        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let client = GMSPlacesClient.shared()
        let token = GMSAutocompleteSessionToken()

        // compute ------------------------------------------------------------
        if rawQuery.isEmpty {
            self.searchPlaces = []
            return
        }

        let placeIDs: [String] = await withCheckedContinuation { (cont: CheckedContinuation<[String], Never>) in
            let filter = GMSAutocompleteFilter()
            filter.types = ["establishment"]
            filter.countries = ["KR"]
            client.findAutocompletePredictions(
                fromQuery: rawQuery, filter: filter, sessionToken: token
            ) { predictions, error in
                if let error = error {
                    print("autocomplete error:", error)
                    cont.resume(returning: [])
                    return
                }
                let ids = (predictions ?? []).prefix(10).compactMap { $0.placeID }
                cont.resume(returning: Array(ids))
            }
        }

        struct PlaceSnap {
            let placeID: String
            let name: String
            let lat: Double
            let lon: Double
            let address: String
            let phone: String
            let website: String?
            let rating: Double
            let priceLevelRaw: Int
            let types: [String]
            let weekdayText: [String]
            let summary: String?
            let isOpenNow: Bool?
        }

        func fetchPlaceSnap(_ placeID: String) async -> PlaceSnap? {
            let fields: GMSPlaceField = [
                .placeID, .name, .coordinate,
                .formattedAddress, .phoneNumber, .website,
                .openingHours, .currentOpeningHours, .secondaryOpeningHours,
                .utcOffsetMinutes, .businessStatus,
                .rating, .priceLevel, .types,
                .editorialSummary
            ]
            return await withCheckedContinuation { (cont: CheckedContinuation<PlaceSnap?, Never>) in
                client.fetchPlace(
                    fromPlaceID: placeID,
                    placeFields: fields,
                    sessionToken: token
                ) { place, error in
                    if let error = error {
                        print("fetchPlace error:", error)
                        cont.resume(returning: nil)
                        return
                    }
                    guard let p = place, let name = p.name else {
                        cont.resume(returning: nil)
                        return
                    }

                    // 영업 여부
                    let req = GMSPlaceIsOpenRequest(place: p, date: nil)
                    client.isOpen(with: req) { resp, _ in
                        var openNow: Bool?
                        switch resp.status {
                        case .open:    openNow = true
                        case .closed:  openNow = false
                        case .unknown: openNow = nil
                        @unknown default: openNow = nil
                        }
                        if p.businessStatus != .operational { openNow = false }

                        cont.resume(returning: .init(
                            placeID: p.placeID ?? "",
                            name: name,
                            lat: p.coordinate.latitude,
                            lon: p.coordinate.longitude,
                            address: p.formattedAddress ?? "",
                            phone: p.phoneNumber ?? "",
                            website: p.website?.absoluteString,
                            rating: Double(p.rating),
                            priceLevelRaw: p.priceLevel.rawValue,
                            types: p.types ?? [],
                            weekdayText: p.openingHours?.weekdayText ?? [],
                            summary: p.editorialSummary,
                            isOpenNow: openNow
                        ))
                    }
                }
            }
        }

        // 3) 스냅샷들을 수집하여 목록/상세 캐시 빌드
        var newDatas: [(name: String, data: PlaceData, summary: String?)] = []

        for placeID in placeIDs {
            guard let snap = await fetchPlaceSnap(placeID) else { continue }

            let placeData = PlaceData(
                name: snap.name,
                imageName: "",
                location: .init(latitude: snap.lat, longitude: snap.lon),
                address: snap.address,
                number: snap.phone
            )

            let detail = PlaceDetail(
                placeID: snap.placeID,
                name: snap.name,
                lat: snap.lat, lon: snap.lon,
                address: snap.address,
                phone: snap.phone,
                website: snap.website,
                rating: snap.rating,
                priceLevelRaw: snap.priceLevelRaw,
                types: snap.types,
                weekdayText: snap.weekdayText,
                editorialSummary: snap.summary,
                isOpenNow: snap.isOpenNow
            )
            self.detailByName[snap.name] = detail
            self.editorialSummaryByName[snap.name] = snap.summary ?? ""
            newDatas.append((snap.name, placeData, snap.summary))
        }

        // 4) MRU 업데이트
        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        var mru = (ud.array(forKey: keyMRU) as? [String]) ?? []
        mru.removeAll { $0 == rawQuery }
        mru.insert(rawQuery, at: 0)
        if mru.count > 10 { mru = Array(mru.prefix(10)) }

        // mutate -------------------------------------------------------------
        let newNames = Set(newDatas.map { $0.name })
        for id in oldIDs {
            guard let name = id.ref?.name else { continue }
            if newNames.contains(name) == false { id.ref?.delete() }
        }

        self.searchPlaces = []
        for (name, placeData, summary) in newDatas {
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.searchPlaces.append(exist)
            } else {
                let sp = SearchPlace(owner: boardRef, data: placeData)
                self.searchPlaces.append(sp.id)
            }
            if let summary = summary {
                self.editorialSummaryByName[name] = summary
            }
        }

        ud.set(mru, forKey: keyMRU)
    }
    
    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        public var isExist: Bool { MapBoardManager.container[self] != nil }
        public var ref: MapBoard? { MapBoardManager.container[self] }
    }
}

@MainActor
fileprivate final class MapBoardManager: Sendable {
    static var container: [MapBoard.ID: MapBoard] = [:]
    static func register(_ object: MapBoard) { container[object.id] = object }
    static func unregister(_ id: MapBoard.ID) { container[id] = nil }
}

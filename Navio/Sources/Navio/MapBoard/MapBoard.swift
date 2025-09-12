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
    public func stopUpdating() async { await LocationManager.shared.stopStreaming() }

    public func fetchLikePlaces() async {
        let boardRef = self.id
        let oldIDs = self.likePlaces

        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard

        let box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        let orderedNames = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? box.keys.sorted()

        for id in oldIDs {
            guard let nm = id.ref?.name else { continue }
            if orderedNames.contains(nm) == false { id.ref?.delete() }
        }
        self.likePlaces = []

        for name in orderedNames {
            guard let rec = box[name] else { continue }
            let imageName = rec["imageName"] ?? ""
            let address = rec["address"] ?? ""

            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.likePlaces.append(exist); continue
            }
            let data = PlaceData(
                name: name, imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: address, number: ""
            )
            let likeRef = LikePlace(owner: boardRef, data: data)
            self.likePlaces.append(likeRef.id)
        }
    }

    @MainActor
    public func fetchRecentPlaces() async {
        let boardRef = self.id
        let oldIDs = self.recentPlaces

        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        let ordered: [String] = ((ud.array(forKey: keyMRU) as? [String]) ?? []).prefix(20).map { $0 }

        for id in oldIDs {
            guard let q = id.ref?.name else { continue }
            if ordered.contains(q) == false { id.ref?.delete() }
        }

        self.recentPlaces = []
        for q in ordered {
            if let exist = oldIDs.first(where: { $0.ref?.name == q }) {
                self.recentPlaces.append(exist); continue
            }
            let data = PlaceData(
                name: q, imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: "", number: ""
            )
            let rec = RecentPlace(owner: boardRef, data: data)
            self.recentPlaces.append(rec.id)
        }
    }

    @MainActor
    public func fetchSearchPlaces() async {
        let boardRef = self.id
        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let client = GMSPlacesClient.shared()
        let token = GMSAutocompleteSessionToken()

        if rawQuery.isEmpty {
            self.searchPlaces = []
            return
        }

        let placeIDs: [String] = await withCheckedContinuation { (cont: CheckedContinuation<[String], Never>) in
            let filter = GMSAutocompleteFilter()
            filter.types = ["establishment"]
            filter.countries = ["KR"]
            client.findAutocompletePredictions(fromQuery: rawQuery, filter: filter, sessionToken: token) { preds, error in
                if let error = error { print("autocomplete error:", error); cont.resume(returning: []); return }
                let ids = (preds ?? []).prefix(10).compactMap { $0.placeID }
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
        }

        func fetchPlaceSnap(_ placeID: String) async -> PlaceSnap? {
            let fields: GMSPlaceField = [
                .placeID, .name, .coordinate,
                .formattedAddress, .phoneNumber, .website,
                .openingHours, .rating, .priceLevel, .types,
                .editorialSummary
            ]
            return await withCheckedContinuation { (cont: CheckedContinuation<PlaceSnap?, Never>) in
                client.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { place, error in
                    if let error = error { print("fetchPlace error:", error); cont.resume(returning: nil); return }
                    guard let p = place, let nm = p.name else { cont.resume(returning: nil); return }
                    cont.resume(returning: .init(
                        placeID: p.placeID ?? "",
                        name: nm,
                        lat: p.coordinate.latitude,
                        lon: p.coordinate.longitude,
                        address: p.formattedAddress ?? "",
                        phone: p.phoneNumber ?? "",
                        website: p.website?.absoluteString,
                        rating: Double(p.rating),
                        priceLevelRaw: p.priceLevel.rawValue,
                        types: p.types ?? [],
                        weekdayText: p.openingHours?.weekdayText ?? [],
                        summary: p.editorialSummary
                    ))
                }
            }
        }

        var newDatas: [(name: String, data: PlaceData, summary: String?)] = []

        for pid in placeIDs {
            guard let s = await fetchPlaceSnap(pid) else { continue }

            // 목록용 최소 모델
            let pdata = PlaceData(
                name: s.name,
                imageName: "",
                location: .init(latitude: s.lat, longitude: s.lon),
                address: s.address,
                number: s.phone
            )

            // 상세 스냅샷 저장
            let detail = PlaceDetail(
                placeID: s.placeID,
                name: s.name,
                lat: s.lat, lon: s.lon,
                address: s.address,
                phone: s.phone,
                website: s.website,
                rating: s.rating,
                priceLevelRaw: s.priceLevelRaw,
                types: s.types,
                weekdayText: s.weekdayText,
                editorialSummary: s.summary
            )
            self.detailByName[s.name] = detail

            self.editorialSummaryByName[s.name] = s.summary ?? ""
            newDatas.append((s.name, pdata, s.summary))
        }

        // MRU
        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        var mru = (ud.array(forKey: keyMRU) as? [String]) ?? []
        mru.removeAll { $0 == rawQuery }
        mru.insert(rawQuery, at: 0)
        if mru.count > 20 { mru = Array(mru.prefix(20)) }

        // mutate
        let newNames = Set(newDatas.map { $0.name })
        for id in oldIDs {
            guard let nm = id.ref?.name else { continue }
            if newNames.contains(nm) == false { id.ref?.delete() }
        }

        self.searchPlaces = []
        for (name, pdata, summary) in newDatas {
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.searchPlaces.append(exist)
            } else {
                let sp = SearchPlace(owner: boardRef, data: pdata)
                self.searchPlaces.append(sp.id)
            }
            if let s = summary { self.editorialSummaryByName[name] = s }
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

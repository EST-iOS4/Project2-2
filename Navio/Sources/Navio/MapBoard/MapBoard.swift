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


// MARK: Object
@MainActor
public final class MapBoard: Sendable, ObservableObject {
    // core
    public init(owner: Navio.ID) {
        self.owner = owner
        self.editorialSummaryByName = [:]
        MapBoardManager.register(self)
    }
    internal func delete() {
        MapBoardManager.unregister(self.id)
    }
    
    
    // state
    public nonisolated let id = ID()
    internal nonisolated let owner: Navio.ID
    
    @Published public private(set) var currentLocation: Location? = nil
    @Published public private(set) var isUpdatingLocation: Bool = false
    private func setLocation(_ newLocation: Location?) {
        self.currentLocation = newLocation
    }
    
    @Published public internal(set) var likePlaces: [LikePlace.ID] = []
    @Published public internal(set) var recentPlaces: [RecentPlace.ID] = []
    
    @Published public var searchInput: String = ""
    @Published public internal(set) var searchPlaces: [SearchPlace.ID] = []
    @Published public internal(set) var editorialSummaryByName: [String: String] = [:]
    
    // action
    public func updateLocation() async {
        // capture
        
        
        // compute
        await LocationManager.shared.getUserAuthentication()
        
        await LocationManager.shared.fetchMyLocation()
        
        let currentLocation = await LocationManager.shared.location
        
        
        // mutate
        self.currentLocation = currentLocation
    }
    
    public func startUpdating() async {
        // capture
        guard self.isUpdatingLocation == false else {
            print("위치가 현재 업데이트 중입니다.")
            return
        }
        let navio = self.id
        
        // compute
        await LocationManager.shared.addHandler { newLocation in
            Task {
                await navio.ref?.setLocation(newLocation)
            }
        }
        
        await LocationManager.shared.startStreaming()
        
        // mutate
        self.isUpdatingLocation = true
    }
    public func stopUpdating() async {
        // compute
        await LocationManager.shared.stopStreaming()
    }
    
    public func fetchLikePlaces() async {
        // capture
        let boardRef = self.id
        let oldIDs = self.likePlaces
        
        // compute
        let userDefaultBoxKey = "LIKED_PLACES"
        let userDefaultIDsKey = "MAPBOARD_LIKEPLACE_IDS"
        let ud = UserDefaults.standard
        
        let box = (ud.dictionary(forKey: userDefaultBoxKey) as? [String: [String: String]]) ?? [:]
        let orderedNames = (ud.array(forKey: userDefaultIDsKey) as? [String]) ?? box.keys.sorted()
        
        // mutate
        for id in oldIDs {
            guard let nm = id.ref?.name else { continue }
            if orderedNames.contains(nm) == false {
                id.ref?.delete()
            }
        }
        
        self.likePlaces = []
        
        for name in orderedNames {
            guard let rec = box[name] else { continue }
            let imageName = rec["imageName"] ?? ""
            let address = rec["address"] ?? ""
            
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.likePlaces.append(exist)
                continue
            }
            
            let data = PlaceData(
                name: name,
                imageName: imageName,
                location: .init(latitude: 0, longitude: 0),
                address:address, number: ""
            )
            let likeRef = LikePlace(owner: boardRef, data: data)
            self.likePlaces.append(likeRef.id)
        }
    }
    
    
    @MainActor
    public func fetchRecentPlaces() async {
        // capture
        let boardRef = self.id
        let oldIDs = self.recentPlaces

        // compute
        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        let ordered: [String] = ((ud.array(forKey: keyMRU) as? [String]) ?? []).prefix(20).map { $0 }

        // mutate
        // 1) 빠진 것 정리
        for id in oldIDs {
            guard let q = id.ref?.name else { continue }
            if ordered.contains(q) == false {
                id.ref?.delete()
            }
        }

        // 2) 재구성(재사용 우선)
        self.recentPlaces = []
        for q in ordered {
            if let exist = oldIDs.first(where: { $0.ref?.name == q }) {
                self.recentPlaces.append(exist)
                continue
            }
            let data = PlaceData(
                name: q,
                imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: "",
                number: ""
            )
            let rec = RecentPlace(owner: boardRef, data: data)
            self.recentPlaces.append(rec.id)
        }
    }
    
    @MainActor
    public func fetchSearchPlaces() async {
        // capture
        let boardRef = self.id
        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let client = GMSPlacesClient.shared()
        let token = GMSAutocompleteSessionToken()

        // compute
        // 0) 빈 쿼리 처리
        if rawQuery.isEmpty {
            // mutate
            self.searchPlaces = []
            return
        }

        // 1) 자동완성 → 후보 placeID 최대 10개 (Sendable만 전달)
        let placeIDs: [String] = await withCheckedContinuation { (cont: CheckedContinuation<[String], Never>) in
            let filter = GMSAutocompleteFilter()
            filter.types = ["establishment"]
            filter.countries = ["KR"]

            client.findAutocompletePredictions(fromQuery: rawQuery, filter: filter, sessionToken: token) { preds, error in
                if let error = error { print("autocomplete error:", error); cont.resume(returning: []); return }
                let ids = (preds ?? []).prefix(10).map { $0.placeID }
                cont.resume(returning: Array(ids))
            }
        }

        // 2) placeID별 상세 → 값 스냅샷으로만 전달
        struct PlaceSnap {
            let name: String
            let lat: Double
            let lon: Double
            let address: String
            let phone: String
            let summary: String?
        }

        func fetchPlaceSnap(_ placeID: String) async -> PlaceSnap? {
            let fields: GMSPlaceField = [.name, .coordinate, .formattedAddress, .phoneNumber, .editorialSummary, .photos]
            return await withCheckedContinuation { (cont: CheckedContinuation<PlaceSnap?, Never>) in
                client.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { place, error in
                    if let error = error { print("fetchPlace error:", error); cont.resume(returning: nil); return }
                    guard let p = place, let nm = p.name else { cont.resume(returning: nil); return }
                    let snap = PlaceSnap(
                        name: nm,
                        lat: p.coordinate.latitude,
                        lon: p.coordinate.longitude,
                        address: p.formattedAddress ?? "",
                        phone: p.phoneNumber ?? "",
                        summary: p.editorialSummary // SDK에 따라 String? 타입
                    )
                    cont.resume(returning: snap)
                }
            }
        }

        var newDatas: [(name: String, data: PlaceData, summary: String?)] = []
        for pid in placeIDs {
            if let s = await fetchPlaceSnap(pid) {
                let pdata = PlaceData(
                    name: s.name,
                    imageName: "",
                    location: .init(latitude: s.lat, longitude: s.lon),
                    address: s.address,
                    number: s.phone
                )
                newDatas.append((s.name, pdata, s.summary))
            }
        }

        // 3) MRU 준비
        let ud = UserDefaults.standard
        let keyMRU = "MAPBOARD_RECENT_QUERIES"
        var mru = (ud.array(forKey: keyMRU) as? [String]) ?? []
        mru.removeAll { $0 == rawQuery }
        mru.insert(rawQuery, at: 0)
        if mru.count > 20 { mru = Array(mru.prefix(20)) }

        // mutate
        // A) 기존 중 새 결과에 없는 항목 정리
        let newNames = Set(newDatas.map { $0.name })
        for id in oldIDs {
            guard let nm = id.ref?.name else { continue }
            if newNames.contains(nm) == false {
                id.ref?.delete()
            }
        }

        // B) 재사용 우선으로 searchPlaces 재구성
        self.searchPlaces = []
        for (name, pdata, summary) in newDatas {
            if let exist = oldIDs.first(where: { $0.ref?.name == name }) {
                self.searchPlaces.append(exist)
            } else {
                let sp = SearchPlace(owner: boardRef, data: pdata)
                self.searchPlaces.append(sp.id)
            }
            if let s = summary {
                self.editorialSummaryByName[name] = s
            }
        }

        // C) MRU 저장
        ud.set(mru, forKey: keyMRU)
    }

    // value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            MapBoardManager.container[self] != nil
        }
        public var ref: MapBoard? {
            MapBoardManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class MapBoardManager: Sendable {
    // core
    static var container: [MapBoard.ID: MapBoard] = [:]
    static func register(_ object: MapBoard) {
        container[object.id] = object
    }
    static func unregister(_ id: MapBoard.ID) {
        container[id] = nil
    }
}

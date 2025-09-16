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
@preconcurrency import GooglePlaces
import UIKit

private let logger = NavioLogger("MapBoard")


// MARK: Object
@MainActor
public final class MapBoard: Sendable, ObservableObject {
    // MARK: core
    public init(owner: Navio) {
        self.owner = owner
        self.editorialSummaryByName = [:]
        self.detailByName = [:]
    }
    

    // MARK: state
    public nonisolated let owner: Navio
    
    private let photoCache = NSCache<NSString, UIImage>()   // 썸네일 캐시
    private var searchGen: UInt = 0
    

    @Published public private(set) var currentLocation: Location? = nil
    @Published public private(set) var isUpdatingLocation: Bool = false
    private func setLocation(_ newLocation: Location?) { self.currentLocation = newLocation }

    @Published public internal(set) var likePlaces: [LikePlace] = []
    internal func removeLikePlace(name: String) {
        self.likePlaces.removeAll {$0.name == name }
    }
    @Published public private(set) var isLikePlaceFetched: Bool = false
    
    @Published public internal(set) var recentPlaces: [RecentPlace] = []

    @Published public var searchInput: String = ""
    @Published public internal(set) var searchPlaces: [SearchPlace] = []
    @Published public internal(set) var editorialSummaryByName: [String: String] = [:]

    // 상세 스냅샷(값 타입만)
    @Published public internal(set) var detailByName: [String: PlaceDetail] = [:]

    // MARK: action
    public func updateLocation() async {
        await LocationManager.shared.getUserAuthentication()
        await LocationManager.shared.fetchMyLocation()
        let currentLocation = await LocationManager.shared.location
        self.currentLocation = currentLocation
    }

    public func startUpdating() async {
        guard self.isUpdatingLocation == false else { return }
        await LocationManager.shared.addHandler { [weak self] newLocation in
            Task { await self?.setLocation(newLocation) }
        }
        await LocationManager.shared.startStreaming()
        self.isUpdatingLocation = true
    }
    public func stopUpdating() async {
        await LocationManager.shared.stopStreaming()
    }

    public func fetchRecentPlaces() {
        //
        let googlePlaces = SearchPlace.load()
        
        var newPlaces: [RecentPlace] = []
        for googlePlace in googlePlaces {
            let recentPlaceRef = RecentPlace(owner: self, name: googlePlace.name)
            newPlaces.append(recentPlaceRef)
        }
        
        self.recentPlaces = newPlaces
    }
    
    public func fetchSearchPlaces() async {
        logger.start()
        
        print("[MapBoard] fetchSearchPlaces() called with input='\(self.searchInput)'")

        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawQuery.isEmpty == false else {
            self.searchPlaces = []
            return
        }
        
        let client = GMSPlacesClient.shared()                // Places SDK 클라이언트
        let token = GMSAutocompleteSessionToken()            // 자동완성/상세 호출 묶기 위한 세션 토큰(비용 최적화)
        let util = GooglePlaceUtil(client: client, token: token)
        
        let t0 = CFAbsoluteTimeGetCurrent()
        self.searchGen &+= 1
        let myGen = self.searchGen

        // compute
        async let placeIDsTask: [String] = await withCheckedContinuation { (cont: CheckedContinuation<[String], Never>) in
            let filter = GMSAutocompleteFilter()             // 자동완성 필터
            filter.types = ["establishment"]                 // 업장 유형만 제한
            filter.countries = ["KR"]
            
            util.client.findAutocompletePredictions(fromQuery: rawQuery, filter: filter, sessionToken: token) { preds, err in
                if let err = err { print("autocomplete error:", err); cont.resume(returning: []); return }
                let ids = (preds ?? []).prefix(6).compactMap { $0.placeID } // 6개로 제한
                cont.resume(returning: Array(ids))
            }
        }

        // 최신 입력만 반영
        guard myGen == self.searchGen else { return }
        print("T/snaps+photos", CFAbsoluteTimeGetCurrent() - t0)

        // 3) 목록/캐시 빌드
//        var assembled: [(placeID: String, name: String, data: PlaceData, summary: String?, image: UIImage)] = []
//        assembled.reserveCapacity(tuples.count)

//        for item in tuples {
//            let s = item.snap
//            let data = PlaceData(
//                name: s.name,
//                imageName: "",
//                location: .init(latitude: s.lat, longitude: s.lon),
//                address: s.address,
//                number: s.phone
//            )
//            // 상세 캐시
//            self.detailByName[s.name] = .init(
//                placeID: s.placeID,
//                name: s.name,
//                lat: s.lat, lon: s.lon,
//                address: s.address,
//                phone: s.phone,
//                website: s.website,
//                rating: s.rating,
//                priceLevelRaw: s.priceLevelRaw,
//                types: s.types,
//                weekdayText: s.weekdayText,
//                editorialSummary: s.summary
//            )
//            self.editorialSummaryByName[s.name] = s.summary ?? ""
//            assembled.append((s.placeID, s.name, data, s.summary, item.image))
//        }


        // 3) 스냅샷들을 수집하여 목록/상세 캐시 빌드
        let placeIDs = await placeIDsTask
        var newDatas: [PlaceTuple] = [] // 리스트 셀 구성용 튜플 배열

        newDatas = await withTaskGroup(of: PlaceTuple?.self) { group in
            for placeID in placeIDs {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    
                    async let snapTask = self.fetchPlaceSnap(placeID, client: util.client, token: util.token)
                    async let imageTask = self.fetchPlaceImage(placeID: placeID, client: util.client, token: util.token)
                    
                    guard let snap = await snapTask else { return nil }
                    
                    let placeData = PlaceData(
                        name: snap.name,
                        imageName: "",                                 // 사진은 상세에서 SDK로 별도 로드
                        location: .init(latitude: snap.lat, longitude: snap.lon),
                        address: snap.address,
                        number: snap.phone
                    )
                    
                    let image = await imageTask
                    
                    return PlaceTuple(id: placeID, data: placeData, image: image)
                }
            }
            
            var collected: [PlaceTuple] = []
            for await item in group {
                if let item {
                    collected.append(item)
                }
            }
            
            return collected
            
        }
        
//        for placeID in placeIDs {
//            guard let snap = await fetchPlaceSnap(placeID, client: client, token: token) else { continue } // 개별 실패 무시하고 다음
//
//            // (A) 목록 셀 최소 모델(PlaceData) 구성: 이름/좌표/주소/전화만
//            let placeData = PlaceData(
//                name: snap.name,
//                imageName: "",                                 // 사진은 상세에서 SDK로 별도 로드
//                location: .init(latitude: snap.lat, longitude: snap.lon),
//                address: snap.address,
//                number: snap.phone
//            )
//            
//            let placeImage = await fetchPlaceImage(placeID: placeID,
//                                                   client: client,
//                                                   token: token)
//
//            // (B) 상세화면용 값 캐시 갱신: 빠른 표시 위해 MapBoard가 보유
//            let detail = PlaceDetail(
//                placeID: snap.placeID,
//                name: snap.name,
//                lat: snap.lat, lon: snap.lon,
//                address: snap.address,
//                phone: snap.phone,
//                website: snap.website,
//                rating: snap.rating,
//                priceLevelRaw: snap.priceLevelRaw,
//                types: snap.types,
//                weekdayText: snap.weekdayText,
//                editorialSummary: snap.summary
//            )
//            self.detailByName[snap.name] = detail             // 키: 이름
//
//            // (C) 리스트 보조 텍스트(요약) 캐시도 갱신
//            self.editorialSummaryByName[snap.name] = snap.summary ?? ""
//
//            // (D) 최종적으로 테이블 재구성에 쓸 튜플 축적
//            newDatas.append(.init(id: placeID, data: placeData, image: placeImage))
//        }


        // (F) 화면 바인딩 배열 재구성: 동일 이름이 있으면 기존 ID 재사용
        var newPlaces: [SearchPlace] = []
        
        for data in newDatas {          // 신규 데이터 순회
            if let exist = oldIDs.first(where: { $0.name == data.data.name }) {
                self.searchPlaces.append(exist)               // 기존 ID 재사용
            } else {
                let sp = SearchPlace(owner: self, data: data.data, googlePlaceId: data.id) // 새 객체 생성
                
                sp.image = data.image
                
                 newPlaces.append(sp)               // ID 추가
            }
        }
        self.searchPlaces = newPlaces
        print("T/total", CFAbsoluteTimeGetCurrent() - t0)
    }
    
    public func removeRecentPlaces() {
        // capture
        let defaults = UserDefaults.standard
        defaults.set([], forKey: SearchPlace.udKey)
        
        self.recentPlaces = []
    }
    
    
    // MARK: Helphers
    private func fetchPlaceSnap(_ placeID: String, client: GMSPlacesClient, token: GMSAutocompleteSessionToken) async -> PlaceSnap? {
        // 호출할 피드
        let fields: GMSPlaceField = [
            .placeID, .name, .coordinate,
            .formattedAddress,
            .rating, .priceLevel, .types,
            .openingHours,
            .editorialSummary
        ]
        
        return await withCheckedContinuation { (cont: CheckedContinuation<PlaceSnap?, Never>) in
            client.fetchPlace(
                fromPlaceID: placeID,                    // 대상 placeID
                placeFields: fields,                     // 필드 집합
                sessionToken: token                      // 동일 세션 토큰
            ) { place, error in
                if let error = error {                   // 개별 실패는 nil 반환하고 계속
                    print("fetchPlace error:", error)
                    cont.resume(returning: nil)
                    return
                }
                guard let p = place, let name = p.name else {
                    cont.resume(returning: nil)          // 이름이 없으면 리스트 키로 사용할 수 없음
                    return
                }
                // SDK 모델 → 경량 스냅샷으로 매핑
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
                    summary: p.editorialSummary
                ))
            }
        }
    }
    private func fetchPlaceImage(placeID: String, client: GMSPlacesClient, token: GMSAutocompleteSessionToken) async -> UIImage {
        if let cached = photoCache.object(forKey: placeID as NSString) { return cached }
        let fallback = UIImage(systemName: "photo")!
        let thumbSize = CGSize(width: 120, height: 120)

        return await withCheckedContinuation { cont in
            client.fetchPlace(fromPlaceID: placeID,
                              placeFields: [.photos],                 // photos만
                              sessionToken: token) { place, err in
                if let err = err { print("fetchPlace error:", err); cont.resume(returning: fallback); return }
                guard let meta = place?.photos?.first else { cont.resume(returning: fallback); return }
                client.loadPlacePhoto(meta, constrainedTo: thumbSize, scale: UIScreen.main.scale) { image, e in
                    if let e = e { print("loadPhoto error:", e) }
                    let img = image ?? fallback
                    self.photoCache.setObject(img, forKey: placeID as NSString)
                    cont.resume(returning: img)
                }
            }
        }
    }
    
    // MARK: value
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
    
    public struct PlaceSnap: Sendable, Hashable {
        let placeID: String          // 고유 식별자
        let name: String             // 장소명(리스트 키)
        let lat: Double              // 위도
        let lon: Double              // 경도
        let address: String          // 주소
        let phone: String            // 전화
        let website: String?         // 웹사이트 URL 문자열
        let rating: Double           // 평점(0이면 없음)
        let priceLevelRaw: Int       // 가격대(rawValue 보존)
        let types: [String]          // 타입들
        let weekdayText: [String]    // 영업시간 요약 문자열(영문)
        let summary: String?         // 편집자 요약(editorialSummary)
    }
    
    public struct PlaceTuple: Sendable, Hashable {
        let id: String
        let data: PlaceData
        let image: UIImage
    }
    
    internal struct GooglePlaceUtil: @unchecked Sendable {
        let client: GMSPlacesClient
        let token: GMSAutocompleteSessionToken
    }
}

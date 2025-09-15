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
        // capture
        let boardRef = self
        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput
            .trimmingCharacters(in: .whitespacesAndNewlines) // 앞뒤 공백 제거
        let client = GMSPlacesClient.shared()                // Places SDK 클라이언트
        let token = GMSAutocompleteSessionToken()            // 자동완성/상세 호출 묶기 위한 세션 토큰(비용 최적화)

        if rawQuery.isEmpty {
            self.searchPlaces = []
            return
        }

        let placeIDs: [String] = await withCheckedContinuation { (cont: CheckedContinuation<[String], Never>) in
            let filter = GMSAutocompleteFilter()             // 자동완성 필터
            filter.types = ["establishment"]                 // 업장 유형만 제한
            filter.countries = ["KR"]
            client.findAutocompletePredictions(
                fromQuery: rawQuery,                         // 사용자 검색어
                filter: filter,                              // 필터 적용
                sessionToken: token                          // 같은 세션으로 묶어 과금 최적화
            ) { predictions, error in
                if let error = error {                       // 네트워크/쿼터 등 오류
                    print("autocomplete error:", error)
                    cont.resume(returning: [])               // 실패하면 빈 배열로 계속 진행
                    return
                }
                // 상위 10개까지만 사용, placeID만 추출
                let ids = (predictions ?? []).prefix(10).compactMap { $0.placeID }
                cont.resume(returning: Array(ids))           // 연속선택으로 반환
            }
        }

        // 3) 스냅샷들을 수집하여 목록/상세 캐시 빌드
        var newDatas: [(googlePlaceId: String, data: PlaceData, image: UIImage)] = [] // 리스트 셀 구성용 튜플 배열

        
        
        for placeID in placeIDs {
            guard let snap = await fetchPlaceSnap(placeID, client: client, token: token) else { continue } // 개별 실패 무시하고 다음

            // (A) 목록 셀 최소 모델(PlaceData) 구성: 이름/좌표/주소/전화만
            let placeData = PlaceData(
                name: snap.name,
                imageName: "",                                 // 사진은 상세에서 SDK로 별도 로드
                location: .init(latitude: snap.lat, longitude: snap.lon),
                address: snap.address,
                number: snap.phone
            )
            
            let placeImage = await fetchPlaceImage(placeID: placeID,
                                                   client: client,
                                                   token: token)

            // (B) 상세화면용 값 캐시 갱신: 빠른 표시 위해 MapBoard가 보유
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
                editorialSummary: snap.summary
            )
            self.detailByName[snap.name] = detail             // 키: 이름

            // (C) 리스트 보조 텍스트(요약) 캐시도 갱신
            self.editorialSummaryByName[snap.name] = snap.summary ?? ""

            // (D) 최종적으로 테이블 재구성에 쓸 튜플 축적
            newDatas.append((placeID, placeData, placeImage))
        }


        // (F) 화면 바인딩 배열 재구성: 동일 이름이 있으면 기존 ID 재사용
        var newPlaces: [SearchPlace] = []
        
        for (googlePlaceId, placeData, placeImage) in newDatas {          // 신규 데이터 순회
            if let exist = oldIDs.first(where: { $0.name == placeData.name }) {
                self.searchPlaces.append(exist)               // 기존 ID 재사용
            } else {
                let sp = SearchPlace(owner: boardRef, data: placeData, googlePlaceId: googlePlaceId) // 새 객체 생성
                
                sp.image = placeImage
                
                 newPlaces.append(sp)               // ID 추가
            }
        }
        
        self.searchPlaces = newPlaces
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
        let fields: GMSPlaceField = [                    // 필요한 것만 명시
            .placeID, .name, .coordinate,
            .formattedAddress, .phoneNumber, .website,
            .openingHours, .rating, .priceLevel, .types,
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
        // 요청할 정보
        let fields: GMSPlaceField = [
            .placeID, .name, .coordinate, .viewport,
            .formattedAddress, .addressComponents,
            .phoneNumber, .website,
            .openingHours, .rating, .userRatingsTotal, .priceLevel, .types,
            .editorialSummary, .photos
        ]
        
        return await withCheckedContinuation { continuation in
            // GoogleClient로 실제 요청
            client.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { [weak self] place, error in
                if let error = error { print("fetchPlace error:", error) }
                guard let self, let place = place else { return }

                // 사진 로드(있을 경우)
                if let meta = place.photos?.first {
                    client.loadPlacePhoto(meta, constrainedTo: CGSize(width: 800, height: 600), scale: UIScreen.main.scale) { [weak self] image, err in
                        if let err = err { print("loadPhoto error:", err) }
                        
                        let sampleImage = UIImage(systemName: "heart.fill")!
                        continuation.resume(returning: image ?? sampleImage)
                    }
                } else {
                    logger.failure("사진이 없습니다!!")
                    
                    // 사진이 없을 경우 SFSymbol로 대체
                    continuation.resume(returning: UIImage(systemName: "person.circle")!)
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
}

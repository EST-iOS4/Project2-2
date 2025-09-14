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

    /// 최근 검색어 목록 재구성(MRU → 메모리 모델)
    /// - UserDefaults("MAPBOARD_RECENT_QUERIES")에 저장된 검색어를 읽어
    ///   기존 객체 재사용/누락 삭제/신규 생성하여 `recentPlaces`를 최신 상태로 만듭니다.
    public func fetchRecentPlaces() async {
        // capture ------------------------------------------------------------
        let boardRef = self                      // 새 객체가 필요할 때 소유자로 연결할 보드 식별자
        let oldIDs = self.recentPlaces                  // 기존 화면 바인딩 배열을 캡처(재사용/삭제 판단)

        // compute ------------------------------------------------------------
        let ud = UserDefaults.standard                  // UserDefaults 핸들
        let keyMRU = "MAPBOARD_RECENT_QUERIES"          // MRU 저장 키
        // 최근 검색어 배열 로드(없으면 빈 배열) → 최대 10개까지만 사용
        let ordered: [String] = ((ud.array(forKey: keyMRU) as? [String]) ?? [])
            .prefix(10)                                 // 상한 적용
            .map { $0 }                                 // ArraySlice → [String]

        // mutate -------------------------------------------------------------
        // 1) 기존 항목 중, MRU 목록에 더 이상 없는 것은 삭제
//        for id in oldIDs {
//            guard let query = id.name else { continue } // ID가 가리키는 실제 객체의 "이름"을 검색어로 사용
//            if ordered.contains(query) == false {             // MRU에 없다면
//                id.ref?.delete()                              // 객체 삭제(스토리지 정합성 보존)
//            }
//        }

        // 2) 화면 바인딩 배열 재구성(재사용 우선)
        self.recentPlaces = []                             // 비움
        for query in ordered {                             // MRU에서 읽어온 순서대로
            if let exist = oldIDs.first(where: { $0.name == query }) {
                self.recentPlaces.append(exist)            // 기존 객체 재사용(아이덴티티 유지)
                continue
            }
            // 없으면 더미 데이터로 새 객체 생성(최근 검색은 좌표/주소/번호가 필요 없음)
            let data = PlaceData(
                name: query,                               // 셀에 표시할 텍스트
                imageName: "",
                location: .init(latitude: 0, longitude: 0),
                address: "",
                number: ""
            )
            let rec = RecentPlace(owner: boardRef, data: data)// 소유자 연결하여 생성
            self.recentPlaces.append(rec)               // ID를 화면 바인딩 배열에 추가
        }
    }

    /// 검색 실행: 자동완성 → placeID[] → 각 placeID 상세 스냅샷 → 목록/상세 캐시 갱신
    public func fetchSearchPlaces() async {
        // capture ------------------------------------------------------------
        let boardRef = self
        let oldIDs = self.searchPlaces
        let rawQuery = self.searchInput
            .trimmingCharacters(in: .whitespacesAndNewlines) // 앞뒤 공백 제거
        let client = GMSPlacesClient.shared()                // Places SDK 클라이언트
        let token = GMSAutocompleteSessionToken()            // 자동완성/상세 호출 묶기 위한 세션 토큰(비용 최적화)

        // compute ------------------------------------------------------------
        // 0) 검색어가 비었으면 즉시 목록 비우고 종료
        if rawQuery.isEmpty {
            self.searchPlaces = []                           // 화면에서 결과 제거
            return
        }

        // 1) 자동완성: 검색어 → 후보 placeID 배열
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

        // 2) 상세 스냅샷용 경량 모델(뷰모델) 정의
        struct PlaceSnap {
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

        // 2-1) placeID 하나에 대해 PlaceSnap 생성(필요한 필드만 요청하여 비용 절감)
        func fetchPlaceSnap(_ placeID: String) async -> PlaceSnap? {
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

        // 3) 스냅샷들을 수집하여 목록/상세 캐시 빌드 --------------------------
        var newDatas: [(name: String, data: PlaceData, summary: String?)] = [] // 리스트 셀 구성용 튜플 배열

        for placeID in placeIDs {                              // 자동완성으로 얻은 placeID들을 순회
            guard let snap = await fetchPlaceSnap(placeID) else { continue } // 개별 실패 무시하고 다음

            // (A) 목록 셀 최소 모델(PlaceData) 구성: 이름/좌표/주소/전화만
            let placeData = PlaceData(
                name: snap.name,
                imageName: "",                                 // 사진은 상세에서 SDK로 별도 로드
                location: .init(latitude: snap.lat, longitude: snap.lon),
                address: snap.address,
                number: snap.phone
            )

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
            newDatas.append((snap.name, placeData, snap.summary))
        }

        // 4) MRU 업데이트(중복 제거 → 앞 삽입 → 10개 제한) --------------------
        let ud = UserDefaults.standard                        // UserDefaults 핸들
        let keyMRU = "MAPBOARD_RECENT_QUERIES"                // MRU 저장 키
        var mru = (ud.array(forKey: keyMRU) as? [String]) ?? [] // 기존 MRU 불러오기
        mru.removeAll { $0 == rawQuery }                      // 동일 검색어 기존 항목 제거
        mru.insert(rawQuery, at: 0)                           // 맨 앞에 현재 검색어 삽입
        if mru.count > 10 { mru = Array(mru.prefix(10)) }     // 개수 제한(10)

        // mutate -------------------------------------------------------------
        // (E) 기존 searchPlaces 중 이번 결과에 없는 항목은 삭제
//        let newNames = Set(newDatas.map { $0.name })          // 신규 이름 집합
//        for id in oldIDs {
//            guard let name = id.name else { continue }
//            if newNames.contains(name) == false { id.delete() }
//        }

        // (F) 화면 바인딩 배열 재구성: 동일 이름이 있으면 기존 ID 재사용
        self.searchPlaces = []                                // 비우고
        for (name, placeData, summary) in newDatas {          // 신규 데이터 순회
            if let exist = oldIDs.first(where: { $0.name == name }) {
                self.searchPlaces.append(exist)               // 기존 ID 재사용
            } else {
                let sp = SearchPlace(owner: boardRef, data: placeData) // 새 객체 생성
                self.searchPlaces.append(sp)               // ID 추가
            }
            if let summary = summary {                        // 보조 텍스트 캐시 동기화
                self.editorialSummaryByName[name] = summary
            }
        }

        // (G) MRU 저장
        ud.set(mru, forKey: keyMRU)                           // 변경된 MRU를 UserDefaults에 반영
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
}

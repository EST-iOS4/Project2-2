//
//  MapBoardTestViewController.swift
//  NavioiOS
//
//  Created by 송영민 on 9/11/25.

import UIKit
import GooglePlaces
import Navio

// MARK: - PlaceDetailViewController
// 상세 화면 전용 뷰컨트롤러.
// - 이 VC는 "이름 문자열(placeName)"만 입력으로 받아,
//   1) 자동완성으로 placeID를 찾고,
//   2) placeID로 상세(fields) 정보를 가져와,
//   3) UI 라벨들에 표시합니다.
// - 네트워크 호출은 Google Places SDK만 사용(별도 REST/번역 없음).
// - 사진 로드는 SDK의 photo 메타를 이용해 진행합니다.
final class PlaceDetailViewController: UIViewController {
    // 입력: 목록에서 선택된 장소의 "이름" (SDK 자동완성 → placeID → 상세 조회 순서의 시작점)
    private let placeName: String

    // 의존성 최소화를 위해 이름만 주입받습니다.
    init(placeName: String) {
        self.placeName = placeName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: UI 컴포넌트
    // - 모든 라벨과 이미지뷰를 코드로 구성해 스토리보드 의존성을 제거합니다.
    // - stack(UIStackView)로 세로 레이아웃을 단순화합니다.
    private let stack = UIStackView()
    private let nameLabel = UILabel()
    private let coordLabel = UILabel()
    private let phoneLabel = UILabel()
    private let addrLabel = UILabel()
    private let idLabel = UILabel()
    private let websiteLabel = UILabel()
    private let ratingLabel = UILabel()
    private let reviewCountLabel = UILabel()
    private let priceLabel = UILabel()
    private let hoursLabel = UILabel()
    private let openNowLabel = UILabel()   // REST를 쓰지 않으므로, 계산/표시는 SDK의 weekday 텍스트 기반 보조 로직으로만 동작
    private let typesLabel = UILabel()
    private let summaryLabel = UILabel()
    private let imageView = UIImageView()
    private let attributionLabel = UILabel()

    // MARK: 라이프사이클
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "상세"
        view.backgroundColor = .systemBackground
        setupUI()     // UI 구성(오토레이아웃 포함)
        fetchDetail() // placeName → placeID → 상세정보 표시 플로우 시작
    }

    // MARK: UI 설정
    private func setupUI() {
        // 긴 텍스트가 올 수 있는 라벨들에 대해 줄바꿈 허용
        [summaryLabel, addrLabel, attributionLabel, typesLabel, hoursLabel].forEach { $0.numberOfLines = 0 }

        // 공통 폰트 설정(가독성)
        [nameLabel, coordLabel, phoneLabel, addrLabel, idLabel, websiteLabel,
         ratingLabel, reviewCountLabel, priceLabel, hoursLabel, openNowLabel,
         typesLabel, summaryLabel].forEach { $0.font = .systemFont(ofSize: 16) }
        nameLabel.font = .boldSystemFont(ofSize: 20)

        // 이미지뷰(사진) 설정
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // 스택뷰로 세로 레이아웃 구성
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        // 스택뷰에 모든 서브뷰 추가(보여줄 순서대로)
        [nameLabel, coordLabel, phoneLabel, addrLabel,
         idLabel, websiteLabel, ratingLabel, reviewCountLabel, priceLabel,
         hoursLabel, openNowLabel, typesLabel,
         summaryLabel, imageView, attributionLabel].forEach { stack.addArrangedSubview($0) }

        // 스택뷰 오토레이아웃
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    // MARK: 데이터 플로우: name → placeID → details
    // 1) 입력된 placeName으로 자동완성 API 호출 → 첫 번째 후보의 placeID 선택
    // 2) placeID로 상세(필드 지정) 조회 → UI 업데이트
    private func fetchDetail() {
        let client = GMSPlacesClient.shared()
        let token = GMSAutocompleteSessionToken()

        // 자동완성 필터: 업장(establishment) + 대한민국(KR)
        let filter = GMSAutocompleteFilter()
        filter.types = ["establishment"]
        filter.countries = ["KR"]

        // 자동완성: 이름 → 후보 배열
        client.findAutocompletePredictions(fromQuery: placeName, filter: filter, sessionToken: token) { [weak self] predictions, error in
            if let error = error { print("autocomplete error:", error) }

            // 첫 번째 후보의 placeID를 사용(간소화)
            guard let placeID = predictions?.first?.placeID else {
                DispatchQueue.main.async { self?.nameLabel.text = "검색 결과 없음" }
                return
            }

            // placeID로 상세 조회
            self?.fetchPlaceDetail(placeID: placeID, client: client, token: token)
        }
    }

    // MARK: 상세 조회
    // - 필요한 필드를 명시적으로 지정하여 최소한의 데이터만 가져옵니다(트래픽/비용 절감).
    private func fetchPlaceDetail(placeID: String, client: GMSPlacesClient, token: GMSAutocompleteSessionToken) {
        let fields: GMSPlaceField = [
            .placeID, .name, .coordinate, .viewport,
            .formattedAddress, .addressComponents,
            .phoneNumber, .website,
            .openingHours, .rating, .userRatingsTotal, .priceLevel, .types,
            .editorialSummary, .photos
        ]

        client.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: token) { [weak self] place, error in
            if let error = error { print("fetchPlace error:", error) }
            guard let self, let place = place else { return }

            // UI에 표시할 가공 데이터 준비
            let sdkSummary = place.editorialSummary ?? ""
            let prettyHoursText = self.prettyHours(place.openingHours?.weekdayText ?? [])

            // UI 업데이트는 메인 스레드에서
            DispatchQueue.main.async {
                self.nameLabel.text  = "이름: \(place.name ?? "-")"
                self.coordLabel.text = String(format: "좌표: %.6f, %.6f", place.coordinate.latitude, place.coordinate.longitude)
                self.phoneLabel.text = "전화: \(place.phoneNumber ?? "-")"
                self.addrLabel.text  = "주소: \(place.formattedAddress ?? "-")"
                self.idLabel.text    = "PlaceID: \(place.placeID ?? "-")"
                self.websiteLabel.text = "웹사이트: \(place.website?.absoluteString ?? "-")"

                // 평점/리뷰 수/가격대
                let rating = place.rating
                self.ratingLabel.text = rating > 0 ? String(format: "평점: %.1f", rating) : "평점: -"
                self.reviewCountLabel.text = "리뷰수: \(place.userRatingsTotal)"
                self.priceLabel.text = "가격대: \(self.priceString(place.priceLevel))"

                // 영업시간/타입/설명
                self.hoursLabel.text  = prettyHoursText.isEmpty ? "영업시간: -" : "영업시간:\n\(prettyHoursText)"
                self.typesLabel.text  = (place.types?.isEmpty == false) ? "타입: " + (place.types ?? []).joined(separator: ", ") : "타입: -"
                self.summaryLabel.text = "설명: \(sdkSummary.isEmpty ? "-" : sdkSummary)"

                // 영업여부: REST 미사용 정책에 따라 고정 또는 보조 계산(openNow(from:)) 결과를 표시합니다.
                self.openNowLabel.text = "영업여부: -"
            }

            // 사진 로드(있을 경우)
            if let meta = place.photos?.first {
                client.loadPlacePhoto(meta, constrainedTo: CGSize(width: 800, height: 600), scale: UIScreen.main.scale) { [weak self] image, err in
                    if let err = err { print("loadPhoto error:", err) }
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                        self?.attributionLabel.attributedText = meta.attributions
                    }
                }
            } else {
                // 사진이 없어도 영업여부 보조 계산은 시도 가능(weekday 텍스트에 의존)
                DispatchQueue.main.async {
                    self.imageView.image = nil
                    self.attributionLabel.text = ""

                    if let isOpen = self.openNow(from: place.openingHours?.weekdayText ?? []) {
                        self.openNowLabel.text = isOpen ? "영업여부: 영업중" : "영업여부: 영업종료"
                        self.openNowLabel.textColor = isOpen ? .systemGreen : .systemRed
                    } else {
                        self.openNowLabel.text = "영업여부: -"
                        self.openNowLabel.textColor = .label
                    }
                }
            }
        }
    }

    // MARK: - 유틸: 가격대 텍스트화
    private func priceString(_ level: GMSPlacesPriceLevel?) -> String {
        // SDK 열거형을 라벨에 표시하기 위한 간단한 치환(알 수 없으면 "-")
        let raw = level?.rawValue ?? -1
        switch raw {
        case -1: return "-"
        case  0: return "무료"
        case  1: return "₩"
        case  2: return "₩₩"
        case  3: return "₩₩₩"
        case  4: return "₩₩₩₩"
        default: return "-"
        }
    }

    // MARK: - 유틸: 요일별 영업시간 텍스트를 한국어 표기/하이라이트로 정리
    private func prettyHours(_ weekdayText: [String]) -> String {
        // weekdayText 예: ["Monday: 9:00 AM – 10:00 PM", ...]
        if weekdayText.isEmpty { return "" }

        // 오늘 요일(Monday=0 기준) 계산 → "오늘" 접두어를 붙여 가독성 향상
        let todayMon0 = ((Calendar(identifier: .gregorian).component(.weekday, from: Date()) + 5) % 7)
        let dayMap: [String:String] = [
            "Monday":"월","Tuesday":"화","Wednesday":"수","Thursday":"목",
            "Friday":"금","Saturday":"토","Sunday":"일"
        ]

        var lines: [String] = []
        for (index, rawLine) in weekdayText.enumerated() {
            // "Monday: ..." 에서 요일/시간 분리
            let parts = rawLine.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let dayEN = parts.first.map(String.init) ?? ""
            let dayKR = dayMap[dayEN] ?? dayEN

            // 우측 시간 문자열(없으면 "-")
            let times = (parts.count > 1) ? String(parts[1]).trimmingCharacters(in: .whitespaces) : "-"

            // en dash/figure space 등 다양한 구분자를 일반 하이픈 표기로 통일
            let normalized = times
                .replacingOccurrences(of: " – ", with: " ~ ")
                .replacingOccurrences(of: "–", with: " ~ ")
                .replacingOccurrences(of: " - ", with: " ~ ")

            let prefix = (index == todayMon0) ? "오늘 " : ""
            lines.append("• \(prefix)\(dayKR): \(normalized)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - 유틸: weekdayText 기반 단순 영업여부 추정
    // SDK에서 open_now를 직접 제공하지 않을 때, 오늘 요일의 텍스트를 파싱해 현재 시간이 범위에 들어가는지 계산.
    // 정확도 100% 보장은 어렵지만, REST를 사용하지 않는 상황에서 보조 지표로 사용할 수 있음.
    private func openNow(from weekdayText: [String]) -> Bool? {
        guard !weekdayText.isEmpty else { return nil }

        // 오늘(현지 시간대)의 요일명 영문(Monday, ...) 획득
        let cal = Calendar(identifier: .gregorian)
        let weekday = cal.component(.weekday, from: Date()) // 1=Sun ... 7=Sat
        let dayMap = [1:"Sunday",2:"Monday",3:"Tuesday",4:"Wednesday",5:"Thursday",6:"Friday",7:"Saturday"]

        guard let todayEN = dayMap[weekday],
              let line = weekdayText.first(where: { $0.hasPrefix(todayEN + ":") }) else {
            return nil
        }

        // "Monday: 9:00 AM – 10:00 PM, 11:00 PM – 2:00 AM" → 오른쪽 시간부만 추출
        let rhs = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            .dropFirst().first.map(String.init)?
            .trimmingCharacters(in: .whitespaces) ?? ""

        let lower = rhs.lowercased()
        if lower.contains("open 24 hours") { return true }  // 24시간 영업
        if lower.contains("closed") { return false }        // 휴무

        // 다양한 dash를 일반 하이픈으로 교체 후, 쉼표(, )로 여러 구간 분리
        let normalized = rhs.replacingOccurrences(of: " – ", with: " - ")
                            .replacingOccurrences(of: "–", with: " - ")
        let segments = normalized.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        // 현재 시각(초) 계산
        let nowSeconds = secondsSinceMidnight(Date())

        // 각 구간 "시작 - 종료" 파싱 → 현재가 포함되면 영업중(true) 반환
        for segment in segments {
            let parts = segment.components(separatedBy: " - ")
            guard parts.count == 2,
                  let startDate = parseTime(parts[0]),
                  let endDate   = parseTime(parts[1]) else { continue }

            let start = secondsSinceMidnight(startDate)
            let end   = secondsSinceMidnight(endDate)

            if start <= end {
                // 일반 구간(당일 내): now ∈ [start, end)
                if nowSeconds >= start && nowSeconds < end { return true }
            } else {
                // 자정 넘어가는 구간: now ∈ [start, 24h) ∪ [0, end)
                if nowSeconds >= start || nowSeconds < end { return true }
            }
        }
        return false
    }

    // "9:00 AM"/"9 AM" → Date 파싱(오늘 날짜의 시간으로만 사용)
    private func parseTime(_ text: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = text.contains(":") ? "h:mm a" : "h a"
        return f.date(from: text)
    }

    // Date → 자정부터 경과 초
    private func secondsSinceMidnight(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        return (c.hour ?? 0) * 3600 + (c.minute ?? 0) * 60 + (c.second ?? 0)
    }
}

// MARK: - MapBoardTestViewController
// MapBoard의 상태만 읽어 리스트를 그리는 간단한 테스트 화면.
// - 검색 실행/최근 불러오기 버튼으로 MapBoard 액션 트리거
// - 셀 탭 → PlaceDetailViewController로 네비게이션
final class MapBoardTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // 상태 소유자 주입
    private let mapBoard: MapBoard
    init(mapBoard: MapBoard) {
        self.mapBoard = mapBoard
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // UI
    private let seg = UISegmentedControl(items: ["검색 결과", "최근 검색"])
    private let searchButton = UIButton(type: .system)
    private let recentButton = UIButton(type: .system)
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MapBoard 테스트"
        view.backgroundColor = .systemBackground
        setupUI()

        // 기본 검색어 지정(초기 화면 확인용)
        mapBoard.searchInput = "아쿠아리움"
    }

    private func setupUI() {
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        searchButton.setTitle("검색 실행", for: .normal)
        searchButton.addTarget(self, action: #selector(runSearchButton), for: .touchUpInside)

        recentButton.setTitle("최근 불러오기", for: .normal)
        recentButton.addTarget(self, action: #selector(runRecentsButton), for: .touchUpInside)

        tableView.dataSource = self
        tableView.delegate = self

        let stack = UIStackView(arrangedSubviews: [seg, searchButton, recentButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func segmentChanged() { tableView.reloadData() }

    // 검색 실행(옵션으로 검색어 교체)
    private func runSearch(for query: String? = nil) {
        if let query = query { mapBoard.searchInput = query }
        Task { @MainActor in
            await mapBoard.fetchSearchPlaces()
            seg.selectedSegmentIndex = 0
            tableView.reloadData()
        }
    }

    @objc private func runSearchButton() {
        runSearch(for: nil)
    }

    @objc private func runRecentsButton() {
        Task { @MainActor in
            await mapBoard.fetchRecentPlaces()
            seg.selectedSegmentIndex = 1
            tableView.reloadData()
        }
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        seg.selectedSegmentIndex == 0 ? mapBoard.searchPlaces.count : mapBoard.recentPlaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

        if seg.selectedSegmentIndex == 0 {
            // 검색 결과
            let id = mapBoard.searchPlaces[indexPath.row]
            cell.textLabel?.text = id.name
            // 주소만 표시
            cell.detailTextLabel?.text = id.address
            cell.accessoryType = .disclosureIndicator
        } else {
            // 최근 검색어
            let id = mapBoard.recentPlaces[indexPath.row]
            cell.textLabel?.text = id.name
            cell.detailTextLabel?.text = "최근 검색어"
            cell.accessoryType = .none
        }
        cell.selectionStyle = .default
        return cell
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if seg.selectedSegmentIndex == 0 {
            // 상세로 이동: 이름만 전달 → 상세 VC 내부에서 placeID/상세 조회
            let id = mapBoard.searchPlaces[indexPath.row]
            guard !id.name.isEmpty else { return }
            let vc = PlaceDetailViewController(placeName: id.name)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // 최근 검색어를 즉시 재검색
            let id = mapBoard.recentPlaces[indexPath.row]
            guard !id.name.isEmpty else { return }
            runSearch(for: id.name)
        }
    }
}

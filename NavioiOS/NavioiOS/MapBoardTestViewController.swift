//
//  ComblinedViewController.swift
//  NavioiOS
//
//  Created by 송영민 on 9/11/25.

import UIKit
import GooglePlaces
import Navio

// 상세 VC: 나머지는 MapBoard에서 호출 사진만 호출
final class PlaceDetailViewController: UIViewController {
    private let placeName: String
    init(placeName: String) {
        self.placeName = placeName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // UI
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
    private let openNowLabel = UILabel()   // 고정 표기
    private let typesLabel = UILabel()
    private let summaryLabel = UILabel()
    private let imageView = UIImageView()
    private let attributionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "상세"
        view.backgroundColor = .systemBackground
        setupUI()
        fetchDetail()
    }
    
    private func setupUI() {
        [summaryLabel, addrLabel, attributionLabel, typesLabel, hoursLabel].forEach { $0.numberOfLines = 0 }
        [nameLabel, coordLabel, phoneLabel, addrLabel, idLabel, websiteLabel, ratingLabel, reviewCountLabel, priceLabel, hoursLabel, openNowLabel, typesLabel, summaryLabel]
            .forEach { $0.font = .systemFont(ofSize: 16) }
        nameLabel.font = .boldSystemFont(ofSize: 20)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        [nameLabel, coordLabel, phoneLabel, addrLabel,
         idLabel, websiteLabel, ratingLabel, reviewCountLabel, priceLabel,
         hoursLabel, openNowLabel, typesLabel,
         summaryLabel, imageView, attributionLabel].forEach { stack.addArrangedSubview($0) }
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    // name → placeID → details
    private func fetchDetail() {
        let client = GMSPlacesClient.shared()
        let token = GMSAutocompleteSessionToken()
        
        let filter = GMSAutocompleteFilter()
        filter.types = ["establishment"]
        filter.countries = ["KR"]
        
        client.findAutocompletePredictions(fromQuery: placeName, filter: filter, sessionToken: token) { [weak self] preds, err in
            if let err = err { print("autocomplete error:", err) }
            guard let pid = preds?.first?.placeID else {
                DispatchQueue.main.async { self?.nameLabel.text = "검색 결과 없음" }
                return
            }
            self?.fetchPlaceDetail(placeID: pid, client: client, token: token)
        }
    }
    
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
            guard let self, let p = place else { return }
            
            let sdkSummary = p.editorialSummary ?? ""
            let hoursPretty = self.prettyHours(p.openingHours?.weekdayText ?? [])
            
            DispatchQueue.main.async {
                self.nameLabel.text  = "이름: \(p.name ?? "-")"
                self.coordLabel.text = String(format: "좌표: %.6f, %.6f", p.coordinate.latitude, p.coordinate.longitude)
                self.phoneLabel.text = "전화: \(p.phoneNumber ?? "-")"
                self.addrLabel.text  = "주소: \(p.formattedAddress ?? "-")"
                self.idLabel.text    = "PlaceID: \(p.placeID ?? "-")"
                self.websiteLabel.text = "웹사이트: \(p.website?.absoluteString ?? "-")"
                
                let r = p.rating
                self.ratingLabel.text = r > 0 ? String(format: "평점: %.1f", r) : "평점: -"
                self.reviewCountLabel.text = "리뷰수: \(p.userRatingsTotal)"
                self.priceLabel.text = "가격대: \(self.priceString(p.priceLevel))"
                
                
                self.hoursLabel.text  = hoursPretty.isEmpty ? "영업시간: -" : "영업시간:\n\(hoursPretty)"
                self.openNowLabel.text = "영업여부: -" // 더 이상 REST로 조회하지 않음
                self.typesLabel.text  = (p.types?.isEmpty == false) ? "타입: " + (p.types ?? []).joined(separator: ", ") : "타입: -"
                self.summaryLabel.text = "설명: \(sdkSummary.isEmpty ? "-" : sdkSummary)"
            }
            
            // 사진(SDK)
            if let meta = p.photos?.first {
                client.loadPlacePhoto(meta, constrainedTo: CGSize(width: 800, height: 600), scale: UIScreen.main.scale) { [weak self] image, err in
                    if let err = err { print("loadPhoto error:", err) }
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                        self?.attributionLabel.attributedText = meta.attributions
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.imageView.image = nil
                    self.attributionLabel.text = ""
                    
                    if let on = self.openNow(from: p.openingHours?.weekdayText ?? []) {
                        self.openNowLabel.text = on ? "영업여부: 영업중" : "영업여부: 영업종료"
                        self.openNowLabel.textColor = on ? .systemGreen : .systemRed
                    } else {
                        self.openNowLabel.text = "영업여부: -"
                        self.openNowLabel.textColor = .label
                    }
                }
            }
        }
    }
    
    // MARK: 유틸
    private func priceString(_ level: GMSPlacesPriceLevel?) -> String {
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
    
    private func prettyHours(_ weekdayText: [String]) -> String {
        if weekdayText.isEmpty { return "" }
        let todayMon0 = ((Calendar(identifier: .gregorian).component(.weekday, from: Date()) + 5) % 7)
        let map: [String:String] = ["Monday":"월","Tuesday":"화","Wednesday":"수","Thursday":"목","Friday":"금","Saturday":"토","Sunday":"일"]
        var out: [String] = []
        for (i, raw) in weekdayText.enumerated() {
            let parts = raw.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            let dayEN = parts.first.map(String.init) ?? ""
            let dayKR = map[dayEN] ?? dayEN
            let times = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespaces) : "-"
            let normalized = times
                .replacingOccurrences(of: " – ", with: " ~ ")
                .replacingOccurrences(of: "–", with: " ~ ")
                .replacingOccurrences(of: " - ", with: " ~ ")
            let prefix = (i == todayMon0) ? "오늘 " : ""
            out.append("• \(prefix)\(dayKR): \(normalized)")
        }
        return out.joined(separator: "\n")
    }
    
    private func openNow(from weekdayText: [String]) -> Bool? {
        guard !weekdayText.isEmpty else { return nil }
        let cal = Calendar(identifier: .gregorian)
        let wd = cal.component(.weekday, from: Date()) // 1=Sun ... 7=Sat
        let dayMap = [1:"Sunday",2:"Monday",3:"Tuesday",4:"Wednesday",5:"Thursday",6:"Friday",7:"Saturday"]
        guard let day = dayMap[wd],
              let line = weekdayText.first(where: { $0.hasPrefix(day + ":") }) else { return nil }
        
        // "Monday: 9:00 AM – 10:00 PM, 11:00 PM – 2:00 AM"
        let rhs = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            .dropFirst().first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
        let lower = rhs.lowercased()
        if lower.contains("open 24 hours") { return true }
        if lower.contains("closed") { return false }
        
        let norm = rhs.replacingOccurrences(of: " – ", with: " - ")
            .replacingOccurrences(of: "–", with: " - ")
        let segments = norm.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let nowSec = secondsSinceMidnight(Date())
        for seg in segments {
            let parts = seg.components(separatedBy: " - ")
            guard parts.count == 2,
                  let s = parseTime(parts[0]),
                  let e = parseTime(parts[1]) else { continue }
            
            let sSec = secondsSinceMidnight(s)
            let eSec = secondsSinceMidnight(e)
            
            if sSec <= eSec {
                if nowSec >= sSec && nowSec < eSec { return true }
            } else {
                if nowSec >= sSec || nowSec < eSec { return true }
            }
        }
        return false
    }
    
    private func parseTime(_ t: String) -> Date? {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = t.contains(":") ? "h:mm a" : "h a"  // "9:00 AM" / "9 AM"
        return f.date(from: t)
    }
    
    private func secondsSinceMidnight(_ date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        return (c.hour ?? 0) * 3600 + (c.minute ?? 0) * 60 + (c.second ?? 0)
    }
}

// MapBoard 상태만 사용
final class MapBoardTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let mapBoard: MapBoard
    init(mapBoard: MapBoard) {
        self.mapBoard = mapBoard
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let seg = UISegmentedControl(items: ["검색 결과", "최근 검색"])
    private let searchButton = UIButton(type: .system)
    private let recentButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MapBoard 테스트"
        view.backgroundColor = .systemBackground
        setupUI()
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
    
    private func runSearch(for query: String? = nil) {
        if let q = query { mapBoard.searchInput = q }
        Task { @MainActor in
            await mapBoard.fetchSearchPlaces()
            seg.selectedSegmentIndex = 0
            tableView.reloadData()
        }
    }
    
    @objc private func runSearchButton() { runSearch(for: nil) }
    
    @objc private func runRecentsButton() {
        Task { @MainActor in
            await mapBoard.fetchRecentPlaces()
            seg.selectedSegmentIndex = 1
            tableView.reloadData()
        }
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        seg.selectedSegmentIndex == 0 ? mapBoard.searchPlaces.count : mapBoard.recentPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        if seg.selectedSegmentIndex == 0 {
            let id = mapBoard.searchPlaces[indexPath.row]
            cell.textLabel?.text = id.ref?.name ?? "(no name)"
            // 항상 주소만 표시(요약/번역 사용 안 함)
            cell.detailTextLabel?.text = id.ref?.address ?? ""
            cell.accessoryType = .disclosureIndicator
        } else {
            let id = mapBoard.recentPlaces[indexPath.row]
            cell.textLabel?.text = id.ref?.name ?? "(no query)"
            cell.detailTextLabel?.text = "최근 검색어"
            cell.accessoryType = .none
        }
        cell.selectionStyle = .default
        return cell
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if seg.selectedSegmentIndex == 0 {
            let id = mapBoard.searchPlaces[indexPath.row]
            guard let name = id.ref?.name, !name.isEmpty else { return }
            let vc = PlaceDetailViewController(placeName: name) // mapBoard 인자 제거
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let id = mapBoard.recentPlaces[indexPath.row]
            guard let q = id.ref?.name, !q.isEmpty else { return }
            runSearch(for: q)
        }
    }
}

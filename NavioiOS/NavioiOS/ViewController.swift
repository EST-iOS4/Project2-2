//
//  ViewController.swift
//  NavioiOS
//
//  Created by 김민우 on 9/4/25.
//
// MapBoardTestViewController.swift
import UIKit
import GooglePlaces
import CoreLocation
import Navio
// MapBoardTestViewController.swift
import UIKit
import GooglePlaces
import CoreLocation
import Navio

final class MapBoardTestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  // MARK: - State
  private let mapBoard = MapBoard(owner: Navio.ID()) // Navio 패키지의 ID 공개 가정

  // MARK: - UI
  private let seg = UISegmentedControl(items: ["검색 결과", "최근 검색"])
  private let searchButton = UIButton(type: .system)
  private let recentButton = UIButton(type: .system)
  private let tableView = UITableView()

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "MapBoard 테스트"
    view.backgroundColor = .systemBackground
    setupUI()
    mapBoard.searchInput = "잠실 카페"
  }

  // MARK: - UI Setup
  private func setupUI() {
    seg.selectedSegmentIndex = 0
    seg.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

    searchButton.setTitle("검색 실행", for: .normal)
    searchButton.addTarget(self, action: #selector(runSearchButton), for: .touchUpInside)

    recentButton.setTitle("최근 불러오기", for: .normal)
    recentButton.addTarget(self, action: #selector(runRecentsButton), for: .touchUpInside)

    tableView.dataSource = self
    tableView.delegate = self
    tableView.tableFooterView = UIView()

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

  // MARK: - Actions
  @objc private func segmentChanged() {
    tableView.reloadData()
  }

  // 공용 검색 실행: query 주면 그걸로, 없으면 현재 searchInput으로
  private func runSearch(for query: String? = nil) {
    if let q = query { mapBoard.searchInput = q }
    Task { @MainActor in
      await mapBoard.fetchSearchPlaces()
      seg.selectedSegmentIndex = 0 // 결과 탭으로 전환
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

  // MARK: - UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if seg.selectedSegmentIndex == 0 {
      return mapBoard.searchPlaces.count
    } else {
      return mapBoard.recentPlaces.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
      ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")

    if seg.selectedSegmentIndex == 0 {
      let id = mapBoard.searchPlaces[indexPath.row]
      cell.textLabel?.text = id.ref?.name ?? "(no name)"
      cell.detailTextLabel?.text = id.ref?.address ?? ""
      cell.accessoryType = .disclosureIndicator
    } else {
      let id = mapBoard.recentPlaces[indexPath.row]
      cell.textLabel?.text = id.ref?.name ?? "(no query)"
      cell.detailTextLabel?.text = "최근 검색어"
      cell.accessoryType = .none
    }
    cell.selectionStyle = .none
    return cell
  }

  // MARK: - UITableViewDelegate
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    if seg.selectedSegmentIndex == 0 {
      // 검색 결과 → 상세
      let id = mapBoard.searchPlaces[indexPath.row]
      guard let name = id.ref?.name else { return }
      let vc = PlaceDetailViewController(placeName: name)
      navigationController?.pushViewController(vc, animated: true)
    } else {
      // 최근 검색어 → 재검색 실행 후 결과 탭으로 전환
      let id = mapBoard.recentPlaces[indexPath.row]
      guard let q = id.ref?.name else { return } // recent는 name = query
      runSearch(for: q)
    }
  }
}

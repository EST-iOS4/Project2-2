//
//  SearchPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/9/25.
//

import UIKit

// MARK: - 리스트 데이터 모델
struct SearchItemData {
  let imageName: String
  let title: String
  let subtitle: String
}

// MARK: - 커스텀 리스트 셀
class SearchListCell: UITableViewCell {
  
  private let itemImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 25
    iv.backgroundColor = .systemGray5
    iv.tintColor = .systemBlue
    return iv
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    label.textColor = .black
    label.numberOfLines = 1
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .systemGray
    label.numberOfLines = 1
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    contentView.addSubview(itemImageView)
    contentView.addSubview(titleLabel)
    contentView.addSubview(subtitleLabel)
    
    selectionStyle = .none
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    itemImageView.frame = CGRect(x: 20, y: 10, width: 50, height: 50)
    titleLabel.frame = CGRect(x: 85, y: 15, width: contentView.frame.width - 100, height: 20)
    subtitleLabel.frame = CGRect(x: 85, y: 35, width: contentView.frame.width - 130, height: 20)
  }
  
  func configure(with data: SearchItemData) {
    itemImageView.image = UIImage(systemName: data.imageName)
    titleLabel.text = data.title
    subtitleLabel.text = data.subtitle
  }
}

// MARK: - 검색 모달 뷰컨트롤러
class SearchPlaceModalViewController: UIViewController {
  
  let searchBar = UISearchBar()
  let tableView = UITableView()
  
  let searchData = [
    SearchItemData(imageName: "cup.and.saucer.fill", title: "스타벅스", subtitle: "영업중 • 리뷰 999+ • 크림라떼와 부드러운 에스프레소를 드립니다."),
    SearchItemData(imageName: "mug.fill", title: "커피빈", subtitle: "영업중 • 리뷰 850+ • 스페셜 커피 음료를 제공합니다."),
    SearchItemData(imageName: "takeoutbag.and.cup.and.straw.fill", title: "투썸플레이스", subtitle: "영업 중 • 리뷰 650+ • 디저트와 음료 전문"),
    SearchItemData(imageName: "cup.and.saucer", title: "폴바셋", subtitle: "영업 중 • 리뷰 420+ • 프리미엄 커피 체인")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    view.backgroundColor = .systemBackground
    
    // 검색바 설정
    searchBar.placeholder = "카페"
    searchBar.searchBarStyle = .minimal
    
    // 테이블뷰 설정
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = .systemGray4
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 30)
    tableView.showsVerticalScrollIndicator = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(SearchListCell.self, forCellReuseIdentifier: "SearchListCell")
    
    view.addSubview(searchBar)
    view.addSubview(tableView)
  }
  
  func layoutViews(isExpanded: Bool) {
    if isExpanded {
      // 50% 확장 상태 - 리스트 보임
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      tableView.frame = CGRect(x: 0, y: 85, width: view.frame.width, height: view.frame.height - 85)
    } else {
      // 축소 상태 - 검색창만 보임
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      tableView.frame = CGRect.zero // 숨김
    }
  }
}

// MARK: - TableView DataSource & Delegate
extension SearchPlaceModalViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as! SearchListCell
    cell.configure(with: searchData[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
}

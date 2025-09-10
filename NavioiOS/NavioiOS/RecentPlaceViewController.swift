//
//  RecentPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/10/25.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - 최근 장소 데이터 모델
struct RecentPlaceData {
  let imageName: String
  let placeName: String
}

// MARK: - 최근 장소 검색 셀
class RecentPlaceCell: UITableViewCell {
  
  private let placeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 20
    iv.backgroundColor = .systemGray5
    iv.tintColor = .systemGray
    return iv
  }()
  
  private let placeNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.textColor = .black
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
    contentView.addSubview(placeImageView)
    contentView.addSubview(placeNameLabel)
    selectionStyle = .none
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    placeImageView.frame = CGRect(x: 20, y: 10, width: 40, height: 40)
    placeNameLabel.frame = CGRect(x: 75, y: 20, width: contentView.frame.width - 100, height: 20)
  }
  
  func configure(with data: RecentPlaceData) {
    placeImageView.image = UIImage(systemName: data.imageName)
    placeNameLabel.text = data.placeName
  }
}

// MARK: - 최근 장소 모달 뷰컨트롤러
class RecentPlaceViewController: UIViewController {
  
  let searchBar = UISearchBar()
  let dividerView = UIView()
  let LikeButtonStackView = UIStackView()
  let recentSearchLabel = UILabel()
  let deleteAllButton = UIButton()
  let tableView = UITableView()
  
  let shortcutData = ["홍익대학교", "석촌호수", "오시리아관광단지"]
  
  let recentPlaceData = [
    RecentPlaceData(imageName: "clock", placeName: "Times Square"),
    RecentPlaceData(imageName: "clock", placeName: "한강")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  // 프리뷰용으로 viewDidAppear 추가
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    layoutViews(isExpanded: true)
  }
  
  func setupUI() {
    view.backgroundColor = .systemBackground
    
    // 검색바 설정
    searchBar.placeholder = "검색하려는 장소를 입력하세요"
    searchBar.searchBarStyle = .minimal
    searchBar.showsCancelButton = false
    searchBar.delegate = self
    
    // 구분선 색상
    dividerView.backgroundColor = .systemGray3
    
    // 바로가기 버튼 스택뷰 설정
    LikeButtonStackView.axis = .horizontal
    LikeButtonStackView.spacing = 8
    LikeButtonStackView.distribution = .fillEqually
    
    for (index, shortcut) in shortcutData.enumerated() {
      let button = likeButton(title: shortcut, isSelected: index == 0)
      LikeButtonStackView.addArrangedSubview(button)
    }
    
    // 최근 검색 라벨 설정
    recentSearchLabel.text = "최근 검색"
    recentSearchLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    recentSearchLabel.textColor = .black
    
    // 삭제 버튼 설정
    deleteAllButton.setTitle("삭제", for: .normal)
    deleteAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    deleteAllButton.setTitleColor(.systemRed, for: .normal)
    
    // 테이블뷰 설정
    tableView.backgroundColor = .clear
    tableView.separatorStyle = .singleLine
    tableView.separatorColor = .systemGray3
    tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    tableView.showsVerticalScrollIndicator = false
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(RecentPlaceCell.self, forCellReuseIdentifier: "RecentPlaceCell")
    
    view.addSubview(searchBar)
    view.addSubview(dividerView)
    view.addSubview(LikeButtonStackView)
    view.addSubview(recentSearchLabel)
    view.addSubview(deleteAllButton)
    view.addSubview(tableView)
  }
  
  private func likeButton(title: String, isSelected: Bool) -> UIButton {
    let button = UIButton()
    var config = UIButton.Configuration.plain()
    
    // 하트 이미지 설정
    let heartImage = UIImage(systemName:"heart.circle.fill")
    config.image = heartImage
    config.title = title
    
    let imageConfig = UIImage.SymbolConfiguration(pointSize: 15)
    config.preferredSymbolConfigurationForImage = imageConfig
    
    // 버튼 패딩 설정
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 16)
    config.imagePadding = 5
    
    // 텍스트 스타일 (incoming: 기본 텍스트설정 사용)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont.systemFont(ofSize: 14, weight: .black)
      outgoing.foregroundColor = .systemGray
      return outgoing
    }
    config.titleLineBreakMode = .byClipping
    
    // 버튼에 configuration 적용
    button.configuration = config
    
    // 스타일 설정
    button.backgroundColor = .systemGray6
    button.tintColor = .systemPink
    button.layer.cornerRadius = 15
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.systemGray4.cgColor
    
    return button
  }
  
  func layoutViews(isExpanded: Bool) {
    if isExpanded {
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      dividerView.frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: 1)
      LikeButtonStackView.frame = CGRect(x: 20, y: 90, width: view.frame.width - 40, height: 30)
      recentSearchLabel.frame = CGRect(x: 20, y: 140, width: 100, height: 20)
      deleteAllButton.frame = CGRect(x: view.frame.width - 70, y: 140, width: 50, height: 20)
      tableView.frame = CGRect(x: 0, y: 170, width: view.frame.width, height: view.frame.height - 170)
      
      LikeButtonStackView.isHidden = false
      recentSearchLabel.isHidden = false
      deleteAllButton.isHidden = false
      tableView.isHidden = false
      dividerView.isHidden = false
    } else {
      // 축소 상태 - 검색창만 보임
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      
      dividerView.frame = CGRect.zero
      LikeButtonStackView.frame = CGRect.zero
      recentSearchLabel.frame = CGRect.zero
      deleteAllButton.frame = CGRect.zero
      tableView.frame = CGRect.zero
      
      
      LikeButtonStackView.isHidden = true
      recentSearchLabel.isHidden = true
      deleteAllButton.isHidden = true
      tableView.isHidden = true
      dividerView.isHidden = true
    }
  }
}

// MARK: - TableView DataSource & Delegate
extension RecentPlaceViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recentPlaceData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecentPlaceCell", for: indexPath) as! RecentPlaceCell
    cell.configure(with: recentPlaceData[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
}

// MARK: - SearchBar Delegate (RecentPlaceViewController 끝에 추가)
extension RecentPlaceViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          // 검색어가 있을 때만 전환
          guard let searchText = searchBar.text, !searchText.isEmpty else { return }
          
          // 키보드 숨기기
          searchBar.resignFirstResponder()
          
          // 부모 MapViewController에게 SearchModal 전환 요청
          if let parent = parent as? MapViewController {
              parent.showSearchModal()
          }
      }
      
      // 타이핑 중에는 아무것도 하지 않음
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      }
  
}

// MARK: - SwiftUI Preview
#if DEBUG
struct RecentPlaceViewController_Previews: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      RecentPlaceViewController()
    }
    .previewDevice("iPhone 16 Pro")
  }
}

struct RecentPlaceViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
  let viewController: ViewController
  
  init(_ builder: @escaping () -> ViewController) {
    viewController = builder()
  }
  
  func makeUIViewController(context: Context) -> ViewController {
    viewController
  }
  
  func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
#endif

//
//  RecentPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
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
      iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()
  
  private let placeNameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.textColor = .black
    label.numberOfLines = 1
      label.translatesAutoresizingMaskIntoConstraints = false
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
      
      NSLayoutConstraint.activate([
        placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        placeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        placeImageView.widthAnchor.constraint(equalToConstant: 40),
        placeImageView.heightAnchor.constraint(equalToConstant: 40),
        
        placeNameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 15),
        placeNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        placeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      ])
  }
  
  func configure(with data: RecentPlaceData) {
    placeImageView.image = UIImage(systemName: data.imageName)
    placeNameLabel.text = data.placeName
  }
}

// MARK: - 최근 장소 모달 뷰컨트롤러
class RecentPlaceViewController: UIViewController {
  
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "검색하려는 장소를 입력하세요"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let shortcutScrollView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.showsHorizontalScrollIndicator = false // 하단 스크롤바 숨기기
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            return scrollView
        }()
    
    let shortcutStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let recentSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemRed, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let tableView: UITableView = {
       let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
  
  let shortcutData = ["홍익대학교", "석촌호수", "오시리아관광단지"]
  
  let recentPlaceData = [
    RecentPlaceData(imageName: "clock", placeName: "Times Square"),
    RecentPlaceData(imageName: "clock", placeName: "한강")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    view.backgroundColor = .systemBackground
    
      for title in shortcutData {
          let button = createShortcutButton(title: title)
          shortcutStackView.addArrangedSubview(button)
      }
        
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(RecentPlaceCell.self, forCellReuseIdentifier: "RecentPlaceCell")
    
    view.addSubview(searchBar)
    view.addSubview(shortcutScrollView)
    shortcutScrollView.addSubview(shortcutStackView)
    view.addSubview(recentSearchLabel)
    view.addSubview(deleteAllButton)
    view.addSubview(tableView)
      
      NSLayoutConstraint.activate([
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
        
        shortcutScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
        shortcutScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        shortcutScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        shortcutScrollView.heightAnchor.constraint(equalToConstant: 35), // 스크롤뷰의 높이
                
        shortcutStackView.topAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.topAnchor),
        shortcutStackView.bottomAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.bottomAnchor),
        shortcutStackView.leadingAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.leadingAnchor, constant: 20), // 좌측 여백
        shortcutStackView.trailingAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.trailingAnchor, constant: -20), // 우측 여백
                
        shortcutStackView.heightAnchor.constraint(equalTo: shortcutScrollView.heightAnchor),
        
        recentSearchLabel.topAnchor.constraint(equalTo: shortcutStackView.bottomAnchor, constant: 20),
        recentSearchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        
        deleteAllButton.centerYAnchor.constraint(equalTo: recentSearchLabel.centerYAnchor),
        deleteAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
        tableView.topAnchor.constraint(equalTo: recentSearchLabel.bottomAnchor, constant: 10),
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
  }
  
    private func createShortcutButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .systemGray6
        config.baseForegroundColor = .black
        config.image = UIImage(systemName: "heart.fill")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: config)
        button.tintColor = .systemPink
        return button
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
//#if DEBUG
//struct RecentPlaceViewController_Previews: PreviewProvider {
//  static var previews: some View {
//    UIViewControllerPreview {
//      RecentPlaceViewController()
//    }
//    .previewDevice("iPhone 16 Pro")
//  }
//}
//
//struct RecentPlaceViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
//  let viewController: ViewController
//  
//  init(_ builder: @escaping () -> ViewController) {
//    viewController = builder()
//  }
//  
//  func makeUIViewController(context: Context) -> ViewController {
//    viewController
//  }
//  
//  func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
//}
//#endif

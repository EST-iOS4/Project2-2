//
//  RecentPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//

import Foundation
import UIKit

// MARK: - RecentPlaceData
// 역할: '최근 검색' 목록의 테이블 뷰에 표시될 데이터 하나의 형태를 정의
struct RecentPlaceData {
    let imageName: String
    let placeName: String
}

// MARK: - RecentPlaceCell
// 역할: UITableView 안에 들어갈 개별 셀의 UI와 레이아웃을 정의
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
        label.textColor = .label
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
      
        // Auto Layout 정의
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
  
    // 외부에서 데이터를 받아 셀의 UI를 업데이트하는 메서드
    func configure(with data: RecentPlaceData) {
        placeImageView.image = UIImage(systemName: data.imageName)
        placeNameLabel.text = data.placeName
    }
}

// MARK: - RecentPlaceModalViewController
// 역할: '최근 검색' 상태일 때 모달 컨테이너에 표시될 콘텐츠 ViewController
class RecentPlaceModalViewController: UIViewController {
  
    // MARK: - UI Components
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
        label.textColor = .label
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
    
        view.addSubview(shortcutScrollView)
        shortcutScrollView.addSubview(shortcutStackView)
        view.addSubview(recentSearchLabel)
        view.addSubview(deleteAllButton)
        view.addSubview(tableView)
      
        // Auto Layout 정의
        NSLayoutConstraint.activate([
            shortcutScrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            shortcutScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shortcutScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shortcutScrollView.heightAnchor.constraint(equalToConstant: 35),
                
            shortcutStackView.topAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.topAnchor),
            shortcutStackView.bottomAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.bottomAnchor),
            shortcutStackView.leadingAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            shortcutStackView.trailingAnchor.constraint(equalTo: shortcutScrollView.contentLayoutGuide.trailingAnchor, constant: -20),
                
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
  
    // 즐겨찾기 버튼 생성 헬퍼 메서드
    private func createShortcutButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = .secondarySystemBackground
        config.baseForegroundColor = .label
        config.image = UIImage(systemName: "heart.fill")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        
        let button = UIButton(configuration: config)
        button.tintColor = .systemPink
        return button
    }
    
    // 좋아요 버튼 생성 헬퍼 메서드
    // (현재 사용 안 함, 필요시 참고)
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
extension RecentPlaceModalViewController: UITableViewDataSource, UITableViewDelegate {
    
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

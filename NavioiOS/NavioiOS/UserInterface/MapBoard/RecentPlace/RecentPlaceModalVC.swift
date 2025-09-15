//
//  RecentPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//
import Foundation
import UIKit
import Navio
import Combine


// MARK: - RecentPlaceData
// 역할: '최근 검색' 목록의 테이블 뷰에 표시될 데이터 하나의 형태를 정의
struct RecentPlaceData {
    let imageName: String
    let placeName: String
}

// MARK: - RecentPlaceCell
// 역할: UITableView 안에 들어갈 개별 셀의 UI와 레이아웃을 정의


// MARK: - RecentPlaceModalViewController
// 역할: '최근 검색' 상태일 때 모달 컨테이너에 표시될 콘텐츠 ViewController
class RecentPlaceModalVC: UIViewController {
    // MARK: core
    private let mapBoardRef: MapBoard
    init(mapBoardRef: MapBoard) {
        self.mapBoardRef = mapBoardRef
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
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
        tv.separatorStyle = .singleLine
        tv.separatorColor = .opaqueSeparator
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
  
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        setupBinding()
        
        mapBoardRef.fetchRecentPlaces()
    }
    
    func setupBinding() {
        // 최근 검색 리스트 변화에 따른 UI 상태와 테이블 갱신
        mapBoardRef.$recentPlaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] places in
                guard let self = self else { return }
                // 비어있을 때 라벨/버튼 상태 조정
                self.recentSearchLabel.isHidden = places.isEmpty
                self.deleteAllButton.isEnabled = places.isEmpty == false
                // 테이블 갱신 (bind()에서도 처리하지만, 버튼/라벨 상태는 여기서 함께 관리)
                self.tableView.reloadData()
            }
            .store(in: &cancellables)

        // 전체 삭제 버튼 탭 처리
        deleteAllButton.addTarget(self, action: #selector(didTapDeleteAll), for: .touchUpInside)
    }
    
    @objc private func didTapDeleteAll() {
        // MRU(UserDefaults) 초기화 후, 보드의 최근목록 재빌드
        Task { 
            mapBoardRef.removeRecentPlaces()
        }
    }
  
    func setupUI() {
        view.backgroundColor = .systemBackground
    
        for place in mapBoardRef.likePlaces {
            let button = createShortcutButton(title: place.name)
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
  
    private func bind() {
        // MapBoard.recentPlaces가 변경될 때마다 테이블뷰 갱신
        mapBoardRef.$recentPlaces
            // 같은 구성으로 연속 방출 시 불필요한 reload 최소화(이름 배열 기준)
            .removeDuplicates { lhs, rhs in
                lhs.map { $0.name } == rhs.map { $0.name }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
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
        
        let heartImage = UIImage(systemName: "heart.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
        config.image = heartImage
      
        let button = UIButton(configuration: config)
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
extension RecentPlaceModalVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapBoardRef.recentPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentPlaceCell", for: indexPath) as! RecentPlaceCell
        cell.configure(with: mapBoardRef.recentPlaces[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

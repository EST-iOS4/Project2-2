//
//  LikePlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/9/25.
//

import Foundation
import UIKit
import MapKit
import Combine
import ToolBox
import SwiftUI
import Navio


// MARK: - 캐러셀 데이터 모델
struct PlaceCardData {
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - 커스텀 캐러셀 셀
class PlaceCardCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(placeImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 컨테이너 영역
        containerView.frame = CGRect(x: 0, y: 145, width: 202, height: 200)
        
        // 이미지 영역
        placeImageView.frame = CGRect(x: 3, y: 0, width: 200, height: 130)
        
        // 타이틀 라벨
        titleLabel.frame = CGRect(x: 50, y: 130, width: 126, height: 22)
        
        // 서브타이틀 라벨
        subtitleLabel.frame = CGRect(x: 50, y: 153, width: 126, height: 45)
    }
    
  func configure(with data: PlaceCardData) {
        placeImageView.image = UIImage(named: data.imageName) ?? UIImage(systemName: "photo.fill")
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
    }
}

// MARK: - 모달 뷰컨트롤러
class SearchModalViewController: UIViewController {
    
    let searchBar = UISearchBar()
    let likeLabel = UILabel()
    let collectionView: UICollectionView
    
    let placeData = [
        PlaceCardData(imageName: "building.2.fill", title: "홍익대학교", subtitle: "서울특별시 마포구 와우산로 94"),
        PlaceCardData(imageName: "building.columns.fill", title: "연세대학교", subtitle: "서울특별시 서대문구 연세로 50"),
        PlaceCardData(imageName: "graduationcap.fill", title: "고려대학교", subtitle: "서울특별시 성북구 안암로 145"),
        PlaceCardData(imageName: "book.fill", title: "서울대학교", subtitle: "서울특별시 관악구 관악로 1")
    ]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 검색바 설정
        searchBar.placeholder = "검색하기"
        searchBar.searchBarStyle = .minimal
        
        // Like 라벨 설정
        likeLabel.text = "Like"
        likeLabel.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        likeLabel.textColor = .black
        
        // 컬렉션뷰 설정
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCardCell.self, forCellWithReuseIdentifier: "PlaceCardCell")
        
        view.addSubview(searchBar)
        view.addSubview(likeLabel)
        view.addSubview(collectionView)
    }
    
    func layoutViews(isExpanded: Bool) {
        if isExpanded {
            // 50% 확장 상태 - 캐러셀 보임
            searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
            likeLabel.frame = CGRect(x: 30, y: 91, width: 100, height: 30)
            collectionView.frame = CGRect(x: 0, y: 129, width: view.frame.width, height: 220) // Like + 8 간격
        } else {
            // 축소 상태 - 검색창만 보임
            searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
            likeLabel.frame = CGRect.zero // 숨김
            collectionView.frame = CGRect.zero // 숨김
        }
    }
}

// MARK: - CollectionView DataSource & Delegate
extension SearchModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCardCell", for: indexPath) as! PlaceCardCell
        cell.configure(with: placeData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalInsets: CGFloat = 40
        let spacing: CGFloat = 16
        let availableWidth = view.frame.width - totalInsets - spacing
        let cellWidth = availableWidth / 1.5
        let originalHeight = (cellWidth * 238) / 202
        let cellHeight = originalHeight * 1.8
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - Home 뷰컨트롤러
class LikePlaceViewController: UIViewController {
    
    private var mapBoard: MapBoard!
    private var cancellables = Set<AnyCancellable>()
    
    let mapView = MKMapView()
    let modalContainerView = UIView()
    let searchBar = UISearchBar()
    
    var isModalExpanded = false
    let collapsedHeight: CGFloat = 100
    var expandedHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navioID = Navio.ID()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 지도 설정
        mapView.backgroundColor = .systemGray4
        view.addSubview(mapView)
        
        // 모달 설정
        modalContainerView.backgroundColor = .systemBackground
        modalContainerView.layer.cornerRadius = 20
        modalContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // 모달 뷰컨트롤러를 자식으로 추가
        let modalVC = SearchModalViewController()
        addChild(modalVC)
        modalContainerView.addSubview(modalVC.view)
        modalVC.view.frame = modalContainerView.bounds
        modalVC.didMove(toParent: self)
        view.addSubview(modalContainerView)
        
        // 레이아웃
        let tabBarHeight: CGFloat = 83
        let modalHeight: CGFloat = 100
        let availableHeight = view.frame.height - tabBarHeight  // 탭바 제외한 사용 가능 높이
        
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - modalHeight)
        modalContainerView.frame = CGRect(x: 0, y: availableHeight - modalHeight, width: view.frame.width, height: modalHeight)
        
        // 드래그 제스처 추가
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        modalContainerView.addGestureRecognizer(panGesture)
        
        layoutModal()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarHeight: CGFloat = 83
        let availableHeight = view.frame.height - tabBarHeight
        expandedHeight = availableHeight * 0.5  // 50% 계산
        layoutModal()
    }

    func layoutModal() {
        let tabBarHeight: CGFloat = 83
        let availableHeight = view.frame.height - tabBarHeight
        
        if isModalExpanded {
            // 확장 상태 (50%)
            mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - expandedHeight)
            modalContainerView.frame = CGRect(x: 0, y: availableHeight - expandedHeight, width: view.frame.width, height: expandedHeight)
            
            // 모달 내부의 캐러셀 표시
            if let modalVC = children.first as? SearchModalViewController {
                modalVC.layoutViews(isExpanded: true)
            }
        } else {
            // 축소 상태
            mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - collapsedHeight)
            modalContainerView.frame = CGRect(x: 0, y: availableHeight - collapsedHeight, width: view.frame.width, height: collapsedHeight)
            
            // 모달 내부의 캐러셀 숨김
            if let modalVC = children.first as? SearchModalViewController {
                modalVC.layoutViews(isExpanded: false)
            }
        }
        
        searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
        
        // 지도 라벨 위치 조정
        if let mapLabel = mapView.subviews.first as? UILabel {
            mapLabel.frame = CGRect(x: 0, y: mapView.frame.height / 2 - 15, width: view.frame.width, height: 30)
        }
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            let tabBarHeight: CGFloat = 83
            let availableHeight = view.frame.height - tabBarHeight
            let currentY = modalContainerView.frame.origin.y
            let newY = currentY + translation.y
            
            // 드래그 범위 제한
            let minY = availableHeight - expandedHeight  // 최대 확장
            let maxY = availableHeight - collapsedHeight  // 최소 축소
            
            let constrainedY = max(minY, min(maxY, newY))
            
            modalContainerView.frame.origin.y = constrainedY
            mapView.frame.size.height = constrainedY
            
            // 지도 라벨 위치 조정
            if let mapLabel = mapView.subviews.first as? UILabel {
                mapLabel.frame = CGRect(x: 0, y: mapView.frame.height / 2 - 15, width: view.frame.width, height: 30)
            }
            
            gesture.setTranslation(.zero, in: view)
            
        case .ended:
            let tabBarHeight: CGFloat = 83
            let availableHeight = view.frame.height - tabBarHeight
            let currentY = modalContainerView.frame.origin.y
            let midPoint = availableHeight - (expandedHeight + collapsedHeight) / 2
            
            // 위치와 속도에 따라 상태 결정 (아래로 드래그도 인식)
            if velocity.y < -300 || (velocity.y > 300) {
                // 빠르게 위로 드래그하거나 빠르게 아래로 드래그
                if velocity.y < 0 {
                    isModalExpanded = true  // 위로 드래그 → 확장
                } else {
                    isModalExpanded = false  // 아래로 드래그 → 축소
                }
            } else {
                // 속도가 느릴 때는 위치로 판단
                if currentY < midPoint {
                    isModalExpanded = true
                } else {
                    isModalExpanded = false
                }
            }
            
            // 애니메이션으로 최종 위치로 이동
            UIView.animate(withDuration: 0.3) {
                self.layoutModal()
            }
            
        default:
            break
        }
    }
}

// MARK: - SwiftUI Preview
//#if DEBUG
//struct MainTabBarController_Previews: PreviewProvider {
//    static var previews: some View {
//        UIViewControllerPreview {
//            MainTabBarController(mapBoard: mapBoard)
//        }
//    }
//}
//
//struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
//    let viewController: ViewController
//
//    init(_ builder: @escaping () -> ViewController) {
//        viewController = builder()
//    }
//
//    func makeUIViewController(context: Context) -> ViewController {
//        viewController
//    }
//
//    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
//}
//#endif

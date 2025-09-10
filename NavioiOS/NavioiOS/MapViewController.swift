//
//  MapViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//

import Foundation
import UIKit
import Navio
import Combine
import MapKit
import ToolBox
import SwiftUI


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
    
    containerView.frame = CGRect(x: 0, y: 145, width: 202, height: 200)
    placeImageView.frame = CGRect(x: 3, y: 0, width: 200, height: 130)
    titleLabel.frame = CGRect(x: 50, y: 130, width: 126, height: 22)
    subtitleLabel.frame = CGRect(x: 50, y: 153, width: 126, height: 45)
  }
  
  func configure(with data: PlaceCardData) {
    placeImageView.image = UIImage(named: data.imageName) ?? UIImage(systemName: "photo.fill")
    titleLabel.text = data.title
    subtitleLabel.text = data.subtitle
  }
}

// MARK: - Like 모달 뷰컨트롤러
class LikeModalViewController: UIViewController {
  
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
    
    searchBar.placeholder = "검색하기"
    searchBar.searchBarStyle = .minimal
    
    likeLabel.text = "Like"
    likeLabel.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
    likeLabel.textColor = .black
    
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
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      likeLabel.frame = CGRect(x: 30, y: 91, width: 100, height: 30)
      collectionView.frame = CGRect(x: 0, y: 129, width: view.frame.width, height: 220)
    } else {
      searchBar.frame = CGRect(x: 20, y: 25, width: view.frame.width - 40, height: 50)
      likeLabel.frame = CGRect.zero
      collectionView.frame = CGRect.zero
    }
  }
}

// MARK: - CollectionView DataSource & Delegate
extension LikeModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
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

// MARK: - Map 뷰컨트롤러 (Map 탭+모달 교체 기능)
class MapViewController: UIViewController {
  
  private let mapBoard: MapBoard
  private let mapView = MKMapView()
  private var cancellables = Set<AnyCancellable>()
    
  let modalContainerView = UIView()
    
    init(mapBoard: MapBoard) {
        self.mapBoard = mapBoard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
  var isModalExpanded = false
  let collapsedHeight: CGFloat = 100
  var expandedHeight: CGFloat = 0
  var currentModalVC: UIViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
      bindViewModel()
  }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await mapBoard.startUpdating()
        }
    }
  
  func setupUI() {
    view.backgroundColor = .systemBackground
    
    view.addSubview(mapView)
    
    modalContainerView.backgroundColor = .systemBackground
    modalContainerView.layer.cornerRadius = 20
    modalContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.addSubview(modalContainerView)
    
    showLikeModal()
    setupInitialLayout()
    
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    modalContainerView.addGestureRecognizer(panGesture)
  }
  
    private func bindViewModel() {
        mapBoard.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                self?.moveMap(to: coordinate)
            }
            .store(in: &cancellables)
        
        mapBoard.$likePlaces
            .sink { [weak self] placeIDs in
                let placeObjects = placeIDs.compactMap { $0.ref }
                self?.updatePins(for: placeObjects)
            }
            .store(in: &cancellables)
    }
    private func moveMap(to coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    private func updatePins(for places: [LikePlace]) {
        // 기존 핀 제거
        mapView.removeAnnotations(mapView.annotations)
        
        // 전달받은 배열 변환
        let newAnnotations = places.map { place -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: place.location.latitude, longitude: place.location.longitude)
            pin.title = place.name
            pin.subtitle = place.address
            return pin
        }
        
        // 새로운 핀 추가
        mapView.addAnnotations(newAnnotations)
        
        // 추가된 핀이 있다면, 모든 핀이 보이도록 지도 조정
        if !newAnnotations.isEmpty {
            mapView.showAnnotations(newAnnotations, animated: true)
        }
    }
    
  func setupInitialLayout() {
    let tabBarHeight: CGFloat = 83
    let modalHeight: CGFloat = 100
    let availableHeight = view.frame.height - tabBarHeight
    
    mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - modalHeight)
    modalContainerView.frame = CGRect(x: 0, y: availableHeight - modalHeight, width: view.frame.width, height: modalHeight)
    
    if let mapLabel = mapView.subviews.first as? UILabel {
      mapLabel.frame = CGRect(x: 0, y: (availableHeight - modalHeight) / 2 - 15, width: view.frame.width, height: 30)
    }
    
    if let likeModal = currentModalVC as? LikeModalViewController {
      likeModal.view.frame = modalContainerView.bounds
      likeModal.layoutViews(isExpanded: false)
    }else if let recentModal = currentModalVC as? RecentPlaceViewController {
      recentModal.view.frame = modalContainerView.bounds
      recentModal.layoutViews(isExpanded: false)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let tabBarHeight: CGFloat = 83
    let availableHeight = view.frame.height - tabBarHeight
    expandedHeight = availableHeight * 0.5
    layoutModal()
  }
  
  func layoutModal() {
    let tabBarHeight: CGFloat = 83
    let availableHeight = view.frame.height - tabBarHeight
    
    if isModalExpanded {
      mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - expandedHeight)
      modalContainerView.frame = CGRect(x: 0, y: availableHeight - expandedHeight, width: view.frame.width, height: expandedHeight)
      
      if let likeModal = currentModalVC as? LikeModalViewController {
        likeModal.view.frame = modalContainerView.bounds
        likeModal.layoutViews(isExpanded: true)
      } else if let recentModal = currentModalVC as? RecentPlaceViewController {
        recentModal.view.frame = modalContainerView.bounds
        recentModal.layoutViews(isExpanded: true)
      } else if let searchModal = currentModalVC as? SearchPlaceModalViewController {  // 추가
        searchModal.view.frame = modalContainerView.bounds
        searchModal.layoutViews(isExpanded: true)
    }
    } else {
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: availableHeight - collapsedHeight)
        modalContainerView.frame = CGRect(x: 0, y: availableHeight - collapsedHeight, width: view.frame.width, height: collapsedHeight)
      
        
        if let likeModal = currentModalVC as? LikeModalViewController {
          likeModal.view.frame = modalContainerView.bounds
          likeModal.layoutViews(isExpanded: false)
        } else if let recentModal = currentModalVC as? RecentPlaceViewController {
          recentModal.view.frame = modalContainerView.bounds
          recentModal.layoutViews(isExpanded: false)
        }
      }
      
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
        
        let minY = availableHeight - expandedHeight
        let maxY = availableHeight - collapsedHeight
        
        let constrainedY = max(minY, min(maxY, newY))
        
        modalContainerView.frame.origin.y = constrainedY
        mapView.frame.size.height = constrainedY
        
        if let mapLabel = mapView.subviews.first as? UILabel {
          mapLabel.frame = CGRect(x: 0, y: mapView.frame.height / 2 - 15, width: view.frame.width, height: 30)
        }
        
        gesture.setTranslation(.zero, in: view)
        
      case .ended:
        let tabBarHeight: CGFloat = 83
        let availableHeight = view.frame.height - tabBarHeight
        let currentY = modalContainerView.frame.origin.y
        let midPoint = availableHeight - (expandedHeight + collapsedHeight) / 2
        
        if velocity.y < -300 || (velocity.y > 300) {
          if velocity.y < 0 {
            isModalExpanded = true
          } else {
            isModalExpanded = false
            showLikeModal()
          }
        } else {
          if currentY < midPoint {
            isModalExpanded = true
          } else {
            isModalExpanded = false
            showLikeModal()
          }
        }
        
        UIView.animate(withDuration: 0.3) {
          self.layoutModal()
        }
        
      default:
        break
      }
    }
    
    
    func showLikeModal() {
      view.endEditing(true)
      
      let likeModalVC = LikeModalViewController()
      likeModalVC.searchBar.delegate = self
      switchModalContent(to: likeModalVC)
    }
    
    func showRecentModal() {
      let recentModalVC = RecentPlaceViewController()
      switchModalContent(to: recentModalVC)
      isModalExpanded = true
      let tabBarHeight: CGFloat = 83
      let availableHeight = view.frame.height - tabBarHeight
      expandedHeight = availableHeight * 0.8  // 80%
      
      UIView.animate(withDuration: 0.3) {
        self.layoutModal()
      }
    }
  func showSearchModal() {
      let searchModalVC = SearchPlaceModalViewController()
      switchModalContent(to: searchModalVC)
      isModalExpanded = true
      let tabBarHeight: CGFloat = 83
      let availableHeight = view.frame.height - tabBarHeight
      expandedHeight = availableHeight * 0.5  // 50%
      
      UIView.animate(withDuration: 0.3) {
          self.layoutModal()
      }
  }
  
  
    private func switchModalContent(to newModalVC: UIViewController) {
      currentModalVC?.removeFromParent()
      currentModalVC?.view.removeFromSuperview()
      
      addChild(newModalVC)
      modalContainerView.addSubview(newModalVC.view)
      newModalVC.view.frame = modalContainerView.bounds
      
      if let LikeModal = newModalVC as? LikeModalViewController {
        LikeModal.layoutViews(isExpanded: isModalExpanded)
      } else if let recentModal = newModalVC as? RecentPlaceViewController {
        recentModal.layoutViews(isExpanded: isModalExpanded)
        if isModalExpanded {
                    recentModal.searchBar.becomeFirstResponder()
                }
      } else if let searchModal = newModalVC as? SearchPlaceModalViewController {
        searchModal.layoutViews(isExpanded: isModalExpanded)
        searchModal.searchBar.becomeFirstResponder()
    }
      
      newModalVC.didMove(toParent: self)
      currentModalVC = newModalVC
    }
  }
  
  // MARK: - SearchBar Delegate
  extension MapViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
      showRecentModal()
      return false
    }
  }

// MARK: - SwiftUI Preview
//#if DEBUG
//  struct MapBaseViewTabBarController_Previews: PreviewProvider {
//    static var previews: some View {
//      UIViewControllerPreview {
//        MapBaseViewTabBarController()
//      }
//    }
//  }
//  
//  struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
//    let viewController: ViewController
//    
//    init(_ builder: @escaping () -> ViewController) {
//      viewController = builder()
//    }
//    
//    func makeUIViewController(context: Context) -> ViewController {
//      viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
//  }
//#endif

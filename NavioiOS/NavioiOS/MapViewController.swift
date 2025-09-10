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
      view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let placeImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleToFill
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 34
    iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
      iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 20)
    label.textColor = .black
    label.textAlignment = .right
    label.numberOfLines = 1
      label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 15)
    label.textColor = .systemGray
    label.textAlignment = .right
    label.numberOfLines = 2
    label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
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
      
      // 오토레이아웃
      NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            placeImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.65),
            
            titleLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            ])
  }
  
  func configure(with data: PlaceCardData) {
    placeImageView.image = UIImage(named: data.imageName) ?? UIImage(systemName: "photo.fill")
    titleLabel.text = data.title
    subtitleLabel.text = data.subtitle
  }
}

// MARK: - Like 모달 뷰컨트롤러
class LikeModalViewController: UIViewController {
    
    let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "검색하기"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    let likeLabel: UILabel = {
        let label = UILabel()
        label.text = "Like"
        label.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCardCell.self, forCellWithReuseIdentifier: "PlaceCardCell")
        
        view.addSubview(searchBar)
        view.addSubview(likeLabel)
        view.addSubview(collectionView)
        
        // 오토레이아웃
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            likeLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            likeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            collectionView.topAnchor.constraint(equalTo: likeLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func updateLayout(isExpanded: Bool) {
        likeLabel.isHidden = !isExpanded
        collectionView.isHidden = !isExpanded
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
    
    private let modalContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var modalHeightConstraint: NSLayoutConstraint!
    
    private var currentModalVC: UIViewController?
    private let collapsedHeight: CGFloat = 100
    private var expandedHeight: CGFloat = 400
    private var isModalExpanded = false
    
    
    init(mapBoard: MapBoard) {
        self.mapBoard = mapBoard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        showLikeModal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await mapBoard.startUpdating()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(mapView)
        view.addSubview(modalContainerView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        modalHeightConstraint = modalContainerView.heightAnchor.constraint(equalToConstant: collapsedHeight)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            modalContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            modalHeightConstraint
        ])
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
    
    func showLikeModal() {
        let likeModalVC = LikeModalViewController()
        likeModalVC.searchBar.delegate = self
        presentAsSheet(likeModalVC)
    }
    
    func showRecentModal() {
        let recentModalVC = RecentPlaceViewController()
        presentAsSheet(recentModalVC)
    }
    
    func showSearchModal() {
        let searchModalVC = SearchPlaceModalViewController()
        
        if let sheet = searchModalVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        self.present(searchModalVC, animated: true)
    }
    
    
    private func switchModalContent(to newModalVC: UIViewController) {
        currentModalVC?.willMove(toParent: nil)
        currentModalVC?.removeFromParent()
        currentModalVC?.view.removeFromSuperview()
        
        addChild(newModalVC)
        modalContainerView.addSubview(newModalVC.view)
        
        newModalVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newModalVC.view.topAnchor.constraint(equalTo: modalContainerView.topAnchor),
            newModalVC.view.leadingAnchor.constraint(equalTo: modalContainerView.leadingAnchor),
            newModalVC.view.trailingAnchor.constraint(equalTo: modalContainerView.trailingAnchor),
            newModalVC.view.bottomAnchor.constraint(equalTo: modalContainerView.bottomAnchor)
        ])
        newModalVC.didMove(toParent: self)
        currentModalVC = newModalVC
    }
    
    private func presentAsSheet(_ viewController: UIViewController) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        self.present(viewController, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        expandedHeight = view.safeAreaLayoutGuide.layoutFrame.height * 0.5
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        //        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            // 드래그에 따른 모달 높이 조정
            let newHeight = modalHeightConstraint.constant - translation.y
            
            modalHeightConstraint.constant = max(collapsedHeight, min(newHeight, expandedHeight))
            gesture.setTranslation(.zero, in: view)
            //            let tabBarHeight: CGFloat = 83
            //            let availableHeight = view.frame.height - tabBarHeight
            //            let currentY = modalContainerView.frame.origin.y
            //            let newY = currentY + translation.y
            //
            //            let minY = availableHeight - expandedHeight
            //            let maxY = availableHeight - collapsedHeight
            //
            //            let constrainedY = max(minY, min(maxY, newY))
            //
            //            modalContainerView.frame.origin.y = constrainedY
            //            mapView.frame.size.height = constrainedY
            //
            //            if let mapLabel = mapView.subviews.first as? UILabel {
            //                mapLabel.frame = CGRect(x: 0, y: mapView.frame.height / 2 - 15, width: view.frame.width, height: 30)
            //            }
            //
            //            gesture.setTranslation(.zero, in: view)
            
        case .ended:
            // 드래그가 끝났을 때 속도를 보고 모달 상태 결정
            let velocity = gesture.velocity(in: view)
            
            if velocity.y < 0 {
                isModalExpanded = true
            }
            else if velocity.y > 500 {
                isModalExpanded = false
            }
            else {
                isModalExpanded = modalHeightConstraint.constant > (collapsedHeight + expandedHeight) / 2
            }
            
            updateModalHeight(animated: true)
            
        default:
            break
        }
    }
    private func updateModalHeight(animated: Bool) {
        modalHeightConstraint.constant = self.isModalExpanded ? self.expandedHeight : self.collapsedHeight
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
}
  
  // MARK: - SearchBar Delegate
  extension MapViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.dismiss(animated: true) { [weak self] in
            self?.showRecentModal()
        }
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

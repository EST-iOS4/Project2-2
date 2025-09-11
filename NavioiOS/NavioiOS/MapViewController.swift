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
struct PlaceCardData: Pinnable {
    let imageName: String
    let title: String
    let subtitle: String?
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 커스텀 캐러셀 셀
class PlaceCardCell: UICollectionViewCell {
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .secondarySystemBackground
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
    label.textColor = .label
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
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let collectionView: UICollectionView
    
    let placeData = [
        PlaceCardData(imageName: "building.2.fill", title: "홍익대학교", subtitle: "서울특별시 마포구 와우산로 94", latitude: 37.5514, longitude: 126.9249),
        PlaceCardData(imageName: "building.columns.fill", title: "연세대학교", subtitle: "서울특별시 서대문구 연세로 50", latitude: 37.5658, longitude: 126.9386),
        PlaceCardData(imageName: "graduationcap.fill", title: "고려대학교", subtitle: "서울특별시 성북구 안암로 145", latitude: 37.5895, longitude: 127.0323),
        PlaceCardData(imageName: "book.fill", title: "서울대학교", subtitle: "서울특별시 관악구 관악로 1", latitude: 37.4598, longitude: 126.9519),
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
        
        view.addSubview(searchBar)
        view.addSubview(likeLabel)
        view.addSubview(collectionView)
        
        // 오토레이아웃
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            likeLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            likeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            collectionView.topAnchor.constraint(equalTo: likeLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCardCell.self, forCellWithReuseIdentifier: "PlaceCardCell")
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
    
      let cellHeight = collectionView.bounds.height - 20
      let cellWidth = cellHeight * (202.0 / 200.0)
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
}

// MARK: - Map 뷰컨트롤러 (Map 탭+모달 교체 기능)
class MapViewController: UIViewController {
    
    private let mapBoard: MapBoard
    private let mapView = MKMapView()
        
    private let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "검색하기"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userTrackingButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "location")
        button.setImage(image, for: .normal)
        button.backgroundColor = .systemBackground
        button.tintColor = .systemBlue
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var cancellables = Set<AnyCancellable>()
        
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
        mapView.delegate = self
        setupUI()
        bindViewModel()
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
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconView)
        searchContainerView.addSubview(searchLabel)
        
        view.addSubview(userTrackingButton)
        userTrackingButton.addTarget(self, action: #selector(userTrackingButtonTapped), for: .touchUpInside)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            searchContainerView.heightAnchor.constraint(equalToConstant: 50),
             
            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 15),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 20),
            searchIconView.heightAnchor.constraint(equalToConstant: 20),
             
            searchLabel.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchLabel.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchLabel.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -15),
            
            userTrackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userTrackingButton.bottomAnchor.constraint(equalTo: searchContainerView.topAnchor, constant: -10),
            userTrackingButton.widthAnchor.constraint(equalToConstant: 44),
            userTrackingButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchContainerTapped))
        searchContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func searchContainerTapped() {
        showLikeModal()
    }
    
    @objc private func userTrackingButtonTapped() {
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
        @unknown default:
            fatalError("Unknown user tracking mode")
        }
    }
    
    private func bindViewModel() {
        mapBoard.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in

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
    private func updatePins(for pinnableItems: [any Pinnable]) {
        // 기존 핀 제거
        mapView.removeAnnotations(mapView.annotations)
        
        // 전달받은 배열 변환
        let newAnnotations = pinnableItems.map { item -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.coordinate = item.coordinate
            pin.title = item.title
            pin.subtitle = item.subtitle
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
        
        updatePins(for: likeModalVC.placeData)
        
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
    
    private func presentAsSheet(_ viewController: UIViewController) {
        if self.presentedViewController != nil {
            self.dismiss(animated: true) { [weak self] in
                self?.presentSheet(viewController)
            }
        } else {
            presentSheet(viewController)
        }
    }
    
    private func presentSheet(_ viewController: UIViewController) {
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        self.present(viewController, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        expandedHeight = view.safeAreaLayoutGuide.layoutFrame.height * 0.5
    }

}
  
  // MARK: - SearchBar Delegate
extension MapViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.dismiss(animated: false) { [weak self] in
            self?.showRecentModal()
        }
        return false
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        switch mode {
        case .none:
            userTrackingButton.setImage(UIImage(systemName: "location"), for: .normal)
            userTrackingButton.tintColor = .systemGray
        case .follow:
            userTrackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
            userTrackingButton.tintColor = .systemBlue
        case .followWithHeading:
            userTrackingButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
            userTrackingButton.tintColor = .systemBlue
        @unknown default:
            break
        }
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

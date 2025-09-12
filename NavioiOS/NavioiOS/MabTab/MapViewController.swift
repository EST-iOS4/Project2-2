//
//  MapViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/11/25.
//

import Foundation
import UIKit
import Navio
import Combine
import MapKit
import ToolBox
import SwiftUI


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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "PlaceAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.clusteringIdentifier = "place"
        annotationView?.canShowCallout = true
        
        if annotationView?.rightCalloutAccessoryView == nil {
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let cluster = view.annotation as? MKClusterAnnotation else {
            return
        }
        mapView.showAnnotations(cluster.memberAnnotations, animated: true)
    }
    
//  핀 터치 시 상세 정보 뷰로 이동 (현재 주석 처리)
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        guard let tappedTitle = view.annotation?.title, let title = tappedTitle else { return }
//        if let place = mapBoard.likePlaces.first(where: { $0.title == title }) {
//            let placeID = place.id
//
//            상세 정보 뷰 컨트롤러는 여기에 연결하시면 됩니다. placeID를 전달받도록 만들어주세요.
//            let detailVC = PlaceDetailViewController(placeID: placeID)
//
//            if let navigationController = self.navigationController {
//                navigationController.pushViewController(detailVC, animated: true)
//            } else {
//                self.present(detailVC, animated: true)
//            }
//        }
//    }
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

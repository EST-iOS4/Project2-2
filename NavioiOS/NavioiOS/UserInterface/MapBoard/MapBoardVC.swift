//
//  MapViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/11/25.
//

import UIKit
import Navio
import Combine
import MapKit
import ToolBox


// MARK: - Map 뷰컨트롤러
// 역할: 지도 표시, ViewModel 데이터 바인딩, 검색 모달 띄우기
class MapBoardVC: UIViewController {
    private let mapBoard: MapBoard
    private let mapView = MKMapView()
    
    // 화면 하단에 위치한 '검색하기' 버튼 역할을 하는 커스텀 뷰
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
    
    // searchContainerView 돋보기 아이콘
    private let searchIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = .systemGray
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // searchContainerView 내부의 "검색하기" 텍스트 레이블
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "검색하기"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 지도 우측 하단의 현위치 추적 버튼
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
        
        // 버튼과 뷰에 액션을 연결
        userTrackingButton.addTarget(self, action: #selector(userTrackingButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchContainerTapped))
        searchContainerView.addGestureRecognizer(tapGesture)
        
        // Auto Layout 설정
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
    }
    
    // 검색 컨테이너 뷰 탭 액션
    @objc private func searchContainerTapped() {
        // 모달 컨테이너 뷰 컨트롤러와 LikeModal 뷰 컨트롤러 생성
        let modalContainer = ModalContainerVC(mapBoard)
        
        // LikeModal에 있는 목데이터로 핀 찍기
        updatePins(for: mapBoard.likePlaces)
        
        // 모달 컨테이너 띄우기
        if let sheet = modalContainer.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        present(modalContainer, animated: true)
    }
    
    // 현위치 추적 버튼 액션
    @objc private func userTrackingButtonTapped() {
        // none -> follow -> followWithHeading -> none 순환
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
    
    // Combine을 사용해 ViewModel의 데이터를 UI에 바인딩
    private func bindViewModel() {
        mapBoard.$likePlaces // 즐겨찾기 장소
            .sink { [weak self] placeIDs in
                let placeObjects = placeIDs.compactMap { $0 }
                self?.updatePins(for: placeObjects)
            }
            .store(in: &cancellables)
    }
    
    // 지도를 특정 좌표로 이동시키는 헬퍼 메서드
    private func moveMap(to coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // 핀 업데이트 메서드
    private func updatePins(for pinnableItems: [LikePlace]) {
        // 기존 핀 제거
        mapView.removeAnnotations(mapView.annotations)
        
        // 전달받은 배열 변환
        let newAnnotations = pinnableItems.map { item -> MKPointAnnotation in
            let pin = MKPointAnnotation()
            pin.coordinate = item.location.toCLLocationCoordinate2D
            pin.title = item.name
            pin.subtitle = item.address
            return pin
        }
        
        // 새로운 핀 추가
        mapView.addAnnotations(newAnnotations)
        
        // 추가된 핀이 있다면, 모든 핀이 보이도록 지도 조정
        if !newAnnotations.isEmpty {
            mapView.showAnnotations(newAnnotations, animated: true)
        }
    }
}

extension MapBoardVC: MKMapViewDelegate {
    
    // 지도의 추적 모드가 변경될 때마다 호출
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        // 추적 모드에 따라 버튼 이미지와 색상 변경
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
    
    // 지도에 핀(어노테이션)을 표시할 때 호출
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 사용자 위치 어노테이션은 기본 모양 사용
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let identifier = "PlaceAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        // 재사용할 뷰가 없으면 새로 생성
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            // 재사용할 뷰가 있으면 데이터만 업데이트
            annotationView?.annotation = annotation
        }
        
        // 클러스터링 설정 및 콜아웃 설정
        annotationView?.clusteringIdentifier = "place"
        annotationView?.canShowCallout = true
        
        // 정보창 오른쪽에 상세 정보 버튼 추가
        if annotationView?.rightCalloutAccessoryView == nil {
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        }
        return annotationView
    }
    
    // 클러스터 핀 터치 시 해당 클러스터에 속한 모든 핀을 보여줌
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // 탭한 핀이 클러스터인지 확인
        guard let cluster = view.annotation as? MKClusterAnnotation else {
            return
        }
        // 클러스터에 속한 모든 핀을 보여주도록 지도 조정
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

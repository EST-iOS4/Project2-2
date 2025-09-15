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

extension Notification.Name {
    static let mapShouldMoveToCoordinate = Notification.Name("MapShouldMoveToCoordinate")
    static let mapShouldFocusPlace       = Notification.Name("MapShouldFocusPlace")
}



// MARK: ViewController
// 역할: 지도 표시, ViewModel 데이터 바인딩, 검색 모달 띄우기
class MapBoardVC: UIViewController {
    // MARK: core
    private let mapBoardRef: MapBoard
    init(_ mapBoardRef: MapBoard) {
        self.mapBoardRef = mapBoardRef
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private final class PlaceAnnotation: MKPointAnnotation {
        var key: String = ""     // 검색: googlePlaceId, 즐겨찾기: name
        var isSearch: Bool = true
    }
    
    private var annSearchIndex: [String: SearchPlace] = [:] // key = googlePlaceId
    private var annLikeIndex:   [String: LikePlace]   = [:] // key = name
    
    // MARK: body
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupUI()
        bindViewModel()
        updatePins(for: mapBoardRef.likePlaces)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Task {
            await mapBoardRef.startUpdating()
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
        
        let modalContainer = ModalContainerVC(mapBoardRef)
        
        // LikeModal에 있는 목데이터로 핀 찍기
        updatePins(for: mapBoardRef.likePlaces)
        
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
        mapBoardRef.$likePlaces
            .receive(on: RunLoop.main)                    // ← 추가
            .sink { [weak self] places in
                self?.updatePins(for: places)
            }
            .store(in: &cancellables)

        mapBoardRef.$searchPlaces
            .receive(on: RunLoop.main)                    // ← 가능하면 이 줄도 추가
            .sink { [weak self] searchPlaces in
                self?.updatePins(for: searchPlaces)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .mapShouldMoveToCoordinate)
            .compactMap { $0.userInfo?["coordinate"] as? CLLocationCoordinate2D }
            .receive(on: RunLoop.main)                    // ← 추가
            .sink { [weak self] coordinate in
                self?.moveMap(to: coordinate)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .mapShouldFocusPlace)
            .sink { [weak self] note in
                guard let self = self,
                      let coord = note.userInfo?["coordinate"] as? CLLocationCoordinate2D else { return }
                let title    = note.userInfo?["title"] as? String
                let subtitle = note.userInfo?["subtitle"] as? String

                // 기존 사용자 위치 외 어노테이션 제거 후 단일 핀 추가
                let keepUser = self.mapView.annotations.compactMap { $0 as? MKUserLocation }
                self.mapView.removeAnnotations(self.mapView.annotations.filter { !($0 is MKUserLocation) })

                let pin = MKPointAnnotation()
                pin.coordinate = coord
                pin.title = title
                pin.subtitle = subtitle
                self.mapView.addAnnotation(pin)
                self.mapView.selectAnnotation(pin, animated: true)
            }
            .store(in: &cancellables)
    }
    
    // 지도를 특정 좌표로 이동시키는 헬퍼 메서드
    private func moveMap(to coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // 핀 업데이트 메서드
    private func updatePins(for searchPlaces: [SearchPlace]) {
        mapView.removeAnnotations(mapView.annotations)
        annSearchIndex.removeAll()
        
        let newAnnotations = searchPlaces.map { sp -> PlaceAnnotation in
            let pin = PlaceAnnotation()
            pin.coordinate = sp.location.toCLLocationCoordinate2D
            pin.title = sp.name
            pin.subtitle = sp.address
            pin.key = sp.name
            pin.isSearch = true
            annSearchIndex[sp.name] = sp
            return pin
        }
        
        mapView.addAnnotations(newAnnotations)
        if !newAnnotations.isEmpty { mapView.showAnnotations(newAnnotations, animated: true) }
    }


    private func updatePins(for pinnableItems: [LikePlace]) {
        mapView.removeAnnotations(mapView.annotations)
        annLikeIndex.removeAll()

        let newAnnotations = pinnableItems.compactMap { item -> MKPointAnnotation? in
            guard item.location.latitude != 0 || item.location.longitude != 0 else { return nil }
            let pin = PlaceAnnotation()
            pin.coordinate = item.location.toCLLocationCoordinate2D
            pin.title = item.name
            pin.subtitle = item.address
            pin.key = item.name
            pin.isSearch = false
            annLikeIndex[item.name] = item
            return pin
        }

        mapView.addAnnotations(newAnnotations)
        if !newAnnotations.isEmpty { mapView.showAnnotations(newAnnotations, animated: true) }
    }
    
    private func pushOrPresent(_ vc: UIViewController) {
        if let nav = self.navigationController { nav.pushViewController(vc, animated: true) }
        else { self.present(vc, animated: true) }
    }

    private func dismissModalIfNeeded(then work: @escaping () -> Void) {
        if let presented = self.presentedViewController {
            presented.dismiss(animated: true) { work() }
        } else {
            work()
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
    
// 핀 터치 시 상세 정보 뷰로 이동 (현재 주석 처리)
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        guard !(view.annotation is MKUserLocation) else { return }
        let title = (view.annotation?.title ?? nil) ?? ""
        let subtitle = (view.annotation?.subtitle ?? nil) ?? ""

        // 1) 즐겨찾기 우선
        if let like = mapBoardRef.likePlaces.first(where: { $0.name == title }) {
            let makeVC: () -> UIViewController = {
                if let hb = self.mapBoardRef.owner.homeBoard,
                   let place = hb.spots.flatMap({ $0.places }).first(where: { $0.name == like.name }) {
                    return PlaceVC(place)
                } else {
                    guard let hb = self.mapBoardRef.owner.homeBoard else { return UIViewController() }
                    let spot = Spot(owner: hb, data: .init(name: "즐겨찾기", imageName: ""))
                    let place = Place(owner: spot, data: like.placeData)
                    return PlaceVC(place)
                }
            }
            let vc = makeVC()
            dismissModalIfNeeded { [weak self] in self?.pushOrPresent(vc) }
            return
        }

        // 2) 검색 결과 매칭
        if let sp = mapBoardRef.searchPlaces.first(where: { $0.name == title })
            ?? mapBoardRef.searchPlaces.first(where: { $0.address == subtitle }) {

            guard let hb = mapBoardRef.owner.homeBoard else { return }
            let spot = Spot(owner: hb, data: .init(name: "검색", imageName: ""))
            let place = Place(owner: spot, data: sp.placeData)
            let vc = PlaceVC(place)
            dismissModalIfNeeded { [weak self] in self?.pushOrPresent(vc) }
            return
        }

        print("No matching place for annotation. title=\(title), subtitle=\(subtitle)")
    }
}

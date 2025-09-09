//
//  MapBoardViewController.swift
//  NavioiOS
//
//  Created by 구현모 on 9/9/25.
//

import UIKit
import Navio
import Combine
import MapKit
import ToolBox

class MapBoardViewController: UIViewController {

    private var mapBoard: MapBoard!
    private var cancellables = Set<AnyCancellable>()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
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
    
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "장소 검색하기"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - Initializer
    init(mapBoard: MapBoard) {
        self.mapBoard = mapBoard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 사용하지 않습니다.")
    }
    
    // MARK: - Lifecycle
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchTextField)
        
        // 오토 레이아웃
        NSLayoutConstraint.activate([
            // MapView
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Search Container
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            searchContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Search TextField
            searchTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 15),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -15),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        // ViewModel의 currentLocation이 바뀔 때마다 지도 업데이트
        mapBoard.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                self?.moveMap(to: coordinate)
            }
            .store(in: &cancellables)
        
        // TODO: 로직 구현 후 수정 필요
        // ViewModel의 LikeplaceObjects(객체 배열)가 바뀔 때마다 핀 업데이트
//        mapBoard.$likePlaceObjects
//            .sink { [weak self] places in
//                self?.updatePins(for: places)
//            }
//            .store(in: &cancellables)
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
}

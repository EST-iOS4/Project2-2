//
//  PlaceInfo.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/11/25.
//
import UIKit
import SwiftUI
import Navio
import MapKit
import Combine
import ToolBox


// MARK: ViewController
class PlaceVC: UIViewController {
    // MARK: core
    private let placeRef: Place
    private var cancellables = Set<AnyCancellable>()
    init(_ placeRef: Place) {
        self.placeRef = placeRef
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: body
    private let scrollView = UIScrollView()
    private let contentView = UIView()
  
    // 헤더
    private let titleLabel = UILabel() // 홍익대학교
    private let heartButton = UIButton(type: .system)
    private let subtitleLabel = UILabel() // 홍익대학교에 대한 간단한 설명
  
    // 이미지
    private let mainImageView = UIImageView() // 현재 임시 이미지 사용중
  
    // 기본정보 섹션
    private let infoContainerView = UIView()
    private let infoTitleLabel = UILabel() // 기본정보 제목 레이블
  
    // 지도
    private let mapView = MKMapView()
  
    // 주소
    private let addressContainerView = UIView()
    private let addressIconImageView = UIImageView() // 아이콘 이미지뷰
    private let addressTitleLabel = UILabel() // 주소
    private let addressLabel = UILabel() // 서울특별시 마포구 와우산로

    // 전화번호
    private let phoneContainerView = UIView()
    private let phoneIconImageView = UIImageView() // 아이콘 이미지뷰
    private let phoneTitleLabel = UILabel() // 전화번호
    private let phoneLabel = UILabel() // 02-420-1114

    // 길찾기 버튼
    private let visitButton = UIButton(type: .system)
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar() // 네비게이션바
        setupUI() // UI 요소 초기설정 및 스타일
        setupConstraints() // 오토레이아웃 제약조건
        bindPlace()
        configureData()
        configureMap()
    }
  
  // MARK: - UI 기본설정 메서드
  private func setupUI() {
    view.backgroundColor = .systemBackground

    // ScrollView 설정
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    // 뷰 계층구조 : 메인뷰 - scroll - content
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

      // MARK: - Header 섹션 설정
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      titleLabel.text = placeRef.name
      titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
      titleLabel.textColor = .label

    // 하트버튼 설정
    heartButton.translatesAutoresizingMaskIntoConstraints = false
    let heartImage = UIImage(systemName: "heart")?.withConfiguration(
      UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
    )
    heartButton.setImage(heartImage, for: .normal)
    heartButton.tintColor = .systemPink
    heartButton.contentHorizontalAlignment = .trailing
    heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside) // 탭 이벤트 연결

    // 서브타이틀 레이블 (장소설명)
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.text = placeRef.address
    subtitleLabel.font = .systemFont(ofSize: 17)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    subtitleLabel.lineBreakMode = .byWordWrapping

    // MARK: - 메인이미지 설정
    // 메인 이미지 설정
    mainImageView.translatesAutoresizingMaskIntoConstraints = false
    mainImageView.backgroundColor = .systemGray5
    mainImageView.clipsToBounds = true
    mainImageView.layer.cornerRadius = 12
    mainImageView.image = placeRef.image
    mainImageView.contentMode = .scaleAspectFill

    // MARK: - 기본 정보 컨테이너 설정
    // 기본 정보 컨테이너 설정
    infoContainerView.translatesAutoresizingMaskIntoConstraints = false
    infoContainerView.backgroundColor = .secondarySystemBackground
    infoContainerView.layer.cornerRadius = 14
    infoContainerView.layer.shadowColor = UIColor.black.cgColor
    infoContainerView.layer.shadowOpacity = 0.1
    infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    infoContainerView.layer.shadowRadius = 8

    // 기본정보 섹션의 제목 레이블
    infoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    infoTitleLabel.text = "기본 정보"
    infoTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    infoTitleLabel.textColor = .label

    // MARK: - 지도 섹션 설정
    // 지도 뷰 설정
    mapView.translatesAutoresizingMaskIntoConstraints = false
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.layer.cornerRadius = 8
    mapView.clipsToBounds = true

    // MARK: 주소 정보 섹션 설정

    // 주소 컨테이너 설정
    addressContainerView.translatesAutoresizingMaskIntoConstraints = false

    // 아이콘 설정
    addressIconImageView.translatesAutoresizingMaskIntoConstraints = false
    addressIconImageView.image = UIImage(systemName: "location")
    addressIconImageView.tintColor = .label
    addressIconImageView.contentMode = .scaleAspectFit

    // "주소" 레이블 설정
    addressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    addressTitleLabel.text = "주소"
    addressTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    addressTitleLabel.textColor = .label

    // 실제 주소 설정
    addressLabel.translatesAutoresizingMaskIntoConstraints = false
    addressLabel.text = placeRef.address
    addressLabel.font = .systemFont(ofSize: 14)
    addressLabel.textColor = .secondaryLabel

    // MARK: 전화번호 정보 섹션 설정
    // 전화번호 컨테이너 설정
    phoneContainerView.translatesAutoresizingMaskIntoConstraints = false

    // 아이콘 설정
    phoneIconImageView.translatesAutoresizingMaskIntoConstraints = false
    phoneIconImageView.image = UIImage(systemName: "phone")
    phoneIconImageView.tintColor = .label
    phoneIconImageView.contentMode = .scaleAspectFit

    // 전화번호 레이블 설정
    phoneTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    phoneTitleLabel.text = "전화번호"
    phoneTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    phoneTitleLabel.textColor = .label

    // 실제 번호 레이블 설정
    phoneLabel.translatesAutoresizingMaskIntoConstraints = false
    phoneLabel.text = placeRef.number
    phoneLabel.font = .systemFont(ofSize: 14)
    phoneLabel.textColor = .secondaryLabel

    // MARK: - 길찾기 버튼 설정
    visitButton.translatesAutoresizingMaskIntoConstraints = false
    visitButton.setTitle("길찾기", for: .normal)
    visitButton.backgroundColor = .systemBlue
    visitButton.setTitleColor(.white, for: .normal)
    visitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    visitButton.layer.cornerRadius = 12
    visitButton.addTarget(self, action: #selector(openInPreferredMaps), for: .touchUpInside)

    // MARK: - 뷰 계층구조 구성
    // 서브뷰 추가
    contentView.addSubview(titleLabel) // 메인타이틀
    contentView.addSubview(heartButton)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(mainImageView)
    contentView.addSubview(infoContainerView)

    infoContainerView.addSubview(infoTitleLabel) // 기본정보
    infoContainerView.addSubview(mapView)
    infoContainerView.addSubview(addressContainerView)
    infoContainerView.addSubview(phoneContainerView)
    infoContainerView.addSubview(visitButton)

    addressContainerView.addSubview(addressIconImageView)
    addressContainerView.addSubview(addressTitleLabel)
    addressContainerView.addSubview(addressLabel)

    phoneContainerView.addSubview(phoneIconImageView)
    phoneContainerView.addSubview(phoneTitleLabel)
    phoneContainerView.addSubview(phoneLabel)
  }
  
  // MARK: - 오토레이아웃 제약조건 설정
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      //ScrollView
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      //ContentView
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      // Title Label
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      
      // Heart Button
      heartButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      heartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
      heartButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
      
      // Subtitle Label
      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
      
      // Main Image
      mainImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
      mainImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      mainImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      mainImageView.heightAnchor.constraint(equalToConstant: 200),
      
      // Info Container
      infoContainerView.topAnchor.constraint(equalTo: mainImageView.bottomAnchor, constant: 20),
      infoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      infoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      infoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
      
      // Info Title
      infoTitleLabel.topAnchor.constraint(equalTo: infoContainerView.topAnchor, constant: 20),
      infoTitleLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
      infoTitleLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
      
      // Map View
      mapView.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 16),
      mapView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
      mapView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
      mapView.heightAnchor.constraint(equalToConstant: 200),
      
      // Address Container
      addressContainerView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
      addressContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
      addressContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
      addressContainerView.heightAnchor.constraint(equalToConstant: 50),
      
      // Address Icon
      addressIconImageView.leadingAnchor.constraint(equalTo: addressContainerView.leadingAnchor),
      addressIconImageView.centerYAnchor.constraint(equalTo: addressContainerView.centerYAnchor),
      addressIconImageView.widthAnchor.constraint(equalToConstant: 20),
      addressIconImageView.heightAnchor.constraint(equalToConstant: 20),
      
      // Address Title
      addressTitleLabel.leadingAnchor.constraint(equalTo: addressIconImageView.trailingAnchor, constant: 12),
      addressTitleLabel.topAnchor.constraint(equalTo: addressContainerView.topAnchor, constant: 4),
      
      // Address Label
      addressLabel.leadingAnchor.constraint(equalTo: addressIconImageView.trailingAnchor, constant: 12),
      addressLabel.topAnchor.constraint(equalTo: addressTitleLabel.bottomAnchor, constant: 2),
      addressLabel.trailingAnchor.constraint(equalTo: addressContainerView.trailingAnchor),
      
      // Phone Container
      phoneContainerView.topAnchor.constraint(equalTo: addressContainerView.bottomAnchor, constant: 16),
      phoneContainerView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
      phoneContainerView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
      phoneContainerView.heightAnchor.constraint(equalToConstant: 50),
      
      // Phone Icon
      phoneIconImageView.leadingAnchor.constraint(equalTo: phoneContainerView.leadingAnchor),
      phoneIconImageView.centerYAnchor.constraint(equalTo: phoneContainerView.centerYAnchor),
      phoneIconImageView.widthAnchor.constraint(equalToConstant: 20),
      phoneIconImageView.heightAnchor.constraint(equalToConstant: 20),
      
      // Phone Title
      phoneTitleLabel.leadingAnchor.constraint(equalTo: phoneIconImageView.trailingAnchor, constant: 12),
      phoneTitleLabel.topAnchor.constraint(equalTo: phoneContainerView.topAnchor, constant: 4),
      
      // Phone Label
      phoneLabel.leadingAnchor.constraint(equalTo: phoneIconImageView.trailingAnchor, constant: 12),
      phoneLabel.topAnchor.constraint(equalTo: phoneTitleLabel.bottomAnchor, constant: 2),
      phoneLabel.trailingAnchor.constraint(equalTo: phoneContainerView.trailingAnchor),
      
      // Visit Button
      visitButton.topAnchor.constraint(equalTo: phoneContainerView.bottomAnchor, constant: 24),
      visitButton.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
      visitButton.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
      visitButton.heightAnchor.constraint(equalToConstant: 50),
      visitButton.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -20)
      
    ])
  }

  private func updateHeart(isLiked: Bool) {
    let name = isLiked ? "heart.fill" : "heart"
    let image = UIImage(systemName: name)?.withConfiguration(
      UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
    )
    heartButton.setImage(image, for: .normal)
  }
  
  private func configureData() {
    titleLabel.text = placeRef.name
    subtitleLabel.text = placeRef.address
    mainImageView.image = placeRef.image
    addressLabel.text = placeRef.address
    phoneLabel.text = placeRef.number
    updateHeart(isLiked: placeRef.isLiked)
  }

  private func configureMap() {
    let coord = CLLocationCoordinate2D(latitude: placeRef.location.latitude,
                                       longitude: placeRef.location.longitude)
    let region = MKCoordinateRegion(center: coord,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    mapView.setRegion(region, animated: false)

    let annotation = MKPointAnnotation()
    annotation.coordinate = coord
    annotation.title = placeRef.name
    mapView.addAnnotation(annotation)
  }

  private func bindPlace() {
    placeRef.$isLiked
      .receive(on: RunLoop.main)
      .sink { [weak self] liked in
        self?.updateHeart(isLiked: liked)
      }
      .store(in: &cancellables)
  }
  
//  // MARK: - 데이터 전달 메서드(data configuration)
//  // place 화면에서 선택된 장소 데이터를 전달받는 메서드
//  func configure(with placeName: String) { //placeName: 홍대 등...
//    self.placeName = placeName
//
//    // viewDidLoad 후에 호출되면 즉시 업데이트
//    if isViewLoaded {
//      updateUI()
//    }
//  }
  
  // MARK: - 이벤트 핸들러
  @objc private func heartButtonTapped() {
    placeRef.toggleLike()
  }
  
  // 길찾기 버튼이 탭 되었을때 호출되는 메서드
    @objc private func openInPreferredMaps() {
        let lat = placeRef.location.latitude
        let lon = placeRef.location.longitude
        let name = placeRef.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Destination"
        let app = UIApplication.shared

        switch MapPrefStore.get() {          // ← 여기!
        case .apple:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: lat, longitude: lon)))
            item.name = placeRef.name
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])

        case .google:
            if let url = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving&q=\(name)"),
               app.canOpenURL(url) { app.open(url) }
            else if let web = URL(string: "https://maps.google.com/?daddr=\(lat),\(lon)&q=\(name)") {
                app.open(web)
            }

        case .naver:
            if let url = URL(string: "nmap://route/car?dlat=\(lat)&dlng=\(lon)&dname=\(name)"),
               app.canOpenURL(url) { app.open(url) }

        case .kakao:
            if let url = URL(string: "kakaomap://route?ep=\(lat),\(lon)&by=CAR"),
               app.canOpenURL(url) { app.open(url) }
        }
    }
  
  // MARK : - 네비게이션 바 설정
  
  private func setupNavigationBar() {
    // 네비게이션바 보이기 + 뒤로가기 버튼
    navigationController?.navigationBar.isHidden = false
    navigationItem.hidesBackButton = false
  }
}

//
//  HomeViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//
import UIKit
import Navio


// MARK: View
class HomeViewController: UIViewController {
    // MARK: core
    private let homeBoardRef: HomeBoard
    init(_ homeBoardRef: HomeBoard) {
        self.homeBoardRef = homeBoardRef
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
  // MARK: body
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  private let mainTitleLabel = UILabel() // 앱이름 표시(Navio)
  private let subtitleLabel = UILabel() // (어디로 떠나볼까요?⛱️)
  private let cardsStackView = UIStackView()
  
  // 카드 데이터
//  private let places = [
//    ("홍대", "building.2"),
//    ("잠실", "skyscraper"),
//    ("여의도", "building.columns"),
//    ("성수", "cube.transparent")
//  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar() // 네비게이션바 설정
    setupUI() // UI 요소 초기설정
    setupConstraints() // 오토레이아웃 제약조건 설정
    setupCards() // 장소 카드 생성 및 배치
  }
  
  // MARK: - Setup 메서드
  
  // 네비게이션 바 숨김
  private func setupNavigationBar() {
    navigationController?.navigationBar.isHidden = true
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // MARK: - ScrollView 설정
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    // 메인뷰 → ScrollView → ContentView
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    // MARK: - 메인 타이틀 (어플 이름)
    mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    mainTitleLabel.text = "Navio"
    mainTitleLabel.font = .italicSystemFont(ofSize: 22)
    mainTitleLabel.textColor = .label
    
    
    // MARK: - 서브타이틀
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.text = "어디로 떠나볼까요?⛱️"
    subtitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    subtitleLabel.textColor = .label
    
    
    // MARK: - 카드 스택뷰 설정
    cardsStackView.translatesAutoresizingMaskIntoConstraints = false
    cardsStackView.axis = .vertical
    cardsStackView.spacing = 16
    cardsStackView.distribution = .fillEqually
    
    // MARK: - UI뷰 추가
    contentView.addSubview(mainTitleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(cardsStackView)
  }
  
  // 오토레이아웃 제약조건 설정
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      
      // MARK: - ScrollView 제약조건
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // MARK: - ContentView 제약조건
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      // MARK: - Main Title (Navio) 제약조건
      mainTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // MARK: - Subtitle 제약조건
      subtitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // MARK: - Cards Stack View 제약조건
      cardsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
      cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      cardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
  }
  
  // 스택뷰에 배치 ( places 배열에 대해 카드 생성 -> 카드뷰에 데이터 전달 -> 스택뷰에 추가)
  private func setupCards() {
      homeBoardRef.setUpSampleSpots()
      
      for (index, spot) in homeBoardRef.spots.enumerated() {
          let cardView = createCardView(title: spot.name,
                                        spotImage: spot.image,
                                        tag: index)
          cardsStackView.addArrangedSubview(cardView)
      }
  }
  
  // 개별 장소 카드를 생성하는 헬퍼 메서드
  // tag: 카드식별을 위함. (탭 이벤트에서 사용)
  private func createCardView(title: String, spotImage: UIImage, tag: Int) -> UIView {
    let containerView = UIView()
    // MARK: - 카드 컨테이너뷰 설정
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .secondarySystemBackground
    containerView.layer.cornerRadius = 16
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowRadius = 8
    containerView.tag = tag
    
    // MARK: - 카드가 탭 되었을 때 실행
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
    
    // MARK: - 이미지 컨테이너 (현재는 아이콘배치)
    let imageContainerView = UIView()
    imageContainerView.translatesAutoresizingMaskIntoConstraints = false
    imageContainerView.backgroundColor = .systemGray5
    imageContainerView.layer.cornerRadius = 12
    imageContainerView.clipsToBounds = true
    
    // Placeholder 아이콘 (임시)
    let spotImageView = UIImageView()
    spotImageView.translatesAutoresizingMaskIntoConstraints = false
    spotImageView.image = spotImage
    spotImageView.contentMode = .scaleAspectFill
      spotImageView.clipsToBounds = true
      
    
    // MARK: - 타이틀 레이블
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
    titleLabel.textColor = .label
    
    // MARK: - 뷰 계층구조 구성
    // 서브뷰 추가 (카드 - 타이틀, 이미지컨테이너)
    containerView.addSubview(titleLabel)
    containerView.addSubview(imageContainerView)
    // (이미지 컨테이너 -> 아이콘)
    imageContainerView.addSubview(spotImageView)
    
    // MARK: - 카드 내부요소 제약조건 설정
    NSLayoutConstraint.activate([
      // 카드 높이
      containerView.heightAnchor.constraint(equalToConstant: 280),
      
      // Title Label 위치
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20),
      
      // Image Container 위치
      imageContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      imageContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
      
      // Placeholder Icon 위치
      spotImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
      spotImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
      spotImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
      spotImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor)
    ])
    
    return containerView
  }
  
  // MARK: 이벤트 핸들러
  
  // MARK: - 카드가 탭 되면 호출되는 메서드 (화면전환담당)
  // gesture : 탭 제스쳐 정보
  @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
    guard let tappedView = gesture.view else { return }  // tappedView: 탭된 뷰 가져오기
    let index = tappedView.tag // index: 카드의 태그(인덱스) 저장
      
      let selectedPlace = homeBoardRef.spots[index].name // selectedPlace: 해당 인덱스에 해당하는 카드의 장소명 불러와 저장
    
    // 탭 애니메이션 효과
    UIView.animate(withDuration: 0.1, animations: {
      tappedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }) { _ in
      UIView.animate(withDuration: 0.1) {
        tappedView.transform = CGAffineTransform.identity
      }
    }
    
    // Place 화면으로 이동
    navigateToPlaceViewController(with: selectedPlace)
  }
  
  // place: 선택된 장소명 ("홍대", "잠실" 등)
  private func navigateToPlaceViewController(with place: String) {
    let placeVC = Place(placeName: place) // 장소명 전달할 인스턴스 생성
    navigationController?.pushViewController(placeVC, animated: true) // 네비게이션으로 push, 화면전환
  }
}

//
//  Place.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/12/25.
//

import UIKit

class PlaceVC: UIViewController {
  
  // MARK: - UI 요소
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  private var placeName: String // Home에서 전달받은 장소명 저장 (홍대,잠실,여의도..)
  private let titleLabel = UILabel() // 현재 장소의 핫플 제목 표시 ( 홍대 핫플)
  private let cardsStackView = UIStackView()
  
  // 카드 데이터
  private let relatedPlaces = [
    "홍익대학교",
    "큐브이스케이프 홍대점",
    "홍대 롤링홀",
    "KT&G 상상마당"
  ]
  
  // MARK: - Initializer 메서드
  
  // HomeViewController에서 장소명을 전달받아 초기화하는 메서드
  init(placeName: String) {
    self.placeName = placeName
    super.init(nibName: nil, bundle: nil)
  }
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar() // 네비게이션바 설정
    setupUI() // UI 초기요소 설정
    setupConstraints() // 오토레이아웃 제약조건 설정
    setupCards() // 관련 장소 카드들 생성 및 배치
  }
  
  // MARK: - 네비게이션바 설정
  private func setupNavigationBar() {
    navigationController?.navigationBar.isHidden = false
    navigationItem.hidesBackButton = false
  }
  
  // MARK: - UI 설정 메서드
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // MARK: - ScrollView, ContentView 설정
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    // 뷰 계층구조 (Scroll -> Content)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    // MARK: - 타이틀 레이블 (ex. 홍대 핫플)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = "\(placeName) 핫플"
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textColor = .label
    
    // MARK: - 카드 스택뷰 설정
    cardsStackView.translatesAutoresizingMaskIntoConstraints = false
    cardsStackView.axis = .vertical
    cardsStackView.spacing = 16
    cardsStackView.distribution = .fill
    
    // MARK: - 계층구조에 뷰 추가
    contentView.addSubview(titleLabel)
    contentView.addSubview(cardsStackView)
  }
  
  
  // 오토레이아웃 제약조건 설정 메서드
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // MARK: ScrollView 제약조건
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // MARK: ContentView 제약조건
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      // MARK: 타이틀 레이블 제약조건
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // MARK: 카드 스택뷰 제약조건
      cardsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
      cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      cardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
  }
  
  // 카드뷰 생성 및 스택뷰 배치 메서드
  private func setupCards() {
    // 현재 장소 제외한 관련 장소들 필터링 (ex. 홍대에 관련된 세부 장소들)
    let filteredPlaces = relatedPlaces.filter { $0 != placeName }
    
    // 필터링된 장소의 카드생성
    for (index, place) in filteredPlaces.enumerated() {
      let cardView = createCardView(title: place, tag: index) // 개별 카드뷰 생성 (장소명, 인덱스)
      cardsStackView.addArrangedSubview(cardView) // 스택뷰에 추가
    }
  }
  
  // 개별 관련 장소 카드를 생성하는 헬퍼 메서드
  // tag: 카드 식별을 위함 ( 탭이벤트에서 사용)
  private func createCardView(title: String, tag: Int) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .secondarySystemBackground
    containerView.layer.cornerRadius = 16
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowRadius = 8
    containerView.tag = tag
    
    // MARK: - 카드가 탭 되었을 때 실행 (placeInfo로 이동)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
    
    // MARK: - 장소명 타이틀 레이블 설정
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    titleLabel.textColor = .label
    
    // MARK: - 하트 버튼 설정
    let heartButton = UIButton(type: .system)
    heartButton.translatesAutoresizingMaskIntoConstraints = false
    heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
    heartButton.tintColor = .systemRed
    heartButton.tag = tag
    heartButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
    
    // MARK: - 이미지 컨테이너 설정
    let imageContainerView = UIView()
    imageContainerView.translatesAutoresizingMaskIntoConstraints = false
    imageContainerView.backgroundColor = .systemGray5
    imageContainerView.layer.cornerRadius = 12
    imageContainerView.clipsToBounds = true
    
    // Placeholder (임시 이미지)
    let placeholderImageView = UIImageView()
    placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
    placeholderImageView.image = getPlaceholderImage(for: title)
    placeholderImageView.tintColor = .systemGray3
    placeholderImageView.contentMode = .scaleAspectFit
    
    // MARK: - 서브뷰 추가 ( 카드 - 타이틀,버튼,이미지 - 아이콘)
    containerView.addSubview(titleLabel)
    containerView.addSubview(heartButton)
    containerView.addSubview(imageContainerView)
    imageContainerView.addSubview(placeholderImageView)
    
    // MARK: - 카드 내부 제약조건 설정
    NSLayoutConstraint.activate([
      // 카드 높이
      containerView.heightAnchor.constraint(equalToConstant: 280),
      
      // Title Label
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      
      // Heart Button
      heartButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
      heartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      heartButton.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
      heartButton.widthAnchor.constraint(equalToConstant: 30),
      heartButton.heightAnchor.constraint(equalToConstant: 30),
      
      // Image Container
      imageContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      imageContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
      
      // Placeholder Image
      placeholderImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
      placeholderImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
      placeholderImageView.widthAnchor.constraint(equalToConstant: 40),
      placeholderImageView.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    return containerView
  }
  
  // MARK: - 헬퍼 메서드들 (Helper Methods)
  private func getPlaceholderImage(for place: String) -> UIImage? {
    switch place {
    case "홍익대학교":
      return UIImage(systemName: "graduationcap")
    case "큐브이스케이프 홍대점":
      return UIImage(systemName: "questionmark.square")
    case "홍대 롤링홀":
      return UIImage(systemName: "music.note")
    case "KT&G 상상마당":
      return UIImage(systemName: "theatermasks")
    default:
      return UIImage(systemName: "map")
    }
  }
  
  // MARK: - 이벤트 처리 메서드
  
  // MARK: - 카드가 탭 됐을 때 액션 (placeInfo로 화면전환)
  @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
    guard let tappedView = gesture.view else { return }
    let index = tappedView.tag
    let filteredPlaces = relatedPlaces.filter { $0 != placeName }
    
    if index < filteredPlaces.count {
      let selectedPlace = filteredPlaces[index] // 선택된 장소명 가져오기
      
      // 애니메이션 효과
      UIView.animate(withDuration: 0.1, animations: {
        tappedView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      }) { _ in
        UIView.animate(withDuration: 0.1) {
          tappedView.transform = CGAffineTransform.identity
        }
      }
      
      // MARK: - PlaceInfo로 이동
      let placeInfoVC = PlaceInfoVC()
      placeInfoVC.configure(with: selectedPlace)  // 선택된 장소 데이터 전달
      navigationController?.pushViewController(placeInfoVC, animated: true)
    }
  }
  
  // heartButton 애니메이션
  @objc private func heartButtonTapped(_ sender: UIButton) {
    UIView.animate(withDuration: 0.1, animations: {
      sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
    }) { _ in
      UIView.animate(withDuration: 0.1) {
        sender.transform = CGAffineTransform.identity
      }
    }
    
    // 하트 상태 변경
    let isSelected = sender.currentImage == UIImage(systemName: "heart.fill")
    let imageName = isSelected ? "heart" : "heart.fill"
    sender.setImage(UIImage(systemName: imageName), for: .normal)
  }
}

// MARK: - SwiftUI Preview (필요시 삭제)
import SwiftUI

struct Place_Preview: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      let navController = UINavigationController(rootViewController: PlaceVC(placeName: "홍대"))
      return navController
    }
    .previewDisplayName("Place")
    .previewDevice("iPhone 16 Pro")
  }
}

struct PlacePreview<ViewController: UIViewController>: UIViewControllerRepresentable {
  let viewController: ViewController
  
  init(_ builder: @escaping () -> ViewController) {
    viewController = builder()
  }
  
  func makeUIViewController(context: Context) -> ViewController {
    viewController
  }
  
  func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    // 업데이트 로직
  }
}


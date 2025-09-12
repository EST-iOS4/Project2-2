//
//  HomeViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//

import UIKit

class HomeViewController: UIViewController {
  
  // MARK: - UI 요소
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  private let mainTitleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let cardsStackView = UIStackView()
  
  // 카드 데이터
  private let places = [
    ("홍대", "building.2"),
    ("잠실", "skyscraper"),
    ("여의도", "building.columns"),
    ("성수", "cube.transparent")
  ]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupUI()
    setupConstraints()
    setupCards()
  }
  
  // MARK: - Setup 메서드
  private func setupNavigationBar() {
    navigationController?.navigationBar.isHidden = true
  }
  
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
    // ScrollView 설정
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.showsVerticalScrollIndicator = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    // 메인 타이틀 (어플 이름)
    mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    mainTitleLabel.text = "Navio"
    mainTitleLabel.font = .italicSystemFont(ofSize: 22)
    mainTitleLabel.textColor = .label
    
    
    // 서브타이틀
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.text = "어디로 떠나볼까요?⛱️"
    subtitleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    subtitleLabel.textColor = .label
    
    
    // 카드 스택뷰 설정
    cardsStackView.translatesAutoresizingMaskIntoConstraints = false
    cardsStackView.axis = .vertical
    cardsStackView.spacing = 16
    cardsStackView.distribution = .fillEqually
    
    // 서브뷰 추가
    contentView.addSubview(mainTitleLabel)
    contentView.addSubview(subtitleLabel)
    contentView.addSubview(cardsStackView)
  }
  
  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // ScrollView
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      // ContentView
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      
      // Main Title (Navio)
      mainTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
      mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // Subtitle
      subtitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      
      // Cards Stack View
      cardsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
      cardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      cardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      cardsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
    ])
  }
  
  // 스택뷰에 배치
  private func setupCards() {
    for (index, place) in places.enumerated() {
      let cardView = createCardView(title: place.0, iconName: place.1, tag: index)
      cardsStackView.addArrangedSubview(cardView)
    }
  }
  
  private func createCardView(title: String, iconName: String, tag: Int) -> UIView {
    let containerView = UIView()
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.backgroundColor = .systemBackground
    containerView.layer.cornerRadius = 16
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowRadius = 8
    containerView.tag = tag
    
    // 카드가 탭 되었을 때 실행
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
    containerView.addGestureRecognizer(tapGesture)
    containerView.isUserInteractionEnabled = true
    
    // 이미지 컨테이너
    let imageContainerView = UIView()
    imageContainerView.translatesAutoresizingMaskIntoConstraints = false
    imageContainerView.backgroundColor = .systemGray5
    imageContainerView.layer.cornerRadius = 12
    imageContainerView.clipsToBounds = true
    
    // Placeholder 아이콘 (임시)
    let placeholderIconImageView = UIImageView()
    placeholderIconImageView.translatesAutoresizingMaskIntoConstraints = false
    placeholderIconImageView.image = UIImage(systemName: iconName)
    placeholderIconImageView.tintColor = .systemGray3
    placeholderIconImageView.contentMode = .scaleAspectFit
    
    // 타이틀 레이블
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = .systemFont(ofSize: 25, weight: .semibold)
    titleLabel.textColor = .label
    
    // 서브뷰 추가
    containerView.addSubview(titleLabel)
    containerView.addSubview(imageContainerView)
    imageContainerView.addSubview(placeholderIconImageView)
    
    // 제약조건 설정
    NSLayoutConstraint.activate([
      // Container 높이
      containerView.heightAnchor.constraint(equalToConstant: 280),
      
      // Title Label
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20),
      
      // Image Container
      imageContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      imageContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      imageContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      imageContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
      
      // Placeholder Icon
      placeholderIconImageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
      placeholderIconImageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
      placeholderIconImageView.widthAnchor.constraint(equalToConstant: 40),
      placeholderIconImageView.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    return containerView
  }
  
  // MARK: - Card Tapped Actions (화면전환)
  @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
    guard let tappedView = gesture.view else { return }
    let index = tappedView.tag
    let selectedPlace = places[index].0
    
    // 애니메이션 효과
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
  
  private func navigateToPlaceViewController(with place: String) {
    let placeVC = Place(placeName: place)
    navigationController?.pushViewController(placeVC, animated: true)
  }
}

// MARK: - SwiftUI Preview (필요시 삭제)
import SwiftUI

struct HomeViewController_Preview: PreviewProvider {
  static var previews: some View {
    UIViewControllerPreview {
      let navController = UINavigationController(rootViewController: HomeViewController())
      return navController
    }
    .previewDisplayName("HomeViewController")
    .previewDevice("iPhone 16 Pro")
  }
}

struct HomaViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
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



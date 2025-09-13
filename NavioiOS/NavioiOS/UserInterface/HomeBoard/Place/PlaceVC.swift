//
//  Place.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/12/25.
//
import UIKit
import Navio


// MARK: ViewController
class PlaceVC: UIViewController {
    // MARK: core
    private let spotRef: Spot
    init(_ spotRef: Spot) {
        self.spotRef = spotRef
        
        spotRef.setUpSamplePlaces()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: body
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel() // 현재 장소의 핫플 제목 표시 ( 홍대 핫플)
    private let cardsStackView = UIStackView()

    // MARK: - Initializer 메서드
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
        titleLabel.text = "\(spotRef.name) 핫플"
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
        // 카드 생성
        for (index, placeRef) in spotRef.places.enumerated() {
            let cardView = createCardView(title: placeRef.name, image: placeRef.image, tag: index) // 개별 카드뷰 생성 (장소명, 이미지, 인덱스)
            cardsStackView.addArrangedSubview(cardView) // 스택뷰에 추가
        }
    }

    // 개별 관련 장소 카드를 생성하는 헬퍼 메서드
    // tag: 카드 식별을 위함 ( 탭이벤트에서 사용)
    private func createCardView(title: String, image: UIImage?, tag: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 12
        containerView.tag = tag

        // Tap to open place info
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true

        // Image view (fills the card)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20

        // A subtle bottom gradient to improve text readability
        let gradientView = GradientOverlayView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        // Capsule label (bottom-left) — match heart background with dark blur
        let pillBG = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        pillBG.translatesAutoresizingMaskIntoConstraints = false
        pillBG.layer.cornerRadius = 16
        pillBG.clipsToBounds = true
        pillBG.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        pillBG.layer.borderWidth = 0.5

        let pillLabel = UILabel()
        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pillLabel.text = title
        pillLabel.textColor = .white
        pillLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        pillLabel.numberOfLines = 1

        // Heart button (top-right)
        let heartButton = UIButton(type: .system)
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.tintColor = .systemRed
        heartButton.tag = tag
        heartButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)

        // Background behind heart for visibility
        let heartBG = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        heartBG.translatesAutoresizingMaskIntoConstraints = false
        heartBG.isUserInteractionEnabled = false
        heartBG.layer.cornerRadius = 20
        heartBG.clipsToBounds = true
        heartBG.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        heartBG.layer.borderWidth = 0.5

        // Stronger symbol size/weight
        let symConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
        heartButton.setPreferredSymbolConfiguration(symConfig, forImageIn: .normal)
        heartButton.tintColor = .systemRed
        heartButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        heartButton.accessibilityLabel = "즐겨찾기"

        // Build view hierarchy
        containerView.addSubview(imageView)
        containerView.addSubview(gradientView)
        containerView.addSubview(pillBG)
        pillBG.contentView.addSubview(pillLabel)
        containerView.addSubview(heartBG)
        containerView.addSubview(heartButton)

        // Constraints
        NSLayoutConstraint.activate([
            // Card height similar to first screenshot
            containerView.heightAnchor.constraint(equalToConstant: 230),

            // Image fills the card
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Gradient only on the bottom area
            gradientView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),

            // Pill label bottom-left (blur capsule + label insets)
            pillBG.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            pillBG.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),

            pillLabel.leadingAnchor.constraint(equalTo: pillBG.leadingAnchor, constant: 12),
            pillLabel.trailingAnchor.constraint(equalTo: pillBG.trailingAnchor, constant: -12),
            pillLabel.topAnchor.constraint(equalTo: pillBG.topAnchor, constant: 6),
            pillLabel.bottomAnchor.constraint(equalTo: pillBG.bottomAnchor, constant: -6),

            // Heart background (bigger hit area & visibility)
            heartBG.widthAnchor.constraint(equalToConstant: 48),
            heartBG.heightAnchor.constraint(equalToConstant: 48),
            heartBG.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            heartBG.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            // Heart button centered inside background
            heartButton.centerXAnchor.constraint(equalTo: heartBG.centerXAnchor),
            heartButton.centerYAnchor.constraint(equalTo: heartBG.centerYAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 36),
            heartButton.heightAnchor.constraint(equalToConstant: 36)
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
        let selectedPlace = spotRef.places[index]
//        let filteredPlaces = relatedPlaces.filter { $0 != placeName }

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
        placeInfoVC.configure(with: selectedPlace.name)  // 선택된 장소 데이터 전달
        navigationController?.pushViewController(placeInfoVC, animated: true)
    }

    // heartButton favorite toggle animation
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

private final class GradientOverlayView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.35).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 20
    }
}

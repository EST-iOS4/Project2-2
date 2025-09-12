//
//  PlaceInfo.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/11/25.
//

import UIKit
import SwiftUI

class PlaceInfo: UIViewController {
    
    // MARK: - UI 요소
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let heartButton = UIButton(type: .system)
    private let subtitleLabel = UILabel()
    
    private let mainImageView = UIImageView()
    
    private let infoContainerView = UIView()
    private let infoTitleLabel = UILabel()
    
    private let mapPlaceholderView = UIView()
    private let mapImageView = UIImageView()
    
    private let addressContainerView = UIView()
    private let addressIconImageView = UIImageView()
    private let addressTitleLabel = UILabel()
    private let addressLabel = UILabel()
    
    private let phoneContainerView = UIView()
    private let phoneIconImageView = UIImageView()
    private let phoneTitleLabel = UILabel()
    private let phoneLabel = UILabel()
    
    private let visitButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureData()
    }
    
    // MARK: - Setup 메서드
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // ScrollView 설정
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header 설정
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "홍익대학교"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .label
        
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        let heartImage = UIImage(systemName: "heart")?.withConfiguration(
          UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        )
        heartButton.setImage(heartImage, for: .normal)
        heartButton.tintColor = .systemPink
        heartButton.contentHorizontalAlignment = .trailing
        heartButton.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "서울시 서대문구 홍익로2길 홍익대학교 정문이 앞에 있는 다리예요"
        subtitleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = .byWordWrapping
        
        // 메인 이미지 설정
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.backgroundColor = .systemGray5
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 12
        mainImageView.image = UIImage(systemName: "building.2")
        mainImageView.tintColor = .systemGray3
        
        // 기본 정보 컨테이너 설정
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.backgroundColor = .systemBackground
        infoContainerView.layer.cornerRadius = 14
        infoContainerView.layer.shadowColor = UIColor.black.cgColor
        infoContainerView.layer.shadowOpacity = 0.1
        infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoContainerView.layer.shadowRadius = 8
        
        infoTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        infoTitleLabel.text = "기본 정보"
        infoTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        infoTitleLabel.textColor = .label
        
        // 지도 플레이스홀더 설정
        mapPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        mapPlaceholderView.backgroundColor = .systemGray6
        mapPlaceholderView.layer.cornerRadius = 8
        
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        mapImageView.image = UIImage(systemName: "map")
        mapImageView.tintColor = .systemBlue
        mapImageView.contentMode = .scaleAspectFit
        
        // 주소 컨테이너 설정
        addressContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addressIconImageView.translatesAutoresizingMaskIntoConstraints = false
        addressIconImageView.image = UIImage(systemName: "location")
        addressIconImageView.tintColor = .label
        addressIconImageView.contentMode = .scaleAspectFit
        
        addressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addressTitleLabel.text = "주소"
        addressTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        addressTitleLabel.textColor = .label
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = "서울특별시 마포구 와우산로 94"
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .secondaryLabel
        
        // 전화번호 컨테이너 설정
        phoneContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        phoneIconImageView.translatesAutoresizingMaskIntoConstraints = false
        phoneIconImageView.image = UIImage(systemName: "phone")
        phoneIconImageView.tintColor = .label
        phoneIconImageView.contentMode = .scaleAspectFit
        
        phoneTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneTitleLabel.text = "전화번호"
        phoneTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        phoneTitleLabel.textColor = .label
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.text = "02-320-1114"
        phoneLabel.font = .systemFont(ofSize: 14)
        phoneLabel.textColor = .secondaryLabel
        
        // 길찾기 버튼 설정
        visitButton.translatesAutoresizingMaskIntoConstraints = false
        visitButton.setTitle("길찾기", for: .normal)
        visitButton.backgroundColor = .systemBlue
        visitButton.setTitleColor(.white, for: .normal)
        visitButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        visitButton.layer.cornerRadius = 12
        
        // 서브뷰 추가
        contentView.addSubview(titleLabel)
        contentView.addSubview(heartButton)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(mainImageView)
        contentView.addSubview(infoContainerView)
        
        infoContainerView.addSubview(infoTitleLabel)
        infoContainerView.addSubview(mapPlaceholderView)
        infoContainerView.addSubview(addressContainerView)
        infoContainerView.addSubview(phoneContainerView)
        infoContainerView.addSubview(visitButton)
        
        mapPlaceholderView.addSubview(mapImageView)
        
        addressContainerView.addSubview(addressIconImageView)
        addressContainerView.addSubview(addressTitleLabel)
        addressContainerView.addSubview(addressLabel)
        
        phoneContainerView.addSubview(phoneIconImageView)
        phoneContainerView.addSubview(phoneTitleLabel)
        phoneContainerView.addSubview(phoneLabel)
    }
    
  // autolayout constaints
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
            
            // Map Placeholder
            mapPlaceholderView.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 16),
            mapPlaceholderView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: 20),
            mapPlaceholderView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -20),
            mapPlaceholderView.heightAnchor.constraint(equalToConstant: 120),
            
            // Map Image in Placeholder
            mapImageView.centerXAnchor.constraint(equalTo: mapPlaceholderView.centerXAnchor),
            mapImageView.centerYAnchor.constraint(equalTo: mapPlaceholderView.centerYAnchor),
            mapImageView.widthAnchor.constraint(equalToConstant: 40),
            mapImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Address Container
            addressContainerView.topAnchor.constraint(equalTo: mapPlaceholderView.bottomAnchor, constant: 20),
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
    
    private func configureData() {
        // 추후 실제 데이터로 교체할 부분
    }
    
    // MARK: - Actions
    @objc private func heartButtonTapped() {
      // 하트 버튼 애니메이션
          UIView.animate(withDuration: 0.1, animations: {
            self.heartButton.transform = CGAffineTransform(scaleX: 1.8, y: 1.8)
          }) { _ in
              UIView.animate(withDuration: 0.1) {
                  self.heartButton.transform = CGAffineTransform.identity
              }
          }
      
        // 하트 상태 변경
        let isSelected = heartButton.currentImage == UIImage(systemName: "heart.fill") // false
        let heartImage = isSelected ? "heart" : "heart.fill"
        let heartTabbed = UIImage(systemName: heartImage)?.withConfiguration(
              UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
          )
          heartButton.setImage(heartTabbed, for: .normal)
    }
    
    @objc private func findButtonTapped() {
        // 길찾기 버튼 액션
        print("길찾기 버튼 탭됨")
    }
}


// SwiftUI 프리뷰
struct PlaceInfo_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            PlaceInfo()
        }
        .previewDisplayName("HomeViewController")
        .previewDevice("iPhone 16 Pro")
    }
}

struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController
    
    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}

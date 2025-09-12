//
//  LikeModalViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/11/25.
//

import UIKit
import Navio
import Combine
import MapKit
import ToolBox

// MARK: - PlaceCardData
// 역할: 캐러셀(CollectionView)에 표시될 카드 하나의 데이터를 정의하는 모델
// Pinnable 프로토콜 채택
struct PlaceCardData: Pinnable {
    let imageName: String
    let title: String
    let subtitle: String?
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - 커스텀 캐러셀 셀
// 역할: UICollectionView 안에 들어갈 개별 카드 셀의 UI와 레이아웃을 정의
class PlaceCardCell: UICollectionViewCell {
  
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
  
    private let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
  
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.textAlignment = .right
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(placeImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
      
        // 오토레이아웃 설정
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            
            placeImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            placeImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            placeImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            placeImageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.65),
            
            titleLabel.topAnchor.constraint(equalTo: placeImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
    }
    
    // 외부에서 데이터를 받아 셀의 UI를 업데이트하는 함수
    func configure(with data: PlaceCardData) {
        placeImageView.image = UIImage(named: data.imageName) ?? UIImage(systemName: "photo.fill")
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
    }
}

// MARK: - Like 모달 뷰컨트롤러
// 역할: 'Like' 상태일 때 모달 컨테이너에 표시될 콘텐츠 ViewController
class LikeModalViewController: UIViewController {

    // MARK: - Properties
    let likeLabel: UILabel = {
        let label = UILabel()
        label.text = "Like"
        label.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let collectionView: UICollectionView
    
    let placeData = [
        PlaceCardData(imageName: "building.2.fill", title: "홍익대학교", subtitle: "서울특별시 마포구 와우산로 94", latitude: 37.5514, longitude: 126.9249),
        PlaceCardData(imageName: "building.columns.fill", title: "연세대학교", subtitle: "서울특별시 서대문구 연세로 50", latitude: 37.5658, longitude: 126.9386),
        PlaceCardData(imageName: "graduationcap.fill", title: "고려대학교", subtitle: "서울특별시 성북구 안암로 145", latitude: 37.5895, longitude: 127.0323),
        PlaceCardData(imageName: "book.fill", title: "서울대학교", subtitle: "서울특별시 관악구 관악로 1", latitude: 37.4598, longitude: 126.9519),
    ]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(likeLabel)
        view.addSubview(collectionView)
        
        // 오토레이아웃 설정
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            likeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            collectionView.topAnchor.constraint(equalTo: likeLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 220)
        ])
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCardCell.self, forCellWithReuseIdentifier: "PlaceCardCell")
    }
    
}

// MARK: - CollectionView DataSource & Delegate
extension LikeModalViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    // 셀 개수를 placeData 배열 크기만큼 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeData.count
    }
  
    // 각 셀을 PlaceCardCell로 구성하고 데이터를 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCardCell", for: indexPath) as! PlaceCardCell
        cell.configure(with: placeData[indexPath.item])
        return cell
    }
  
    // 셀 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.height - 20
        let cellWidth = cellHeight * (202.0 / 200.0)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

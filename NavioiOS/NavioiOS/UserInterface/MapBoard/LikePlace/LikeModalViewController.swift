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


// MARK: View
class PlaceCardCell: UICollectionViewCell {
    // MARK: body
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    private func setupUI() {
        // 계층 형성
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
    
    // 외부에서 데이터를 받아 셀의 UI를 업데이트하는 함수
    func configure(with likePlace: LikePlace) {
        placeImageView.image = likePlace.image
        titleLabel.text = likePlace.name
        subtitleLabel.text = likePlace.address
    }
}

// MARK: - Like 모달 뷰컨트롤러
class LikeModalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // MARK: core
    private let mapBoardRef: MapBoard
    
    init(_ object: MapBoard) {
        self.mapBoardRef = object

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    
    // MARK: body
    let collectionView: UICollectionView
    let likeLabel: UILabel = {
        let label = UILabel()
        label.text = "Like"
        label.font = UIFont.systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    
    // MARK: Helpher
    // 셀 개수를 placeData 배열 크기만큼 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapBoardRef.likePlaces.count
    }
  
    // 각 셀을 PlaceCardCell로 구성하고 데이터를 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PlaceCardCell",
            for: indexPath) as! PlaceCardCell
        
        cell.configure(with: mapBoardRef.likePlaces[indexPath.item])
        return cell
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let likePlace = mapBoardRef.likePlaces[indexPath.item]
        let coord = likePlace.location.toCLLocationCoordinate2D
        NotificationCenter.default.post(name: .mapShouldMoveToCoordinate, object: nil, userInfo: ["coordinate": coord])
    }
  
    // 셀 크기를 지정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.bounds.height - 20
        let cellWidth = cellHeight * (202.0 / 200.0)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

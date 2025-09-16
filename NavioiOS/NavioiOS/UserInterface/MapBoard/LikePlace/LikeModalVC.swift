//
//  LikeModalVC.swift
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


// MARK: - Like 모달 뷰컨트롤러
class LikeModalVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        label.text = "✨ Like"
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PlaceCardCell.self, forCellWithReuseIdentifier: "PlaceCardCell")
        collectionView.contentInset.bottom = 8
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
  
  // 지도이동 로직
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

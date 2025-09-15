//
//  SearchPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//
import UIKit
import Navio
import Combine
import ToolBox


// MARK: - SearchItemData
// 역할: '검색 결과' 목록의 테이블 뷰에 표시될 데이터 하나의 형태를 정의
struct SearchItemData {
  let imageName: String
  let title: String
  let subtitle: String
}


// MARK: - SearchPlaceModalViewController
class SearchPlaceModelVC: UIViewController {
    // MARK: core
    private let mapBoardRef: MapBoard
    private var cancellables = Set<AnyCancellable>()
    private var items: [SearchPlace] = []
    
    init(_ mapBoardRef: MapBoard) {
        self.mapBoardRef = mapBoardRef
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.separatorColor = .systemGray4
        tv.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 30)
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpBindings()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchListCell.self, forCellReuseIdentifier: "SearchListCell")
        
        view.addSubview(tableView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setUpBindings() {
        // MapBoard.searchPlaces 변경을 구독하여 셀 데이터 업데이트
        mapBoardRef.$searchPlaces
            .throttle(for: 0.3, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] places in
                guard let self = self else { return }
                self.items = places
                print("[SearchPlaceModelVC] list updated. count=\(self.items.count)")
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - TableView DataSource & Delegate
extension SearchPlaceModelVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as! SearchListCell
    cell.configure(with: items[indexPath.row])
      if let img = items[indexPath.row].image {
            let iv = cell.contentView.subviews.compactMap { $0 as? UIImageView }.first ?? cell.imageView
            iv?.image = img
            iv?.contentMode = .scaleAspectFill
            iv?.clipsToBounds = true
            cell.setNeedsLayout()
        }
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 탭된 아이템 가져오기
        let selectedPlace = items[indexPath.row]
        selectedPlace.save()
        
        let placeData = selectedPlace.placeData
        
        let homeBoardRef = mapBoardRef.owner.homeBoard!
        let sampleSpotRef = Spot(owner: homeBoardRef, data: .init(name: "", imageName: ""))
        
        let placeRef = Place(owner: sampleSpotRef, data: placeData)
        placeRef.customImage = selectedPlace.image
        
        // 이동할 VC 생성 (예: PlaceDetailViewController)
        let detailVC = PlaceVC(placeRef)
        
        // 네비게이션 컨트롤러가 있다면 push
        if let navigationController = self.navigationController {
            navigationController.pushViewController(detailVC, animated: true)
        } else {
            // 네비게이션 컨트롤러가 없다면 modal present
            detailVC.modalPresentationStyle = .automatic
            self.present(detailVC, animated: true, completion: nil)
        }
    }
}

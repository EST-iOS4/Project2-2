//
//  SearchPlaceViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//

import UIKit

// MARK: - SearchItemData
// 역할: '검색 결과' 목록의 테이블 뷰에 표시될 데이터 하나의 형태를 정의
struct SearchItemData {
  let imageName: String
  let title: String
  let subtitle: String
}


// MARK: - SearchPlaceModalViewController
class SearchPlaceModelVC: UIViewController {
    
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
    
    let searchData = [
        SearchItemData(imageName: "cup.and.saucer.fill", title: "스타벅스", subtitle: "영업중 • 리뷰 999+ • 크림라떼와 부드러운 에스프레소를 드립니다."),
        SearchItemData(imageName: "mug.fill", title: "커피빈", subtitle: "영업중 • 리뷰 850+ • 스페셜 커피 음료를 제공합니다."),
        SearchItemData(imageName: "takeoutbag.and.cup.and.straw.fill", title: "투썸플레이스", subtitle: "영업 중 • 리뷰 650+ • 디저트와 음료 전문"),
        SearchItemData(imageName: "cup.and.saucer", title: "폴바셋", subtitle: "영업 중 • 리뷰 420+ • 프리미엄 커피 체인")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
}

// MARK: - TableView DataSource & Delegate
extension SearchPlaceModelVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchListCell", for: indexPath) as! SearchListCell
    cell.configure(with: searchData[indexPath.row])
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }
}

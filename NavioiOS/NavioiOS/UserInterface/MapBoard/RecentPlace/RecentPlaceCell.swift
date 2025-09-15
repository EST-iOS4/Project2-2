//
//  RecentPlaceCell.swift
//  NavioiOS
//
//  Created by 김민우 on 9/15/25.
//


import Foundation
import UIKit
import Navio

class RecentPlaceCell: UITableViewCell {
  
    private let placeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.backgroundColor = .systemGray5
        iv.tintColor = .systemGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
  
    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    private func setupUI() {
        contentView.addSubview(placeImageView)
        contentView.addSubview(placeNameLabel)
        selectionStyle = .none
      
        // Auto Layout 정의
        NSLayoutConstraint.activate([
            placeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            placeImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeImageView.widthAnchor.constraint(equalToConstant: 40),
            placeImageView.heightAnchor.constraint(equalToConstant: 40),
        
            placeNameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 15),
            placeNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            placeNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
  
    // 외부에서 데이터를 받아 셀의 UI를 업데이트하는 메서드
    func configure(with data: RecentPlace) {
        placeImageView.image = UIImage(systemName: "clock")
        placeNameLabel.text = data.name
    }
}

//
//  SampleView.swift
//  ToolBoxTester
//
//  Created by 김민우 on 9/8/25.
//
import UIKit
import SwiftUI

struct CarouselCellData {
    let imageName: String //임시데이터
    let title: String
    let subtitle: String
}

class HardcodedUniversityCardCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let cardImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 34
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.numberOfLines = 1
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
        containerView.addSubview(cardImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        containerView.frame = CGRect(x: 0, y: 0, width: 202, height: 238)
        
        cardImageView.frame = CGRect(x: 0, y: 0, width: 202, height: 146)
        
      
        titleLabel.frame = CGRect(x: 18, y: 170, width: 166, height: 22)
        
        
        subtitleLabel.frame = CGRect(x: 18, y: 195, width: 166, height: 32)
    }
    
    func configure(with data: CarouselCellData) {
        cardImageView.image = UIImage(named: data.imageName) ?? UIImage(systemName: "photo.fill")
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
    }
}

// MARK: 프리뷰
struct HardcodedCardPreview: UIViewRepresentable {
    let data: CarouselCellData
    
    func makeUIView(context: Context) -> HardcodedUniversityCardCell {
        let cell = HardcodedUniversityCardCell(frame: CGRect(x: 0, y: 0, width: 200, height: 280))
        cell.configure(with: data)
        return cell
    }
    
    func updateUIView(_ uiView: HardcodedUniversityCardCell, context: Context) {
        uiView.configure(with: data)
    }
}

#Preview {
    VStack(spacing: 20) {
        HardcodedCardPreview(data: CarouselCellData(
            imageName: "building.2.fill",
            title: "홍익대학교",
            subtitle: "서울특별시 마포구 와우산로 94"
        ))
        .frame(width: 202, height: 238)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

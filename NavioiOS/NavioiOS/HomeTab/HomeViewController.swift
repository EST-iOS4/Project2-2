//
//  HomeViewController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {

  // MARK: - UI 요소
  private let ScrollView = UIScrollView()
  private let contentView = UIView()
  
  private let NavioLabel = UILabel()
  private let titleLabel = UILabel()
  
  
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Home"
    }
  
}

// SwiftUI 프리뷰
struct HomeViewController_Preview: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreview {
            HomeViewController()
        }
        .previewDisplayName("HomeViewController")
        .previewDevice("iPhone 16 Pro")
    }
}

struct UIPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
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


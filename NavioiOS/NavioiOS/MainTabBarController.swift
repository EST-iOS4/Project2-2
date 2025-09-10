//
//  MainTabBarController.swift
//  NavioiOS
//
//  Created by EunYoung Wang on 9/9/25.
//

import UIKit
import Navio
import Combine
import MapKit
import ToolBox

// MARK: - 메인 TabBarController
class MainTabBarController: UITabBarController {
    
    private let mapBoard: MapBoard
    private let setting: Setting
    
    init(mapBoard: MapBoard, setting: Setting) {
        self.mapBoard = mapBoard
        self.setting = setting
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 사용하지 않습니다.") // Storyboard 사용 안 함
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let HomeVC = HomeViewController()
        let mapBoardVC = MapViewController(mapBoard: mapBoard)
        let settingVC = SettingController(settingRef: self.setting)
        let settingNav = UINavigationController(rootViewController: settingVC)
        
        HomeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        mapBoardVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        settingNav.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gearshape"), tag: 2)
        
        viewControllers = [HomeVC, mapBoardVC, settingVC]
    }
}

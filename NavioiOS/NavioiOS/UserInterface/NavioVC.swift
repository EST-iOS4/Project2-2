//
//  MainTabBarController.swift
//  NavioiOS
//
//  Created by EunYoung Wang, 구현모 on 9/10/25.
//
import UIKit
import Navio
import Combine
import MapKit
import ToolBox


// MARK: ViewController
class NavioVC: UITabBarController {
    // MARK: core
    private let navioRef: Navio = Navio()
    init() {
        navioRef.setUp()
        
        navioRef.homeBoard!
            .spots
            .forEach {
                $0.places
                    .forEach {
                        $0.fetchFromDB()
                    }
            }
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 사용하지 않습니다.") // Storyboard 사용 안 함
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // HomeBoard의 UI
        let HomeVC = HomeVC(navioRef.homeBoard!)
        let homeNav = UINavigationController(rootViewController: HomeVC)
      
        // MapBoard의 UI
        let mapBoardVC = MapBoardVC(navioRef.mapBoard!)
        
        // Setting의 UI
        let settingVC = SettingVC(settingRef: navioRef.setting!)
        let settingNav = UINavigationController(rootViewController: settingVC)
        
        // Navio의 UI
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        mapBoardVC.tabBarItem = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), tag: 1)
        settingNav.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 2)
        
        self.viewControllers = [homeNav, mapBoardVC, settingNav]
    }
}

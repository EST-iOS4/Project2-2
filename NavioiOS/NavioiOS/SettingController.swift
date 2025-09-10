//
//  SettingController.swift
//  NavioiOS
//
//  Created by 김민우 on 9/5/25.
//
import UIKit
import Navio


final class SettingController: UIViewController {
    private let settingRef: Setting
    init(settingRef: Setting) {
        self.settingRef = settingRef
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 사용하지 않습니다.") // Storyboard 사용 안 함
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Setting"
    }
}

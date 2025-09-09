//
//  ViewController.swift
//  NavioiOS
//
//  Created by 김민우 on 9/4/25.
//
import UIKit
import Navio
import Combine
import ToolBox


class ViewController: UIViewController {
    private let navio = Navio()
    private var cancellables = Set<AnyCancellable>()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "권한 확인 중"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let coordLabel: UILabel = {
        let label = UILabel()
        label.text = "위도: -, 경도: -"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sampleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sample Button", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(statusLabel)
        view.addSubview(coordLabel)
        view.addSubview(sampleButton)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            coordLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            coordLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            coordLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor),

            sampleButton.topAnchor.constraint(equalTo: coordLabel.bottomAnchor, constant: 20),
            sampleButton.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            sampleButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        sampleButton.addTarget(self, action: #selector(handleSampleButtonTap), for: .touchUpInside)

        // currentLocation 관찰
        navio.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                if let location = location {
                    self?.statusLabel.text = "위치 업데이트 완료"
                    self?.coordLabel.text = "위도: \(location.latitude), 경도: \(location.longitude)"
                } else {
                    self?.statusLabel.text = "권한 확인 중"
                    self?.coordLabel.text = "위도: -, 경도: -"
                }
            }
            .store(in: &cancellables)
        
        
        // setting 관찰
        navio.$setting
            .sink { newSetting in
                // Setting을 볼 수 있는 Controller를 추가하는 로직
                guard let settingRef = newSetting?.ref else {
                    return
                }
                
                let settingViewController = SettingViewController(settingRef: settingRef)
                settingViewController.modalPresentationStyle = .pageSheet
                
                if let sheet = settingViewController.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
                
                self.present(settingViewController, animated: true)
            }
            .store(in: &cancellables)

        Task {
            await navio.startUpdating()
            updateSampleButtonTitle()
        }
    }

    @objc
    private func handleSampleButtonTap() {
        Task {
            await navio.showSetting()
        }
    }

    @MainActor
    private func updateSampleButtonTitle() {
        sampleButton.setTitle("ShowSetting", for: .normal)
    }
}


#Preview {
    ViewController()
}

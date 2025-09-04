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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        view.addSubview(statusLabel)
        view.addSubview(coordLabel)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            coordLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            coordLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            coordLabel.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor)
        ])

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

        Task {
            await navio.startUpdating()
        }
    }
}

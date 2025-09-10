//
//  SettingViewController.swift
//  NavioiOS
//
//  Created by 구현모 on 9/10/25.
//
import UIKit
import Navio
import Combine


final class SettingViewController: UIViewController {
    private let settingRef: Setting
    private var cancellables = Set<AnyCancellable>()
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let keywordSwitch = UISwitch()
    
    init(settingRef: Setting) {
        self.settingRef = settingRef
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:)는 사용하지 않습니다.") // Storyboard 사용 안 함
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
        
        settingRef.load()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        self.title = "설정"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        keywordSwitch.addTarget(self, action: #selector(keywordSwitchChanged), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindViewModel() {
        settingRef.$displayMode
            .sink { [weak self] mode in
                self?.tableView.reloadData()
                self?.updateInterfaceStyle(for: mode)
            }
            .store(in: &cancellables)
        
        settingRef.$collectKeyword
            .sink { [weak self] isOn in
                self?.keywordSwitch.setOn(isOn, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func keywordSwitchChanged(_ sender: UISwitch) {
        settingRef.collectKeyword = sender.isOn
        settingRef.save()
    }
    
    private func presentDarkModeActionSheet() {
        let alert = UIAlertController(title: "다크 모드 설정", message: nil, preferredStyle: .actionSheet)
        
        let systemAction = UIAlertAction(title: "시스템 설정에 따름", style: .default) { _ in
            self.settingRef.displayMode = .system
            self.settingRef.save()
        }
        let lightAction = UIAlertAction(title: "라이트 모드", style: .default) { _ in
            self.settingRef.displayMode = .light
            self.settingRef.save()
        }
        let darkAction = UIAlertAction(title: "다크 모드", style: .default) { _ in
            self.settingRef.displayMode = .dark
            self.settingRef.save()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(systemAction)
        alert.addAction(lightAction)
        alert.addAction(darkAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func updateInterfaceStyle(for mode: Setting.DisplayMode) {
        guard let window = view.window else { return }
        switch mode {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "설정"
        } else {
            return "개인정보 보호"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "테마"
            switch settingRef.displayMode {
                case .light:
                    cell.detailTextLabel?.text = "라이트 모드"
                case .dark:
                    cell.detailTextLabel?.text = "다크 모드"
                case .system:
                    cell.detailTextLabel?.text = "시스템 설정"
            }
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "키워드 수집"
            cell.accessoryView = keywordSwitch
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            presentDarkModeActionSheet()
        }
    }
}
            

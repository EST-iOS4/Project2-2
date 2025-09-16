//
//  SettingVC.swift
//  NavioiOS
//
//  Created by 구현모 on 9/10/25.
//
import UIKit
import Navio
import Combine


// ===== 지도 앱 선택 전역 정의
enum PreferredMapApp: String, CaseIterable {
    case apple, naver, kakao, google
    var title: String {
        switch self {
        case .apple:  return "Apple 지도"
        case .naver:  return "네이버 지도"
        case .kakao:  return "카카오맵"
        case .google: return "Google 지도"
        }
    }
}

enum MapPrefStore {
    static let key = "NAVIO_PREFERRED_MAP_APP"
    static func get() -> PreferredMapApp {
        let raw = UserDefaults.standard.string(forKey: key) ?? "apple"
        return PreferredMapApp(rawValue: raw) ?? .apple
    }
    static func set(_ v: PreferredMapApp) {
        UserDefaults.standard.set(v.rawValue, forKey: key)
        NotificationCenter.default.post(name: .preferredMapAppDidChange,
                                        object: nil,
                                        userInfo: ["value": v.rawValue])
    }
}

extension Notification.Name {
    static let preferredMapAppDidChange = Notification.Name("PreferredMapAppDidChange")
}


// MARK: - SettingVC
final class SettingVC: UIViewController {
    
    // MARK: - Properties
    private let settingRef: Setting
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    // '키워드 수집' 항목의 On/Off 스위치
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
        // 화면이 로드될 때 UserDefaults에 저장된 설정값을 불러오기
        settingRef.load()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        self.title = "설정"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 스위치의 값이 변경될 때마다 keywordSwitchChanged 함수가 호출되도록 연결
        keywordSwitch.addTarget(self, action: #selector(keywordSwitchChanged), for: .valueChanged)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    // Combine을 사용해 ViewModel의 데이터 변경을 UI에 자동으로 반영
    private func bindViewModel() {
        // ViewModel의 displayMode가 바뀌면 UI를 업데이트
        settingRef.$displayMode
            .sink { [weak self] mode in
                self?.tableView.reloadData()
                // 앱 전체의 테마를 변경
                self?.updateInterfaceStyle(for: mode)
            }
            .store(in: &cancellables)
        
        // ViewModel의 collectKeyword가 바뀌면 스위치의 On/Off 상태를 업데이트
        settingRef.$collectKeyword
            .sink { [weak self] isOn in
                self?.keywordSwitch.setOn(isOn, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func currentMapAppDisplay() -> String {
        switch MapPrefStore.get() {
        case .apple:  return "Apple 지도"
        case .naver:  return "네이버 지도"
        case .kakao:  return "카카오맵"
        case .google: return "Google 지도"
        }
    }
    
    private func presentMapAppPicker() {
        let current = MapPrefStore.get()
        let sheet = UIAlertController(title: "지도", message: nil, preferredStyle: .actionSheet)
        PreferredMapApp.allCases.forEach { opt in
            let title = opt.title + (opt == current ? " ✓" : "")
            sheet.addAction(UIAlertAction(title: title, style: .default) { _ in
                MapPrefStore.set(opt)
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            })
        }
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(sheet, animated: true)
    }
    
    // '키워드 수집' 스위치를 탭했을 때 호출
    @objc private func keywordSwitchChanged(_ sender: UISwitch) {
        // UI에서 발생한 이벤트를 ViewModel에 전달
        settingRef.collectKeyword = sender.isOn
        // 변경된 내용을 UserDefaults에 저장
        settingRef.save()
    }
    
    // '다크 모드' 셀을 탭했을 때 선택 옵션을 띄우기
    private func presentDarkModeActionSheet() {
        let alert = UIAlertController(title: "다크 모드 설정", message: nil, preferredStyle: .actionSheet)
        
        // 각 액션을 탭하면 ViewModel의 displayMode 값을 변경하고 저장
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
    
    // 앱 창의 라이트/다크 모드를 실제로 변경하는 함수
    private func updateInterfaceStyle(for mode: Setting.DisplayMode) {
        // 앱의 window에 접근하여 전체 스타일을 변경
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
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // 섹션0,row1 == "지도" 셀만 갱신 (없으면 전체 리로드)
            if tableView.numberOfSections > 0 && tableView.numberOfRows(inSection: 0) > 1 {
                tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            } else {
                tableView.reloadData()
            }
        }
}

extension SettingVC: UITableViewDataSource, UITableViewDelegate {
    
    // 섹션의 개수를 반환
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // 각 섹션의 행(row) 개수를 반환
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 2 : 1
    }
    
    // 각 섹션의 제목을 반환
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "설정"
        } else {
            return "개인정보 보호"
        }
    }
    
    // 각 행에 표시될 셀을 생성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            if indexPath.row == 0 {
                cell.textLabel?.text = "테마"
                switch settingRef.displayMode {
                case .light:  cell.detailTextLabel?.text = "라이트 모드"
                case .dark:   cell.detailTextLabel?.text = "다크 모드"
                case .system: cell.detailTextLabel?.text = "시스템 설정"
                }
            } else {
                cell.textLabel?.text = "지도"      // ← 여기서 지도 셀 표시
                cell.detailTextLabel?.text = currentMapAppDisplay()
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "키워드 수집"
        cell.accessoryView = keywordSwitch
        cell.selectionStyle = .none
        return cell
    }

    
    // 특정 행을 탭했을 때의 동작을 정의
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                presentDarkModeActionSheet()
            } else {
                presentMapAppPicker()
            }
        }
    }

}
            

//
//  MapAppPickerVC.swift
//  NavioiOS
//
//  Created by 송영민 on 9/15/25.
//

import UIKit

// 앱 전역에서 쓸 키와 옵션
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
        NotificationCenter.default.post(name: .preferredMapAppDidChange, object: nil, userInfo: ["value": v.rawValue])
    }
}
extension Notification.Name {
    static let preferredMapAppDidChange = Notification.Name("PreferredMapAppDidChange")
}

final class MapAppPickerVC: UITableViewController {
    private let options: [PreferredMapApp] = [.apple, .naver, .kakao, .google]
    private var current = MapPrefStore.get()

    init() {
        super.init(style: .insetGrouped)
        self.title = "지도"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        current = MapPrefStore.get()
        tableView.reloadData()
    }

    // MARK: Table
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { options.count }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let opt = options[indexPath.row]
        cell.textLabel?.text = opt.title
        cell.accessoryType = (opt == current) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sel = options[indexPath.row]
        MapPrefStore.set(sel)
        navigationController?.popViewController(animated: true)
    }
}

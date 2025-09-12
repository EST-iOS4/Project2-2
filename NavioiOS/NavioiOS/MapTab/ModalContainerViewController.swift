//
//  ModalContainerViewController.swift
//  NavioiOS
//
//  Created by 구현모 on 9/11/25.
//

import UIKit
import Combine

final class ModalContainerViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "검색하기"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var currentContentVC: UIViewController?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
        showInitialContent()
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Setup & Binding
    private func setupUI() {
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        view.addSubview(searchBar)
        view.addSubview(contentContainerView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            contentContainerView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBinding() {
        // 검색창 텍스트가 변경될 때마다 이벤트를 받습니다.
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchBar.searchTextField)
            .compactMap { ($0.object as? UISearchTextField)?.text }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.handleSearchQueryChanged(query: text)
            }
            .store(in: &cancellables)
    }

    // MARK: - Content Transition & Logic
    private func showInitialContent() {
        let initialVC = LikeModalViewController()
        transition(to: initialVC, animated: false)
    }
    
    private func handleSearchQueryChanged(query: String) {
        guard currentContentVC is RecentPlaceViewController || currentContentVC is SearchPlaceModalViewController else { return }
        
        if query.isEmpty {
            // 검색어가 비었으면 -> RecentView로
            if !(currentContentVC is RecentPlaceViewController) {
                transition(to: RecentPlaceViewController())
            }
        } else {
            // 검색어가 있으면 -> SearchView로
            if !(currentContentVC is SearchPlaceModalViewController) {
                transition(to: SearchPlaceModalViewController())
            }
            // TODO: SearchPlaceModalViewController에 검색어(query) 전달 로직 추가
        }
    }

    // 자식 뷰 컨트롤러를 교체하는 함수
    private func transition(to newContentVC: UIViewController, animated: Bool = true) {
        let oldVC = currentContentVC
        oldVC?.willMove(toParent: nil)
        
        addChild(newContentVC)
        contentContainerView.addSubview(newContentVC.view)
        newContentVC.view.frame = contentContainerView.bounds
        newContentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if animated, let oldView = oldVC?.view, let newView = newContentVC.view {
            UIView.transition(from: oldView, to: newView, duration: 0.2, options: .transitionCrossDissolve) { _ in
                oldVC?.removeFromParent()
                newContentVC.didMove(toParent: self)
                self.currentContentVC = newContentVC
            }
        } else {
            oldVC?.view.removeFromSuperview()
            oldVC?.removeFromParent()
            newContentVC.didMove(toParent: self)
            self.currentContentVC = newContentVC
        }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 검색창 탭이 시작될 때 전환
        if currentContentVC is LikeModalViewController {
            transition(to: RecentPlaceViewController())
        }
        return true
    }
}

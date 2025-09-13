//
//  ModalContainerViewController.swift
//  NavioiOS
//
//  Created by 구현모 on 9/11/25.
//
import UIKit
import Combine
import Navio


// MARK: - ModalContainerViewController
// 역할: 모달들의 '껍데기' 역할. 내부 컨텐츠(자식 ViewController)를 관리하고 교체
final class ModalContainerViewController: UIViewController, UISearchBarDelegate {
    
    private let mapBoardRef: MapBoard
    init(_ object: MapBoard) {
        self.mapBoardRef = object
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    // 검색창은 모든 자식 VC들이 공유해서 사용합니다
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "검색하기"
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // 자식 VC들이 표시될 컨테이너 뷰
    private let contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 현재 표시 중인 자식 뷰 컨트롤러
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
        
        // Auto Layout 설정
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
            .compactMap { ($0.object as? UISearchTextField)?.text } // 텍스트만 추출
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main) // 타이핑을 멈추면 300ms 후에 처리
            .sink { [weak self] text in
                self?.handleSearchQueryChanged(query: text) // 텍스트가 바뀔 때마다 처리
            }
            .store(in: &cancellables)
    }

    // MARK: - Content Transition & Logic
    
    // 모달이 처음 나타날 때 보여줄 초기 화면 설정
    private func showInitialContent() {
        let initialVC = LikeModalViewController(mapBoardRef)
        transition(to: initialVC, animated: false)
    }
    
    // 검색어 변경에 따른 화면 전환 로직
    private func handleSearchQueryChanged(query: String) {
        // 사용자가 타이핑하는 동안에만 화면 전환 로직이 작동하도록 제한
        guard currentContentVC is RecentPlaceModalViewController || currentContentVC is SearchPlaceModalViewController else { return }
        
        if query.isEmpty {
            // 검색어가 비었으면 -> RecentView로
            if !(currentContentVC is RecentPlaceModalViewController) {
                transition(to: RecentPlaceModalViewController())
            }
        } else {
            // 검색어가 있으면 -> SearchView로
            if !(currentContentVC is SearchPlaceModalViewController) {
                transition(to: SearchPlaceModalViewController())
                
                // TODO: SearchPlaceModalViewController에 검색어(query) 전달 로직 추가 필요
            }
        }
    }

    // 자식 뷰 컨트롤러를 교체하는 함수
    private func transition(to newContentVC: UIViewController, animated: Bool = true) {
        let oldVC = currentContentVC
        oldVC?.willMove(toParent: nil)
        
        // 새로운 자식 뷰 컨트롤러 추가
        addChild(newContentVC)
        contentContainerView.addSubview(newContentVC.view)
        newContentVC.view.frame = contentContainerView.bounds
        newContentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 애니메이션과 함께 뷰 교체
        if animated, let oldView = oldVC?.view, let newView = newContentVC.view {
            UIView.transition(from: oldView, to: newView, duration: 0.2, options: .transitionCrossDissolve) { _ in
                // 기존 자식 뷰 컨트롤러 제거
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
    // 사용자가 검색창을 터치해서 편집을 시작할 때 호출
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // 현재 화면이 LikeModalViewController라면 RecentPlaceViewController로 전환
        if currentContentVC is LikeModalViewController {
            transition(to: RecentPlaceModalViewController())
        }
        return true // 키보드가 나타나도록 허용
    }
}

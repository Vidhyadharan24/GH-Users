//
//  UsersListViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit
import Combine

class UsersListViewController: UIViewController {

    private let viewModel: UsersListViewModelProtocol
    
    private var searchBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var offlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed
        return view
    }()
    
    private lazy var offlineLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.offlineErrorMessage
        view.textColor = UIColor.white
        view.textAlignment = .center
        return view
    }()

    private var offlineViewTopConstraint: NSLayoutConstraint?
    
    private lazy var usersListContainer: UIView = {
        return UIView()
    }()
    private(set) lazy var usersSearchContainer: UIView = {
        return UIView()
    }()

    private lazy var usersTableViewController = UsersListTableViewController(viewModel: viewModel)
    var usersSearchTableViewController: UsersSearchTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.text = viewModel.emptyDataTitle
        return view
    }()
    
    private var cancellableSet: Set<AnyCancellable> = []

    static func create(viewModel: UsersListViewModelProtocol) -> UsersListViewController {
        let controller = UsersListViewController(viewModel: viewModel)
        return controller
    }
        
    private init(viewModel: UsersListViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = setUpRootView()
        self.view.layoutIfNeeded()
    }
    
    private func setUpRootView() -> UIView {
        let rootView = UIView();
        rootView.backgroundColor = UIColor.systemBackground

        offlineView.addSubview(offlineLabel)
        rootView.addSubview(offlineView)
        rootView.addSubview(searchBarContainer)
        rootView.addSubview(usersListContainer)
        rootView.addSubview(errorLabel)
        rootView.addSubview(usersSearchContainer)

        
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            searchBarContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            searchBarContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        offlineLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offlineLabel.topAnchor.constraint(equalTo: offlineView.topAnchor),
            offlineLabel.leadingAnchor.constraint(equalTo: offlineView.leadingAnchor),
            offlineLabel.trailingAnchor.constraint(equalTo: offlineView.trailingAnchor),
            offlineLabel.bottomAnchor.constraint(equalTo: offlineView.bottomAnchor)
        ])
        
        offlineView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = offlineView.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor)
        topConstraint.priority = .defaultLow
        offlineViewTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            topConstraint,
            offlineView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            offlineView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            offlineView.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            searchBarContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            searchBarContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 56)
        ])
                
        usersListContainer.translatesAutoresizingMaskIntoConstraints = false
        let topAnchor = usersListContainer.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor)
        topAnchor.priority = .defaultHigh
        NSLayoutConstraint.activate([
            topAnchor,
            usersListContainer.topAnchor.constraint(equalTo: offlineView.bottomAnchor),
            usersListContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            usersListContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            usersListContainer.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        ])
        add(child: usersTableViewController, container: usersListContainer)
        
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.centerYAnchor.constraint(equalTo: usersListContainer.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 8),
            errorLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: 8),
        ])
        
        usersSearchContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usersSearchContainer.topAnchor.constraint(equalTo: usersListContainer.topAnchor),
            usersSearchContainer.leadingAnchor.constraint(equalTo: usersListContainer.leadingAnchor),
            usersSearchContainer.trailingAnchor.constraint(equalTo: usersListContainer.trailingAnchor),
            usersSearchContainer.bottomAnchor.constraint(equalTo: usersListContainer.bottomAnchor)
        ])
        
        usersSearchContainer.isHidden = true
        
        return rootView
    }
    
}

extension UsersListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = !(self.navigationController?.navigationBar.isTranslucent ?? false);

        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    private func setupViews() {
        title = viewModel.screenTitle
        offlineLabel.text = viewModel.offlineErrorMessage
        
        setupSearchController()
    }

    private func bind(to viewModel: UsersListViewModelProtocol) {
        viewModel.userViewModels.sink { [weak self] _ in self?.updateItems() }.store(in: &cancellableSet)
        viewModel.loading.sink { [weak self] in self?.updateLoading($0) }.store(in: &cancellableSet)
        viewModel.error.sink { [weak self] in self?.showError($0) }.store(in: &cancellableSet)
        viewModel.offline.sink { [weak self] in self?.showHideOfflineView($0) }.store(in: &cancellableSet)
    }
    
    private func updateItems() {
        usersTableViewController.reload()
    }
    
    private func updateLoading(_ loading: UsersListViewModelLoading?) {
        errorLabel.isHidden = true

        switch loading {
        case .fullScreen: usersListContainer.isHidden = false
        case .nextPage: usersListContainer.isHidden = false
        case .none:
            usersListContainer.isHidden = viewModel.isEmpty
            errorLabel.isHidden = !viewModel.isEmpty
        }

        usersTableViewController.updateLoading(loading)
    }
    
    private func showError(_ error: String?) {
        guard let error = error, !error.isEmpty, viewModel.userViewModels.value.count == 0 else { return }
        self.errorLabel.text = error
//        showAlert(title: viewModel.errorTitle, message: error)
    }
    
    private func showHideOfflineView(_ offline: Bool)  {
        if (offline) {
            offlineViewTopConstraint?.priority = UILayoutPriority(999)
        } else {
            offlineViewTopConstraint?.priority = .defaultLow
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Search Controller

extension UsersListViewController {
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = viewModel.searchBarPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
        searchController.searchBar.barStyle = .default
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
    }
}

extension UsersListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        usersSearchTableViewController?.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        usersSearchTableViewController?.didCancelSearch()
    }
}

extension UsersListViewController: UISearchControllerDelegate {
    private func updateLocalSearch() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeLocalUserSearch()
            return
        }
        viewModel.showLocalUserSearch()
    }
    
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateLocalSearch()
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
        updateLocalSearch()
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
        updateLocalSearch()
    }
}

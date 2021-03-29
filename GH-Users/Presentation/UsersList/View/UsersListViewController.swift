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
    private let imageRepository: ImageRepositoryProtocol
    
    private var searchBarContainer: UIView!
    private var usersListContainer: UIView!
    private(set) var usersSearchContainer: UIView!

    private lazy var usersTableViewController = UsersListTableViewController(viewModel: viewModel)
    var usersSearchTableViewController: UsersSearchTableViewController?
    private var searchController = UISearchController(searchResultsController: nil)
    
    private var emptyDataLabel: UILabel! {
        didSet {
            emptyDataLabel.textAlignment = .center
        }
    }
    
    private var cancellableSet: Set<AnyCancellable> = []

    static func create(viewModel: UsersListViewModelProtocol, imageRepository: ImageRepositoryProtocol) -> UsersListViewController {
        let controller = UsersListViewController(viewModel: viewModel, imageRepository: imageRepository)
        return controller
    }
        
    private init(viewModel: UsersListViewModelProtocol, imageRepository: ImageRepositoryProtocol) {
        self.viewModel = viewModel
        self.imageRepository = imageRepository
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = setUpRootView()
    }
    
    private func setUpRootView() -> UIView {
        let rootView = UIView();
        rootView.backgroundColor = UIColor.systemBackground
        
        searchBarContainer = UIView()
        rootView.addSubview(searchBarContainer)
        
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarContainer.topAnchor.constraint(equalTo: rootView.safeAreaLayoutGuide.topAnchor),
            searchBarContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            searchBarContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            searchBarContainer.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        usersListContainer = UIView()
        rootView.addSubview(usersListContainer)
        
        usersListContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usersListContainer.topAnchor.constraint(equalTo: searchBarContainer.bottomAnchor),
            usersListContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            usersListContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
            usersListContainer.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        ])
        add(child: usersTableViewController, container: usersListContainer)
        
        emptyDataLabel = UILabel()
        rootView.addSubview(emptyDataLabel)
        
        emptyDataLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyDataLabel.centerYAnchor.constraint(equalTo: usersListContainer.centerYAnchor),
            emptyDataLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 8),
            emptyDataLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: 8),
        ])
        
        usersSearchContainer = UIView()
        rootView.addSubview(usersSearchContainer)
        
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
        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    private func setupViews() {
        title = viewModel.screenTitle
        emptyDataLabel.text = viewModel.emptyDataTitle
        setupSearchController()
    }

    private func bind(to viewModel: UsersListViewModelProtocol) {
        viewModel.userViewModels.sink { [weak self] _ in self?.updateItems() }.store(in: &cancellableSet)
        viewModel.loading.sink { [weak self] in self?.updateLoading($0) }.store(in: &cancellableSet)
        viewModel.error.sink { [weak self] in self?.showError($0) }.store(in: &cancellableSet)
    }
    
    private func updateItems() {
        usersTableViewController.reload()
    }
    
    private func updateLoading(_ loading: UsersListViewModelLoading?) {
        emptyDataLabel.isHidden = true
        usersListContainer.isHidden = true
        LoadingView.hide()

        switch loading {
        case .fullScreen: LoadingView.show()
        case .nextPage: usersListContainer.isHidden = false
        case .none:
            usersListContainer.isHidden = viewModel.isEmpty
            emptyDataLabel.isHidden = !viewModel.isEmpty
        }

        usersTableViewController.updateLoading(loading)
    }
    
    private func updateQueriesSuggestions() {
        guard searchController.searchBar.isFirstResponder else {
            viewModel.closeLocalUserSearch()
            return
        }
        viewModel.showLocalUserSearch()
    }
    
    private func showError(_ error: String?) {
        guard let error = error, !error.isEmpty else { return }
//        showAlert(title: viewModel.errorTitle, message: error)
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
        searchController.isActive = false
        usersSearchContainer.isHidden = false
        usersSearchTableViewController?.didSearch(query: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        usersSearchTableViewController?.didCancelSearch()
    }
}

extension UsersListViewController: UISearchControllerDelegate {
    public func willPresentSearchController(_ searchController: UISearchController) {
        updateQueriesSuggestions()
    }

    public func willDismissSearchController(_ searchController: UISearchController) {
    }

    public func didDismissSearchController(_ searchController: UISearchController) {
    }
}

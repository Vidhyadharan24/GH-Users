//
//  UsersListViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import Foundation
import Combine
import Reachability

struct UsersListViewModelActions {
    let showUserDetails: (UserEntity, @escaping () -> Void) -> Void
    let showLocalUserSearch: () -> Void
    let closeLocalUserSearch: () -> Void
}

struct UsersSince {
    let since: Int
    let users: [UserEntity]
}

enum UsersListViewModelLoading {
    case fullScreen
    case nextPage
}

enum UsersListDataType {
    case cached
    case live
}

protocol UsersListViewModelInputProtocol {
    func viewDidLoad()
    func didLoadNextPage()
    func showLocalUserSearch()
    func closeLocalUserSearch()
    func didSelectItem(at index: Int)
}

protocol UsersListViewModelOutputProtocol {
    var userViewModels: CurrentValueSubject<[UserListCellViewModelProtocol], Never> { get }
    var loading: CurrentValueSubject<UsersListViewModelLoading?, Never> { get }
    var dataType: CurrentValueSubject<UsersListDataType, Never> { get }
    var error: PassthroughSubject<String?, Never> { get }
    var offline: CurrentValueSubject<Bool, Never> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
    var offlineErrorMessage: String { get }

}

protocol UsersListViewModelProtocol: UsersListViewModelInputProtocol, UsersListViewModelOutputProtocol {}

// BONUS TASK: Coordinator and/or MVVM patterns are used.
class UsersListViewModel: UsersListViewModelProtocol {

    let respository: UsersListRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    let actions: UsersListViewModelActions?
    
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }
    private var cancellableSet = Set<AnyCancellable>()

    private var pages: [UsersSince] = []
    private var users: [UserEntity] = []
    private(set) var userViewModels = CurrentValueSubject<[UserListCellViewModelProtocol], Never>([])
    private(set) var loading = CurrentValueSubject<UsersListViewModelLoading?, Never>(.none)
    private(set) var dataType = CurrentValueSubject<UsersListDataType, Never>(.live)
    private(set) var error = PassthroughSubject<String?, Never>()
    private(set) var offline = CurrentValueSubject<Bool, Never>(false)
    var isEmpty: Bool { return userViewModels.value.isEmpty }
    let screenTitle = NSLocalizedString("Users", comment: "")
    let emptyDataTitle = NSLocalizedString("Unable to retrive users", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Users", comment: "")
    let offlineErrorMessage = NSLocalizedString("Offline", comment: "")

    init(repository: UsersListRepositoryProtocol, imageRepository: ImageRepositoryProtocol, actions: UsersListViewModelActions?) {
        self.respository = repository
        self.actions = actions
        self.imageRepository = imageRepository
    }
    
    deinit {
        usersLoadTask?.cancel()
    }
    
    private func reloadIfRequired() {
        guard isEmpty else { return }
        load(since: 0, loading: .fullScreen)
    }
    
    func viewDidLoad() {
        setupObservers()
        load(since: 0, loading: .fullScreen)
    }
    
    func setupObservers() {
        // REQUIRED TASK: The app must ​automatically​ retry loading data once the connection is available.
        NotificationCenter.default.publisher(for: .reachabilityChanged, object: nil)
            .sink {[weak self] (note) in
                let reachability = note.object as! Reachability

                switch reachability.connection {
                case .wifi, .cellular:
                    self?.offline.send(false)
                    self?.reloadIfRequired()
                case .unavailable, .none:
                  print("Network not reachable")
                }
            }.store(in: &cancellableSet)
    }
    
    // REQUIRED TASK: The list must support pagination (​scroll to load more​) utilizing ​since p​ arameter as the integer ID of the last User loaded.
    func didLoadNextPage() {
        let lastUserId = Int(users.last?.id ?? 0)
        load(since: lastUserId, loading: .nextPage)
    }
    
    func showLocalUserSearch() {
        actions?.showLocalUserSearch()
    }
    
    func closeLocalUserSearch() {
        actions?.closeLocalUserSearch()
    }
    
    func didSelectItem(at index: Int) {
        let users = pages.flatMap { $0.users }
        actions?.showUserDetails(users[index]) {[weak self] in
            // Reloading on return from User Details Page
            guard let self = self else { return }
            self.userViewModels.send(self.userViewModels.value)
        }
    }
}

extension UsersListViewModel {
    // MARK: - Private

    private func appendPage(since: Int, response: [UserEntity]) {
        pages = pages
            .filter { $0.since != since }
            + [UsersSince(since: since, users: response)]

        users = pages.flatMap { $0.users }.sorted {Int($0.id) < Int($1.id)}
        userViewModels.send(users.map {(user) in UserListCellViewModel(user: user, imageRepository: imageRepository)})
    }

    private func resetPages() {
        pages.removeAll()
        users.removeAll()
        userViewModels.send([])
    }

    private func load(since: Int, loading: UsersListViewModelLoading) {
        guard self.loading.value == .none else { return }
        self.loading.send(loading)

        usersLoadTask = respository.fetchUsersList(since: since, cached: {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let page):
                self.appendPage(since: since, response: page)
                self.dataType.send(.cached)
                self.loading.send(.none)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, completion: { (result) in
            switch result {
            case .success(let page):
                self.appendPage(since: since, response: page)
                self.dataType.send(.live)
            case .failure(let error):
                self.handle(error: error)
            }
            self.loading.send(.none)
        })
    }

    private func handle(error: Error) {
        if (error.isInternetConnectionError) {
            self.offline.send(true)
            self.error.send(NSLocalizedString("No internet connection", comment: ""))
            return
        }
        self.error.send(NSLocalizedString("Failed loading movies", comment: ""))
    }
}

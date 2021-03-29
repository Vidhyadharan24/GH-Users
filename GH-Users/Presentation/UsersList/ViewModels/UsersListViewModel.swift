//
//  UsersListViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import Foundation
import Combine

struct UsersListViewModelActions {
    let showUserDetails: (UserEntity, @escaping (_ updated: UserEntity) -> Void) -> Void
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
    var error: CurrentValueSubject<String?, Never> { get }
    var isCached: CurrentValueSubject<Bool, Never> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var searchBarPlaceholder: String { get }
}

protocol UsersListViewModelProtocol: UsersListViewModelInputProtocol, UsersListViewModelOutputProtocol {}

class UsersListViewModel: UsersListViewModelProtocol {

    
    let respository: UsersListRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    let actions: UsersListViewModelActions
    
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }

    private var pages: [UsersSince] = []
    private var users: [UserEntity] = []
    private(set) var userViewModels = CurrentValueSubject<[UserListCellViewModelProtocol], Never>([])
    private(set) var loading = CurrentValueSubject<UsersListViewModelLoading?, Never>(.none)
    private(set) var error = CurrentValueSubject<String?, Never>(nil)
    private(set) var isCached = CurrentValueSubject<Bool, Never>(false)
    var isEmpty: Bool { return userViewModels.value.isEmpty }
    let screenTitle = NSLocalizedString("Users", comment: "")
    let emptyDataTitle = NSLocalizedString("Unable to retrive users", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let searchBarPlaceholder = NSLocalizedString("Search Users", comment: "")
    
    init(usersListRepository: UsersListRepositoryProtocol, imageRepository: ImageRepositoryProtocol, actions: UsersListViewModelActions) {
        self.respository = usersListRepository
        self.actions = actions
        self.imageRepository = imageRepository
    }
    
    func viewDidLoad() {
        load(since: 0, loading: .nextPage)
    }
    
    func didLoadNextPage() {
        let lastUserId = Int(users.last?.id ?? 0)
        load(since: lastUserId, loading: .nextPage)
    }
    
    func showLocalUserSearch() {
        actions.showLocalUserSearch()
    }
    
    func closeLocalUserSearch() {
        actions.closeLocalUserSearch()
    }
    
    func didSelectItem(at index: Int) {
        let users = pages.flatMap { $0.users }
        actions.showUserDetails(users[index]) {[weak self] _ in
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
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, completion: { (result) in
            switch result {
            case .success(let page):
                self.isCached.send(false)
                self.appendPage(since: since, response: page)
            case .failure(let error):
                if (self.pages.filter { $0.since == since }.count > 0) {
                    self.isCached.send(true)
                }
                self.handle(error: error)
            }
            self.loading.send(.none)
        })
    }

    private func handle(error: Error) {
        self.error.send(error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: ""))
    }
}

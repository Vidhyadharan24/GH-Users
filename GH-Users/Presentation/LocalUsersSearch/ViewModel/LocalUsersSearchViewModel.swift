//
//  LocalUsersSearchViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

struct LocalUsersSearchViewModelActions {
    let showUserDetails: (UserEntity, @escaping () -> Void) -> Void
}

protocol LocalUsersSearchViewModelInputProtocol {
    func didSearch(query: String)
    func didCancel()
    func didSelectItem(at index: Int)
}

protocol LocalUsersSearchViewModelOutputProtocol {
    var userViewModels: CurrentValueSubject<[UserListCellViewModelProtocol], Never> { get }
    var error: CurrentValueSubject<String?, Never> { get }
    var isEmpty: Bool { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
}

protocol LocalUsersSearchViewModelProtocol: LocalUsersSearchViewModelInputProtocol, LocalUsersSearchViewModelOutputProtocol {}

// BONUS TASK: Coordinator and/or MVVM patterns are used.
class LocalUsersSearchViewModel: LocalUsersSearchViewModelProtocol {
    let respository: LocalUsersSearchRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    let actions: LocalUsersSearchViewModelActions?

    private var users: [UserEntity] = []
    private(set) var userViewModels = CurrentValueSubject<[UserListCellViewModelProtocol], Never>([])
    private(set) var error = CurrentValueSubject<String?, Never>(nil)
    var isEmpty: Bool { return userViewModels.value.isEmpty }
    let emptyDataTitle = NSLocalizedString("No users found", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }

    init(repository: LocalUsersSearchRepositoryProtocol,
         imageRepository: ImageRepositoryProtocol,
         actions: LocalUsersSearchViewModelActions?) {
        self.respository = repository
        self.imageRepository = imageRepository
        self.actions = actions
    }
    
    deinit {
        usersLoadTask?.cancel()
    }
    
    func didSearch(query: String) {
        load(query: query)
    }
    
    func didCancel() {
        usersLoadTask?.cancel()
    }
    
    func didSelectItem(at index: Int) {
        actions?.showUserDetails(users[index]) {[weak self] in
            // Reloading on return from User Details Page
            guard let self = self else { return }
            self.userViewModels.send(self.userViewModels.value)
        }
    }
}

extension LocalUsersSearchViewModel {
    // MARK: - Private
    
    private func setLocalSearch(results: [UserEntity]) {
        users = results
        let models = users.map { UserListCellViewModel(user: $0, imageRepository: imageRepository)}
        userViewModels.send(models)
    }

    private func load(query: String) {
        usersLoadTask = respository.fetchUsers(for: query, cached: {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let results):
                self.setLocalSearch(results: results ?? [])
            case .failure(let error):
                print(error.localizedDescription)
                self.handle(error: error)
            }
        })
    }

    private func handle(error: Error) {
        self.error.send(error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: ""))
    }
}

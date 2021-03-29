//
//  LocalUsersSearchViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

struct LocalUsersSearchViewModelActions {
    let showUserDetails: (UserEntity, @escaping (_ updated: UserEntity) -> Void) -> Void
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

class LocalUsersSearchViewModel: LocalUsersSearchViewModelProtocol {
    let respository: LocalUsersSearchRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    let actions: LocalUsersSearchViewModelActions
    
    private var usersLoadTask: Cancellable? { willSet { usersLoadTask?.cancel() } }

    private var users: [UserEntity] = []
    private(set) var userViewModels = CurrentValueSubject<[UserListCellViewModelProtocol], Never>([])
    private(set) var error = CurrentValueSubject<String?, Never>(nil)
    var isEmpty: Bool { return userViewModels.value.isEmpty }
    let emptyDataTitle = NSLocalizedString("No users foud", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    
    init(localUsersSearchRepository: LocalUsersSearchRepositoryProtocol,
         imageRepository: ImageRepositoryProtocol,
         actions: LocalUsersSearchViewModelActions) {
        self.respository = localUsersSearchRepository
        self.actions = actions
        self.imageRepository = imageRepository
    }
    
    func didSearch(query: String) {
        load(query: query)
    }
    
    func didCancel() {
        usersLoadTask?.cancel()
    }
    
    func didSelectItem(at index: Int) {
        actions.showUserDetails(users[index]) { _ in
        }
    }
}

extension LocalUsersSearchViewModel {
    // MARK: - Private
    
    private func setLocalSearch(results: [UserEntity]) {
        users = results
        userViewModels.send(users.map { UserListCellViewModel(user: $0, imageRepository: imageRepository)})
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

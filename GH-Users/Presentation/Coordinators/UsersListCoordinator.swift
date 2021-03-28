//
//  UsersListCoordinator.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

protocol UsersListCoordinatorProtocol  {
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController
//    func makeUsersDetailsViewController(user: UserEntity) -> UserDetailsViewController
}

final class UsersListCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let dependencies: UsersListCoordinatorProtocol

    private weak var usersListViewController: UsersListViewController?
    private weak var usersLocalSearchViewController: UIViewController?

    init(navigationController: UINavigationController,
         dependencies: UsersListCoordinatorProtocol) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }
    
    func start() {
        let actions = UsersListViewModelActions(showUserDetails: showUserDetails)
        let vc = dependencies.makeUsersListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        usersListViewController = vc
    }

    private func showUserDetails(user: UserEntity) {
    }
    
    private func showLocalUserSearch(didSelect: @escaping (UserEntity) -> Void) {
    }

    private func closeLocalUserSearch() {
    }
}

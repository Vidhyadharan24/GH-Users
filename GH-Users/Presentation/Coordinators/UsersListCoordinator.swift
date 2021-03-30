//
//  UsersListCoordinator.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

protocol UsersListDIContainerProtocol  {
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController
    func makeUserDetailsViewController(user: UserEntity, completion: @escaping () -> Void) -> UserDetailsViewController
    func makeLocalUserSearchListViewController(actions: LocalUsersSearchViewModelActions) -> UsersSearchTableViewController
}

final class UsersListCoordinator {
    
    private weak var navigationController: UINavigationController?
    private let diContainer: UsersListDIContainerProtocol

    private weak var usersListViewController: UsersListViewController?
    private weak var usersLocalSearchViewController: UsersSearchTableViewController?

    init(navigationController: UINavigationController,
         diContainer: UsersListDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        let actions = UsersListViewModelActions(showUserDetails: showUserDetails,
                                                showLocalUserSearch: showLocalUserSearch,
                                                closeLocalUserSearch: closeLocalUserSearch)
        let vc = diContainer.makeUsersListViewController(actions: actions)

        navigationController?.pushViewController(vc, animated: false)
        usersListViewController = vc
    }

    // MARK: UserDetails
    private func showUserDetails(user: UserEntity, completion: @escaping () -> Void) {
        let vc = diContainer.makeUserDetailsViewController(user: user, completion: completion)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: LocalUserSearch
    private func showLocalUserSearch() {
        guard let usersListViewController = usersListViewController, usersLocalSearchViewController == nil else { return }
        let container = usersListViewController.usersSearchContainer

        let actions = LocalUsersSearchViewModelActions(showUserDetails: showUserDetails)
        let vc = diContainer.makeLocalUserSearchListViewController(actions: actions)
        
        usersListViewController.add(child: vc, container: container)
        usersListViewController.usersSearchTableViewController = vc
        usersLocalSearchViewController = vc
        container.isHidden = false
    }

    private func closeLocalUserSearch() {
        usersLocalSearchViewController?.remove()
        usersLocalSearchViewController = nil
        usersListViewController?.usersSearchTableViewController = nil
        usersListViewController?.usersSearchContainer.isHidden = true
    }
}

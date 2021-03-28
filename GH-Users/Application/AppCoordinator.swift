//
//  AppCoordinator.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import UIKit

final class AppCoordinator {

    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        let usersSceneDIContainer = appDIContainer.makeUsersSceneDIContainer()
        let coordinator = usersSceneDIContainer.makeUsersListCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}

//
//  AppCoordinator.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import UIKit

// BONUS TASK: Coordinator and/or MVVM patterns are used.
final class AppCoordinator {

    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
         appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        
        navigationController.navigationBar.isTranslucent = false
    }

    func start() {
        let usersSceneDIContainer = appDIContainer.makeUsersSceneDIContainer()
        let coordinator = usersSceneDIContainer.makeUsersListCoordinator(navigationController: navigationController)
        coordinator.start()
    }

}

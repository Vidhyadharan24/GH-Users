//
//  UsersSceneDIContainer.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import UIKit

final class UsersSceneDIContainer {

    private let appConfig: AppConfig
    private let apiDecodableService: NetworkDecodableServiceProtocol
    private let imageDecodableService: NetworkDecodableServiceProtocol

    // MARK: - Persistent Storage
    lazy var persistantStorageService: UsersListStorageServiceProtocol = UsersListStorageService(persistenceManager: PersistenceManager.shared, fetchLimit: appConfig.persistantStorageFetchLimit)
    
    lazy var localUserSearchPersistanceService: LocalUsersSearchPersistanceServiceProtocol = LocalUsersSearchPersistanceService(persistenceManager: PersistenceManager.shared)
    
    // MARK: - Image Cache Service
    lazy var imageCacheService: ImageCacheServiceProtocol = ImageCacheService(imagePersistanceManager: ImagePersistanceManager())

    init(appConfig: AppConfig, apiDecodableService: NetworkDecodableServiceProtocol, imageDecodableService: NetworkDecodableServiceProtocol) {
        self.appConfig = appConfig
        self.apiDecodableService = apiDecodableService
        self.imageDecodableService = imageDecodableService
    }

    // MARK: - Repositories
    func makeUsersListRepository() -> UsersListRepositoryProtocol {
        return UsersListRepository(networkDecodableService: apiDecodableService, persistantStorageService: persistantStorageService)
    }
    func makeLocalUsersSearchRepository() -> LocalUsersSearchRepositoryProtocol {
        return LocalUsersSearchRepository(persistantStorageService: localUserSearchPersistanceService)
    }
    func makeImageRepository() -> ImageRepositoryProtocol {
        return ImageRepository(networkDecodableService: imageDecodableService, imageCacheService: imageCacheService)
    }

    // MARK: - Users List
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController {
        return UsersListViewController.create(viewModel: makeUsersListViewModel(actions: actions),
                                              imageRepository: makeImageRepository())
    }

    func makeUsersListViewModel(actions: UsersListViewModelActions) -> UsersListViewModel {
        return UsersListViewModel(usersListRepository: makeUsersListRepository(), imageRepository: makeImageRepository(), actions: actions)
    }
    
    // MARK: Local User Search
    
    func makeLocalUserSearchListViewController(actions: LocalUsersSearchViewModelActions) -> UsersSearchTableViewController {
        return UsersSearchTableViewController(viewModel: makeLocalUsersSearchViewModel(actions: actions))
    }
    
    func makeLocalUsersSearchViewModel(actions: LocalUsersSearchViewModelActions) -> LocalUsersSearchViewModel {
        return LocalUsersSearchViewModel(localUsersSearchRepository: makeLocalUsersSearchRepository(),
                                         imageRepository: makeImageRepository(),
                                         actions: actions)
    }
//    // MARK: - User Details
//    func makeUsersDetailsViewController(user: UserEntity) -> UserDetailsViewController {
//        return UserDetailsViewController.create(with: makeUsersDetailsViewModel(user: user))
//    }
//
//    func makeUsersDetailsViewModel(user: UserEntity) -> UserDetailsViewModelProtocol {
//        return UserDetailsViewModel(user: user,
//                                     posterImagesRepository: makePosterImagesRepository())
//    }

    // MARK: - Coordinators
    func makeUsersListCoordinator(navigationController: UINavigationController) -> UsersListCoordinator {
        return UsersListCoordinator(navigationController: navigationController,
                                    diContainer: self)
    }
}

extension UsersSceneDIContainer: UsersListDIContainerProtocol {}

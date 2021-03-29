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
    
    lazy var userDetailsPersistanceService: UserDetailsPersistanceServiceProtocol = UserDetailsPersistanceService(persistenceManager: PersistenceManager.shared)
    
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
    func makeUserDetailsRepository() -> UserDetailsRepositoryProtocol {
        return UserDetailsRepository(networkDecodableService: apiDecodableService, persistantStorageService: userDetailsPersistanceService)
    }

    // MARK: - Users List
    func makeUsersListViewController(actions: UsersListViewModelActions) -> UsersListViewController {
        return UsersListViewController.create(viewModel: makeUsersListViewModel(actions: actions))
    }

    func makeUsersListViewModel(actions: UsersListViewModelActions) -> UsersListViewModel {
        return UsersListViewModel(repository: makeUsersListRepository(), imageRepository: makeImageRepository(), actions: actions)
    }
    
    // MARK: Local User Search
    
    func makeLocalUserSearchListViewController(actions: LocalUsersSearchViewModelActions) -> UsersSearchTableViewController {
        return UsersSearchTableViewController(viewModel: makeLocalUsersSearchViewModel(actions: actions))
    }
    
    func makeLocalUsersSearchViewModel(actions: LocalUsersSearchViewModelActions) -> LocalUsersSearchViewModel {
        return LocalUsersSearchViewModel(repository: makeLocalUsersSearchRepository(),
                                         imageRepository: makeImageRepository(),
                                         actions: actions)
    }
    // MARK: - User Details
    func makeUserDetailsViewController(user: UserEntity, completion: @escaping () -> Void) -> UserDetailsViewController {
        let storyboardName = "UserDetailsViewController"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vc = storyboard.instantiateInitialViewController() as? UserDetailsViewController else {
            fatalError("Cannot instantiate initial view controller \(Self.self) from storyboard with name \(storyboardName)")
        }
        vc.viewModel = makeUserDetailsViewModel(user: user)
        vc.completion = completion
        return vc
    }

    func makeUserDetailsViewModel(user: UserEntity) -> UserDetailsViewModel {
        return UserDetailsViewModel(user: user,
                                    repository: makeUserDetailsRepository(),
                                    imageRespository: makeImageRepository())
    }

    // MARK: - Coordinators
    func makeUsersListCoordinator(navigationController: UINavigationController) -> UsersListCoordinator {
        return UsersListCoordinator(navigationController: navigationController,
                                    diContainer: self)
    }
}

extension UsersSceneDIContainer: UsersListDIContainerProtocol {}

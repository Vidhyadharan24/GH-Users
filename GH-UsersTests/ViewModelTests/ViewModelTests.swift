//
//  ViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import XCTest
import Combine

@testable import GH_Users


class ViewModelTests: XCTestCase {
    var persistanceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    
    var mockUsersListRepository: MockUsersListRepository!
    var mockSearchUsersRepository: MockSearchUsersRepository!
    var mockUserDetailsRepository: MockUserDetailsRepository!

    var userListViewModel: UsersListViewModel!
    var usersSearchViewModel: LocalUsersSearchViewModel!
    var userDetailsViewModel: UserDetailsViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistanceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        
        mockUsersListRepository = MockUsersListRepository()
        mockSearchUsersRepository = MockSearchUsersRepository()
        mockUserDetailsRepository = MockUserDetailsRepository()
        
    }

    override func tearDownWithError() throws {
        persistanceManager = nil

        mockUsersListRepository = nil
        mockSearchUsersRepository = nil
        mockUserDetailsRepository = nil

        userListViewModel = nil
        usersSearchViewModel = nil
        userDetailsViewModel = nil
        
        cancellableSet.removeAll()
    }
    
    // MARK: - UsersListViewModel tests
    
    func testUserListViewModelNoData() throws {
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: nil)
        
        mockUsersListRepository.cacheError = PersistanceError.noData
        mockUsersListRepository.liveError = NetworkDecodableServiceError.networkFailure(.notConnected)
        
        userListViewModel.viewDidLoad()
        
        let expectation = self.expectation(description: "View model values are valid when not data from cache and network")
        
        userListViewModel.loading.sink {[weak self] (loading) in
            guard case .none = loading else { return }
            guard self?.userListViewModel.isEmpty == true else { return }
            guard self?.userListViewModel.offline.value == true else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - UsersSearchViewModel tests
    func testUserSearchViewModelNoData() throws {
        func showUserDetails(user: UserEntity, completion: @escaping () -> Void) {
        }

        let actions = LocalUsersSearchViewModelActions(showUserDetails: showUserDetails)

        usersSearchViewModel = LocalUsersSearchViewModel(repository: mockSearchUsersRepository, imageRepository: mockImageRepository, actions: actions)
    }

    // MARK: - UserDetailsViewModel tests

    func testUserDetailsViewModelNoData() throws {
        let userEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistanceManager.backgroundContext)
        try persistanceManager.backgroundContext.save()
        
        userDetailsViewModel = UserDetailsViewModel(user: userEntity, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
    }

}

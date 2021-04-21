//
//  ViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import XCTest
import Combine
import CoreData

@testable import GH_Users


class ViewModelTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    
    var mockUsersListRepository: MockUsersListRepository!
    var mockSearchUsersRepository: MockSearchUsersRepository!
    var mockUserDetailsRepository: MockUserDetailsRepository!

    var userListViewModel: UsersListViewModel!
    var usersSearchViewModel: LocalUsersSearchViewModel!
    var userDetailsViewModel: UserDetailsViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        
        mockUsersListRepository = MockUsersListRepository()
        mockSearchUsersRepository = MockSearchUsersRepository()
        mockUserDetailsRepository = MockUserDetailsRepository()
    }

    override func tearDownWithError() throws {
        persistenceManager = nil

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
        
        mockUsersListRepository.cacheError = PersistenceError.noData
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
        let expectation = self.expectation(description: "User view model no data")

        func execute(_ entity: UserEntity?, _ error: Error?) {
            guard let entity = entity, error == nil else { return }
            userDetailsViewModel = UserDetailsViewModel(user: entity, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
            expectation.fulfill()
        }
        
        persistenceManager.saveInBackgroundContext { (context) in
            let userEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: context)
            do {
                try context.save()
                execute(userEntity, nil)
            } catch (let error) {
                execute(nil, error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}

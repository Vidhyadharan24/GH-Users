//
//  ViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import XCTest
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
    }
    
    // MARK: - UsersListViewModel tests
    
    func testUserListViewModelNoData() throws {
        func showUserDetails(user: UserEntity, completion: @escaping () -> Void) {
        }

        func showLocalUserSearch() {
        }
        
        func closeLocalUserSearch() {
            
        }

        let actions = UsersListViewModelActions(showUserDetails: showUserDetails, showLocalUserSearch: showLocalUserSearch, closeLocalUserSearch: closeLocalUserSearch)
        
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: actions)
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

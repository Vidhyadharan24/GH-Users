//
//  UserSearchViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
import Combine

@testable import GH_Users

class UserSearchViewModelTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    var mockSearchUsersRepository: MockSearchUsersRepository!

    var usersSearchViewModel: LocalUsersSearchViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        mockSearchUsersRepository = MockSearchUsersRepository()
    }

    override func tearDownWithError() throws {
        persistenceManager = nil

        mockImageRepository = nil
        mockSearchUsersRepository = nil
        
        usersSearchViewModel = nil
        
        cancellableSet.removeAll()
    }

    // MARK: - UsersSearchViewModel tests
    func testUserSearchViewModelNoData() throws {
        let expectation = self.expectation(description: "View model should no return any data")

        usersSearchViewModel = LocalUsersSearchViewModel(repository: mockSearchUsersRepository, imageRepository: mockImageRepository, actions: nil)
        mockSearchUsersRepository.error = PersistenceError.noData
        
        usersSearchViewModel.userViewModels.sink { (result) in
            guard result.count == 0 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        usersSearchViewModel.didSearch(query: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserSearchViewModelValidData() throws {
        let expectation = self.expectation(description: "View model should return users data for query")

        usersSearchViewModel = LocalUsersSearchViewModel(repository: mockSearchUsersRepository, imageRepository: mockImageRepository, actions: nil)
        mockSearchUsersRepository.userList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        
        usersSearchViewModel.userViewModels.sink { (result) in
            guard result.count == 10 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        usersSearchViewModel.didSearch(query: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}

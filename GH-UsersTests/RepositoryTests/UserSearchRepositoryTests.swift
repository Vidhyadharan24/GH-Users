//
//  UserSearchRepositoryTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users

class UserSearchRepositoryTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    
    var networkDecodableService: MockNetworkDecodableService!
    var localUsersSearchPersistenceService: MockLocalUsersSearchPersistenceService!

    var localUserSearchRepository: LocalUsersSearchRepositoryProtocol!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        networkDecodableService = MockNetworkDecodableService()
        localUsersSearchPersistenceService = MockLocalUsersSearchPersistenceService()

        localUserSearchRepository = LocalUsersSearchRepository(persistenceService: localUsersSearchPersistenceService)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        
        networkDecodableService = nil
        localUsersSearchPersistenceService = nil
        
        localUserSearchRepository = nil
    }
        
    func testUserSearchSuccess() throws {
        let userList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        localUsersSearchPersistenceService.usersListResponse = userList
        
        let expectation = self.expectation(description: "fetch users result should be a success")
        
        _ = localUserSearchRepository.fetchUsers(for: "test") { (result) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserSearchFailure() throws {
        localUsersSearchPersistenceService.persistenceError = PersistenceError.readError(nil)
        
        let expectation = self.expectation(description: "fetch users result should be a failure")
        
        _ = localUserSearchRepository.fetchUsers(for: "test") { (result) in
            switch result {
            case .success(_): break
            case .failure(_):
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}

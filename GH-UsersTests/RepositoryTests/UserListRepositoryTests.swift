//
//  UserListRepositoryTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users


class UserListRepositoryTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    
    var networkDecodableService: MockNetworkDecodableService!
    var usersListPersistenceService: MockUserListPersistenceService!

    var usersListRepository: UsersListRepositoryProtocol!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        networkDecodableService = MockNetworkDecodableService()
        usersListPersistenceService = MockUserListPersistenceService()

        usersListRepository = UsersListRepository(networkDecodableService: networkDecodableService, persistenceService: usersListPersistenceService)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        
        networkDecodableService = nil
        usersListPersistenceService = nil
        
        usersListRepository = nil
    }
    
    func testFetchUserNoData() throws {
        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        usersListPersistenceService.persistenceError = .readError(nil)
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a failure")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a failure")

        _ = usersListRepository.fetchUsersList(since: 0, cached: { (result) in
            switch result {
            case .success(_): break
            case .failure(_):
                cacheDataExpectation.fulfill()
            }
        }, completion: { (result) in
            switch result {
            case .success(_): break
            case .failure(_):
                networkDataExpectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchUserCachedData() throws {
        let userList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)

        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        usersListPersistenceService.usersListResponse = userList
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a success")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a failure")

        _ = usersListRepository.fetchUsersList(since: 0, cached: { (result) in
            switch result {
            case .success(_):
                cacheDataExpectation.fulfill()
            case .failure(_): break
            }
        }, completion: { (result) in
            switch result {
            case .success(_): break
            case .failure(_):
                networkDataExpectation.fulfill()
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchUserLiveData() throws {
        let usersEntityList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        let usersList = ModelGenerator.generateUserListResponse(10)

        networkDecodableService.decodable = usersList
        usersListPersistenceService.usersListResponse = usersEntityList
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a success")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a failure")

        _ = usersListRepository.fetchUsersList(since: 0, cached: { (result) in
            switch result {
            case .success(_):
                cacheDataExpectation.fulfill()
            case .failure(_): break
            }
        }, completion: { (result) in
            switch result {
            case .success(_):
                networkDataExpectation.fulfill()
            case .failure(_): break
            }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}

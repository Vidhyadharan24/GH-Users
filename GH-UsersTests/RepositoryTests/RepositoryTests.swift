//
//  RepositoryTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import XCTest
@testable import GH_Users

class RepositoryTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    
    var networkDecodableService: MockNetworkDecodableService!
    var usersListPersistenceService: MockUserListPersistanceService!
    var localUsersSearchPersistanceService: MockLocalUsersSearchPersistanceService!
    var userDetailsPersistenceService: MockUserDetailsPersistenceService!

    var usersListRepository: UsersListRepositoryProtocol!
    var localUserSearchRepository: LocalUsersSearchRepositoryProtocol!
    var userDetailsRepository: UserDetailsRepositoryProtocol!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        networkDecodableService = MockNetworkDecodableService()
        usersListPersistenceService = MockUserListPersistanceService()
        localUsersSearchPersistanceService = MockLocalUsersSearchPersistanceService()
        userDetailsPersistenceService = MockUserDetailsPersistenceService()

        usersListRepository = UsersListRepository(networkDecodableService: networkDecodableService, persistenceService: usersListPersistenceService)
        localUserSearchRepository = LocalUsersSearchRepository(persistenceService: localUsersSearchPersistanceService)
        userDetailsRepository = UserDetailsRepository(networkDecodableService: networkDecodableService, persistenceService: userDetailsPersistenceService)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        
        networkDecodableService = nil
        usersListPersistenceService = nil
        localUsersSearchPersistanceService = nil
        userDetailsPersistenceService = nil
        
        usersListRepository = nil
        localUserSearchRepository = nil
        userDetailsRepository = nil
    }
    
    // MARK: - LocalUsersSearchRepository Tests
    
    func testUserSearchSuccess() throws {
        let userList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        localUsersSearchPersistanceService.usersListResponse = userList
        
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
        localUsersSearchPersistanceService.persistanceError = PersistanceError.readError(nil)
        
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
    
    // MARK: - UsersListRepositoryProtocol Tests
    func testFetchUserNoData() throws {
        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        usersListPersistenceService.persistanceError = .readError(nil)
        
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

    // MARK: - UserDetailsRepositoryProtocol Tests
    func testFetchUserDetailsNoData() throws {
        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        userDetailsPersistenceService.persistanceError = .readError(nil)
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a failure")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a failure")

        _ = userDetailsRepository.fetchUserDetails(username: "test", cached: { (result) in
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
    
    func testFetchUserDetailsCachedData() throws {
        let userDetails = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)

        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        userDetailsPersistenceService.userDetails = userDetails
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a success")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a failure")

        _ = userDetailsRepository.fetchUserDetails(username: "test", cached: { (result) in
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
    
    func testFetchUserDetailsLiveData() throws {
        let userDetailsEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)
        let userDetailsResponse = ModelGenerator.generateUserDetails(id: 1)
        
        networkDecodableService.decodable = userDetailsResponse
        userDetailsPersistenceService.userDetails = userDetailsEntity
        
        let cacheDataExpectation = self.expectation(description: "fetch users result should be a success")
        let networkDataExpectation = self.expectation(description: "fetch users result should be a success")

        _ = userDetailsRepository.fetchUserDetails(username: "test", cached: { (result) in
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
    
    func testSaveNoteSuccess() throws {
        let expectation = self.expectation(description: "save should return no errors")

        userDetailsRepository.save(note: "test", username: "vid", completion: { (error) in
            guard error == nil else { return }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSaveNoteFailure() throws {
        userDetailsPersistenceService.persistanceError = .readError(nil)
        
        let expectation = self.expectation(description: "save should return an error")

        userDetailsRepository.save(note: "test", username: "vid", completion: { (error) in
            guard error != nil else { return }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}

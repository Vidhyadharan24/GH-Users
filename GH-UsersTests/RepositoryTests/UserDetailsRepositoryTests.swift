//
//  UserDetailsRepositoryTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users

class UserDetailsRepositoryTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    
    var networkDecodableService: MockNetworkDecodableService!
    var userDetailsPersistenceService: MockUserDetailsPersistenceService!

    var userDetailsRepository: UserDetailsRepositoryProtocol!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        networkDecodableService = MockNetworkDecodableService()
        userDetailsPersistenceService = MockUserDetailsPersistenceService()

        userDetailsRepository = UserDetailsRepository(networkDecodableService: networkDecodableService, persistenceService: userDetailsPersistenceService)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        
        networkDecodableService = nil
        userDetailsPersistenceService = nil
        
        userDetailsRepository = nil
    }

    // MARK: - UserDetailsRepositoryProtocol Tests
    func testFetchUserDetailsNoData() throws {
        networkDecodableService.error = NetworkDecodableServiceError.networkFailure(.notConnected)
        userDetailsPersistenceService.persistenceError = PersistenceError.readError(nil)
        
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
    
    // MARK: BUGFix - No actual data model tests (e.g. testing the save note logic)

    func testSaveNoteSuccess() throws {
        let expectation = self.expectation(description: "save should return no errors")

        userDetailsRepository.save(note: "test", username: "vid", completion: { (error) in
            guard error == nil else { return }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSaveNoteFailure() throws {
        userDetailsPersistenceService.persistenceError = PersistenceError.readError(nil)
        
        let expectation = self.expectation(description: "save should return an error")

        userDetailsRepository.save(note: " ", username: "vid", completion: { (error) in
            guard error != nil else { return }
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

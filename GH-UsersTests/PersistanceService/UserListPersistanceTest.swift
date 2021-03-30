//
//  UserListPersistanceTest.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import XCTest
@testable import GH_Users

class UserListPersistanceTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var persistenceService: UsersListPersistanceService!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        persistenceService = UsersListPersistanceService(persistenceManager: persistenceManager, fetchLimit: 30)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        persistenceService = nil
    }
    
    func testwriteAndRead() throws {
        let response = ModelGenerator.generateUserListResponse(userCount: 10)
        
        let expectation = self.expectation(description: "User response write test")
        
        func readAndValidate() {
            let request = UsersListRequest(since: 0)
            persistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 10 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }
        
        persistenceService.save(response: response) {(error) in
            guard error == nil else { return }
            readAndValidate()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func readTest() throws {
    }

}

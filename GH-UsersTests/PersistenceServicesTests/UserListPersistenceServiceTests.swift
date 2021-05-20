//
//  UserListPersistenceServiceTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users

class UserListPersistenceServiceTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    var userListPersistenceService: UsersListPersistenceService!
    var localUsersSearchPersistenceService: LocalUsersSearchPersistenceService!
    var userDetailsPersistenceService: UserDetailsPersistenceService!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        userListPersistenceService = UsersListPersistenceService(persistenceManager: persistenceManager, fetchLimit: 30)
        localUsersSearchPersistenceService = LocalUsersSearchPersistenceService(persistenceManager: persistenceManager)
        userDetailsPersistenceService = UserDetailsPersistenceService(persistenceManager: persistenceManager)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        userListPersistenceService = nil
        localUsersSearchPersistenceService = nil
        userDetailsPersistenceService = nil

    }

    // MARK: - UsersListPersistenceService tests
        
    func testUsersListServiceRead() throws {
        let expectation = self.expectation(description: "User response write test")
            
        func execute(_ error: Error?) {
            guard error == nil else { return }
                
            let request = UsersListRequest(since: 0)
            userListPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 10 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let _ = ModelGenerator.generateUserEntityList(10, in: context)
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
            
        waitForExpectations(timeout: 1, handler: nil)
    }
        
    func testUsersListServiceWrite() throws {
        let response = ModelGenerator.generateUserListResponse(10)
            
        let expectation = self.expectation(description: "User response write test")
            
        func readAndValidate() {
            let request = UsersListRequest(since: 0)
            userListPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 10 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }
            
        userListPersistenceService.save(response: response) {(error) in
            guard error == nil else { return }
                
            readAndValidate()
        }
            
        waitForExpectations(timeout: 1, handler: nil)
    }
}

//
//  MergePolicyPersistenceServicesTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import XCTest
@testable import GH_Users

class MergePolicyPersistenceServicesTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var userListPersistenceService: UsersListPersistenceService!
    var userDetailsPersistenceService: UserDetailsPersistenceService!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        userListPersistenceService = UsersListPersistenceService(persistenceManager: persistenceManager, fetchLimit: 30)
        userDetailsPersistenceService = UserDetailsPersistenceService(persistenceManager: persistenceManager)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        userListPersistenceService = nil
        userDetailsPersistenceService = nil
    }

    func testStoreMergePolicy() throws {
        let expectation = self.expectation(description: "User response write test")

        func execute(_ user: UserEntity?, _ error: Error?) {
           guard let user = user, error == nil else { return }
            
            let userDetailsRequest = UserDetailsRequest(username: user.login!)
            let userDetails = ModelGenerator.generateUserDetails(id: 1)
            userDetailsPersistenceService.save(request: userDetailsRequest, response: userDetails) { (error) in
                guard error == nil else { return }
                // first users viewed property is true
                saveUserListAndValidateUserData()
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in

            let user = ModelGenerator.generateUserEntity(id: 1, in: context)
            do {
                try context.save()
                execute(user, nil)
            } catch (let error) {
                execute(nil, error)
            }
            // first users viewed property is false
        }
        
        func saveUserListAndValidateUserData() {
            func execute(_ error: Error?) {
                guard error == nil else { return }
                validate()
            }

            persistenceManager.saveInBackgroundContext {(context) in
                let _ = ModelGenerator.generateUserEntityList(10, in: context)
                do {
                    try context.save()
                    execute(nil)
                } catch (let error) {
                    execute(error)
                }
                // first users viewed property should be true as the user list save should not override the viewed property with the current(store trump) merge policy the store value take precidence over in memory value.
            }
        }
        
        func validate() {
            let request = UsersListRequest(since: 0)
            userListPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard let first = users?.first, first.viewed else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

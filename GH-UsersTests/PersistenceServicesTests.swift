//
//  PersistenceServicesTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import XCTest
@testable import GH_Users

class PersistenceServicesTests: XCTestCase {
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
    
    // MARK: - LocalUsersSearchPersistenceService tests
    
    func testUsersSearchLoginContains() throws {
        let expectation = self.expectation(description: "User search login contains test")

        func execute(_ error: Error?) {
            guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "r")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            lists.forEach{ $0.login = "login"}
            
            lists.last?.login = "read"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
                
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNoteContains() throws {
        let expectation = self.expectation(description: "User search note contains test")

        func execute(_ error: Error?) {
            guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "r")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            
            lists.last?.note = "read"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUsersSearchLoginMatch() throws {
        let expectation = self.expectation(description: "User search login match test")

        func execute(_ error: Error?) {
            guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "read")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            lists.forEach{ $0.login = "login"}
            
            lists.last?.login = "read login"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNoteMatch() throws {
        let expectation = self.expectation(description: "User search note match test")

        func execute(_ error: Error?) {
           guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "read")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            
            lists.last?.note = "read note"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUsersSearchLogin_CaseInsensitivity() throws {
        let expectation = self.expectation(description: "User search login match test")

        func execute(_ error: Error?) {
           guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "r")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            lists.forEach{ $0.login = "login"}
            
            lists.last?.login = "Read login"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNote_CaseInsensitivity() throws {
        let expectation = self.expectation(description: "User search note match test")

        func execute(_ error: Error?) {
           guard error == nil else { return }
            
            let request = LocalUsersSearchQuery(query: "r")
            localUsersSearchPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let users):
                    guard users?.count == 1 else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let lists = ModelGenerator.generateUserEntityList(10, in: context)
            
            lists.last?.note = "Read note"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - UserDetailsPersistenceService tests
    
    func testUserDetailsRead() throws {
        let expectation = self.expectation(description: "User search note match test")

        func execute(_ error: Error?) {
           guard error == nil else { return }
            
            let request = UserDetailsRequest(username: "vid")
            userDetailsPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let user):
                    guard user != nil else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: context)
            user.login = "vid"
            
            do {
                try context.save()
                execute(nil)
            } catch (let error) {
                execute(error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsUpdate() throws {
        let expectation = self.expectation(description: "User search note match test")

        func userDetailsReadAndValidate(request: UserDetailsRequest) {
            userDetailsPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let user):
                    guard let user = user, user.viewed else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }
        
        func execute(_ userDetails: UserDetailsResponse?, _ error: Error?) {
           guard let userDetails = userDetails, error == nil else { return }
            
            let request = UserDetailsRequest(username: userDetails.login!)

            userDetailsPersistenceService.save(request: request, response: userDetails) { (error) in
                guard error == nil else { return }
                userDetailsReadAndValidate(request: request)
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let userDetails = ModelGenerator.generateUserDetails(id: 1)
            let userEntity = ModelGenerator.generateUserEntity(id: 1, in: context)
            userEntity.login = userDetails.login!
            
            do {
                try context.save()
                execute(userDetails, nil)
            } catch (let error) {
                execute(nil, error)
            }
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: BUGFix - No actual data model tests (e.g. testing the save note logic)
    
    func testUserDetailsSaveNoteSuccess() throws {
        let expectation = self.expectation(description: "User save note test")

        func execute(_ userDetails: UserDetailsResponse?, _ error: Error?) {
           guard let userDetails = userDetails, error == nil else { return }
            
            let request = UserDetailsRequest(username: userDetails.login!)
            
            userDetailsPersistenceService.save(note: "test", request: request) { [weak self] (error) in
                self?.userDetailsPersistenceService.getResponse(for: request) { (result) in
                    switch result {
                    case .success(let user):
                        guard let user = user, user.viewed, user.note == "test" else { return }
                        expectation.fulfill()
                    case .failure(_): break
                    }
                }
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let userDetails = ModelGenerator.generateUserDetails(id: 1)
            let userDetailsEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: context)
            userDetailsEntity.login = userDetails.login!
            
            do {
                try context.save()
                execute(userDetails, nil)
            } catch (let error) {
                execute(nil, error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsWhitespaceSaveNoteFailure() throws {
        let expectation = self.expectation(description: "User save note failure test")

        func execute(_ userDetails: UserDetailsResponse?, _ error: Error?) {
           guard let userDetails = userDetails, error == nil else { return }
            
            let request = UserDetailsRequest(username: userDetails.login!)
            
            userDetailsPersistenceService.save(note: " ", request: request) { (error) in
                guard let err = error as? UserDetailsPeristanceServiceError else { return }
                guard case .invalidNote = err else { return }
                expectation.fulfill()
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let userDetails = ModelGenerator.generateUserDetails(id: 1)
            let userDetailsEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: context)
            userDetailsEntity.login = userDetails.login!
            
            do {
                try context.save()
                execute(userDetails, nil)
            } catch (let error) {
                execute(nil, error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsNewlineSaveNoteFailure() throws {
        let expectation = self.expectation(description: "User save note failure test")

        func execute(_ userDetails: UserDetailsResponse?, _ error: Error?) {
           guard let userDetails = userDetails, error == nil else { return }
            
            let request = UserDetailsRequest(username: userDetails.login!)
            
            userDetailsPersistenceService.save(note: "\n", request: request) { (error) in
                guard let err = error as? UserDetailsPeristanceServiceError else { return }
                guard case .invalidNote = err else { return }
                expectation.fulfill()
            }
        }

        persistenceManager.saveInBackgroundContext {(context) in
            let userDetails = ModelGenerator.generateUserDetails(id: 1)
            let userDetailsEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: context)
            userDetailsEntity.login = userDetails.login!
            
            do {
                try context.save()
                execute(userDetails, nil)
            } catch (let error) {
                execute(nil, error)
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Merge Policy tests

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

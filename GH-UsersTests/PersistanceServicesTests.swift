//
//  PersistanceServicesTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import XCTest
@testable import GH_Users

class PersistanceServicesTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    var userListPersistenceService: UsersListPersistanceService!
    var localUsersSearchPersistanceService: LocalUsersSearchPersistanceService!
    var userDetailsPersistenceService: UserDetailsPersistanceService!

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        userListPersistenceService = UsersListPersistanceService(persistenceManager: persistenceManager, fetchLimit: 30)
        localUsersSearchPersistanceService = LocalUsersSearchPersistanceService(persistenceManager: persistenceManager)
        userDetailsPersistenceService = UserDetailsPersistanceService(persistenceManager: persistenceManager)
    }

    override func tearDownWithError() throws {
        persistenceManager = nil
        userListPersistenceService = nil
        localUsersSearchPersistanceService = nil
        userDetailsPersistenceService = nil

    }
    
// MARK: - UsersListPersistanceService tests
    
    func testUsersListServiceRead() throws {
        let _ = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User response write test")
        
        let request = UsersListRequest(since: 0)
        userListPersistenceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 10 else { return }
                expectation.fulfill()
            case .failure(_): break
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
    
    // MARK: - LocalUsersSearchPersistanceService tests
    
    func testUsersSearchLoginContains() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        lists.forEach{ $0.login = "login"}
        
        lists.last?.login = "read"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search login contains test")
        
        let request = LocalUsersSearchQuery(query: "r")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNoteContains() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        
        lists.last?.note = "read"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search note contains test")

        let request = LocalUsersSearchQuery(query: "r")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUsersSearchLoginMatch() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        lists.forEach{ $0.login = "login"}
        
        lists.last?.login = "read login"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search login match test")
        
        let request = LocalUsersSearchQuery(query: "read")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNoteMatch() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        
        lists.last?.note = "read note"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search note match test")

        let request = LocalUsersSearchQuery(query: "read")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUsersSearchLogin_CaseInsensitivity() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        lists.forEach{ $0.login = "login"}
        
        lists.last?.login = "Read login"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search login match test")
        
        let request = LocalUsersSearchQuery(query: "r")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUsersSearchNote_CaseInsensitivity() throws {
        let lists = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
        
        lists.last?.note = "Read note"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search note match test")

        let request = LocalUsersSearchQuery(query: "r")
        localUsersSearchPersistanceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let users):
                guard users?.count == 1 else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - UserDetailsPersistanceService tests
    
    func testUserDetailsRead() throws {
        let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.backgroundContext)
        user.login = "vid"
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search note match test")

        let request = UserDetailsRequest(username: "vid")
        userDetailsPersistenceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let user):
                guard user != nil else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsUpdate() throws {
        let userDetails = ModelGenerator.generateUserDetails(id: 1)
        let userEntity = ModelGenerator.generateUserEntity(id: 1, in: persistenceManager.backgroundContext)
        userEntity.login = userDetails.login!
        
        try persistenceManager.backgroundContext.save()
        
        let expectation = self.expectation(description: "User search note match test")
        
        let request = UserDetailsRequest(username: userDetails.login!)

        func userDetailsReadAndValidate() {
            userDetailsPersistenceService.getResponse(for: request) { (result) in
                switch result {
                case .success(let user):
                    guard let user = user, user.viewed else { return }
                    expectation.fulfill()
                case .failure(_): break
                }
            }
        }
        
        userDetailsPersistenceService.save(request: request, response: userDetails) { (error) in
            guard error == nil else { return }
            userDetailsReadAndValidate()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsSaveNote() throws {
        let userDetails = ModelGenerator.generateUserDetails(id: 1)
        let userDetailsEntity = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.backgroundContext)
        userDetailsEntity.login = userDetails.login!
        
        try persistenceManager.backgroundContext.save()
        
        let request = UserDetailsRequest(username: userDetails.login!)
        
        userDetailsPersistenceService.save(note: "test", request: request, completion: {_ in })
        let expectation = self.expectation(description: "User search note match test")
        
        userDetailsPersistenceService.getResponse(for: request) { (result) in
            switch result {
            case .success(let user):
                guard let user = user, user.viewed, user.note == "test" else { return }
                expectation.fulfill()
            case .failure(_): break
            }
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - Merge Policy tests

    func testStoreMergePolicy() throws {
        let expectation = self.expectation(description: "User response write test")

        let user = ModelGenerator.generateUserEntity(id: 1, in: persistenceManager.backgroundContext)
        try persistenceManager.backgroundContext.save()
        // first users viewed property is false

        let userDetailsRequest = UserDetailsRequest(username: user.login!)
        let userDetails = ModelGenerator.generateUserDetails(id: 1)
        userDetailsPersistenceService.save(request: userDetailsRequest, response: userDetails) { (error) in
            guard error == nil else { return }
            // first users viewed property is true
            saveUserListAndValidateUserData()
        }
        
        func saveUserListAndValidateUserData() {
            let _ = ModelGenerator.generateUserEntityList(10, in: persistenceManager.backgroundContext)
            try? persistenceManager.backgroundContext.save()
            // first users viewed property should be true as the user list save should not override the viewed property with the current(store trump) merge policy the store value take precidence over in memory value.
            validate()
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

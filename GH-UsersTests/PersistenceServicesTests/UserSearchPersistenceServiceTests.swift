//
//  UserSearchPersistenceServiceTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users

class UserSearchPersistenceServiceTests: XCTestCase {

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

}

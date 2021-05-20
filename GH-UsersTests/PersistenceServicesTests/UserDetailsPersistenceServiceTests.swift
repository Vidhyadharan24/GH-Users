//
//  UserDetailsPersistenceServiceTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
@testable import GH_Users

class UserDetailsPersistenceServiceTests: XCTestCase {

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

}

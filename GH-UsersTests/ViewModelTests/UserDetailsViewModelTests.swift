//
//  UserDetailsViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
import Combine

@testable import GH_Users

class UserDetailsViewModelTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    var mockUserDetailsRepository: MockUserDetailsRepository!

    var userDetailsViewModel: UserDetailsViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        mockUserDetailsRepository = MockUserDetailsRepository()
    }

    override func tearDownWithError() throws {
        persistenceManager = nil

        mockImageRepository = nil
        mockUserDetailsRepository = nil

        userDetailsViewModel = nil
        
        cancellableSet.removeAll()
    }

    func testUserDetailsViewModelDetailsCachedData() throws {
        let expectation = self.expectation(description: "Note should be saved")
        
        let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)
        
        mockUserDetailsRepository.cachedUserDetails = user
        mockUserDetailsRepository.liveError = NetworkDecodableServiceError.networkFailure(.notConnected)
        
        userDetailsViewModel = UserDetailsViewModel(user: user, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
        
        var dataTypes: [UserDetailsDataType] = []
        userDetailsViewModel.dataType.sink { (dataType) in
            dataTypes.append(dataType)
        }.store(in: &cancellableSet)

        userDetailsViewModel.loading.sink { (loading) in
            guard case .none = loading else { return }
            let arr = dataTypes.dropFirst()
            guard let dataType = arr.last, dataType == .cached else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userDetailsViewModel.viewDidLoad()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserDetailsViewModelDetailsCachedAndLiveData() throws {
        let expectation = self.expectation(description: "Note should be saved")
        
        let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)
        
        mockUserDetailsRepository.cachedUserDetails = user
        mockUserDetailsRepository.liveUserDetails = user
        
        userDetailsViewModel = UserDetailsViewModel(user: user, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
        
        var dataTypes: [UserDetailsDataType] = []
        userDetailsViewModel.dataType.sink { (dataType) in
            dataTypes.append(dataType)
        }.store(in: &cancellableSet)

        userDetailsViewModel.loading.sink { (loading) in
            guard case .none = loading else { return }
            let arr = dataTypes.dropFirst()
            guard let first = arr.first, let second = arr.last, arr.count == 2,
                  first == .cached, second == .live else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userDetailsViewModel.viewDidLoad()
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    // MARK: BUGFix - No actual data model tests (e.g. testing the save note logic)
    
    func testUserDetailsViewModelSaveNoteSuccess() throws {
        let expectation = self.expectation(description: "Note should be saved")
        
        let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)
        
        userDetailsViewModel = UserDetailsViewModel(user: user, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
        
        userDetailsViewModel.noteSaved.sink { (msg) in
            guard let msg = msg, msg.count > 0 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userDetailsViewModel.save(note: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUserDetailsViewModelSaveNoteError() throws {
        let expectation = self.expectation(description: "Note save should return error")

        mockUserDetailsRepository.saveNoteError = UserDetailsPeristanceServiceError.invalidNote
        
        let user = ModelGenerator.generateUserDetailsEntity(id: 1, in: persistenceManager.viewContext)
        
        userDetailsViewModel = UserDetailsViewModel(user: user, repository: mockUserDetailsRepository, imageRespository: mockImageRepository)
        
        userDetailsViewModel.noteSaveError.sink { (error) in
            guard let error = error, error.count > 0 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userDetailsViewModel.save(note: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}

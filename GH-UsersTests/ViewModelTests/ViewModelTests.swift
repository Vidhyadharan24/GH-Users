//
//  ViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import XCTest
import Combine
import CoreData

@testable import GH_Users


class ViewModelTests: XCTestCase {
    var persistenceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    
    var mockUsersListRepository: MockUsersListRepository!
    var mockSearchUsersRepository: MockSearchUsersRepository!
    var mockUserDetailsRepository: MockUserDetailsRepository!

    var userListViewModel: UsersListViewModel!
    var usersSearchViewModel: LocalUsersSearchViewModel!
    var userDetailsViewModel: UserDetailsViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        
        mockUsersListRepository = MockUsersListRepository()
        mockSearchUsersRepository = MockSearchUsersRepository()
        mockUserDetailsRepository = MockUserDetailsRepository()
    }

    override func tearDownWithError() throws {
        persistenceManager = nil

        mockUsersListRepository = nil
        mockSearchUsersRepository = nil
        mockUserDetailsRepository = nil

        userListViewModel = nil
        usersSearchViewModel = nil
        userDetailsViewModel = nil
        
        cancellableSet.removeAll()
    }
    
    // MARK: - UsersListViewModel tests
    
    func testUserListViewModelNoData() throws {
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: nil)
        
        mockUsersListRepository.cacheError = PersistenceError.noData
        mockUsersListRepository.liveError = NetworkDecodableServiceError.networkFailure(.notConnected)
                
        let expectation = self.expectation(description: "View model values are valid when not data from cache and network")
        
        Publishers.CombineLatest(userListViewModel.loading, userListViewModel.offline).sink { [weak self] (result) in
            guard case .none = result.0, result.1 else { return }
            guard self?.userListViewModel.isEmpty == true else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userListViewModel.viewDidLoad()

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserListViewModelCachedData() throws {
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: nil)
        
        mockUsersListRepository.cachedUserList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        mockUsersListRepository.liveError = NetworkDecodableServiceError.networkFailure(.notConnected)
                
        let expectation = self.expectation(description: "View model values are valid when data is from cache and network returns error")
        
        var dataTypes: [UsersListDataType] = []
        userListViewModel.dataType.sink { (dataType) in
            dataTypes.append(dataType)
        }.store(in: &cancellableSet)

        userListViewModel.loading.sink { (loading) in
            guard case .none = loading else { return }
            let arr = dataTypes.dropFirst()
            guard let last = arr.last, last == .cached else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)

        userListViewModel.viewDidLoad()

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserListViewModelLiveData() throws {
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: nil)
        
        mockUsersListRepository.cacheError = PersistenceError.noData
        mockUsersListRepository.liveUserList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
                
        let expectation = self.expectation(description: "View model values are valid when data is from cache and network returns error")
        
        var dataTypes: [UsersListDataType] = []
        userListViewModel.dataType.sink { (dataType) in
            dataTypes.append(dataType)
        }.store(in: &cancellableSet)

        userListViewModel.loading.sink { (loading) in
            guard case .none = loading else { return }
            let arr = dataTypes.dropFirst()
            guard let last = arr.last, last == .live else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        userListViewModel.viewDidLoad()

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserListViewModelCachedAndLiveData() throws {
        userListViewModel = UsersListViewModel(repository: mockUsersListRepository, imageRepository: mockImageRepository, actions: nil)
        
        mockUsersListRepository.cachedUserList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        mockUsersListRepository.liveUserList = mockUsersListRepository.cachedUserList
                
        let expectation = self.expectation(description: "Both cached data and live data are avaialble")
        
        var dataTypes: [UsersListDataType] = []
        userListViewModel.dataType.sink { (dataType) in
            dataTypes.append(dataType)
        }.store(in: &cancellableSet)

        userListViewModel.loading.sink { (loading) in
            guard case .none = loading else { return }
            let arr = dataTypes.dropFirst()
            guard let first = arr.first, let second = arr.last, arr.count == 2,
                  first == .cached, second == .live else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)

        userListViewModel.viewDidLoad()

        waitForExpectations(timeout: 1, handler: nil)
    }
    

    // MARK: - UsersSearchViewModel tests
    func testUserSearchViewModelNoData() throws {
        let expectation = self.expectation(description: "View model should no return any data")

        usersSearchViewModel = LocalUsersSearchViewModel(repository: mockSearchUsersRepository, imageRepository: mockImageRepository, actions: nil)
        mockSearchUsersRepository.error = PersistenceError.noData
        
        usersSearchViewModel.userViewModels.sink { (result) in
            guard result.count == 0 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        usersSearchViewModel.didSearch(query: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testUserSearchViewModelValidData() throws {
        let expectation = self.expectation(description: "View model should return users data for query")

        usersSearchViewModel = LocalUsersSearchViewModel(repository: mockSearchUsersRepository, imageRepository: mockImageRepository, actions: nil)
        mockSearchUsersRepository.userList = ModelGenerator.generateUserEntityList(10, in: persistenceManager.viewContext)
        
        usersSearchViewModel.userViewModels.sink { (result) in
            guard result.count == 10 else { return }
            expectation.fulfill()
        }.store(in: &cancellableSet)
        
        usersSearchViewModel.didSearch(query: "test")
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - UserDetailsViewModel Notes tests
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

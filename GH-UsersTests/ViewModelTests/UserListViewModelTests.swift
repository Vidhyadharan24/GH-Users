//
//  UserListViewModelTests.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 20/05/21.
//

import XCTest
import Combine

@testable import GH_Users


class UserListViewModelTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    
    var mockImageRepository: MockImageRepository!
    var mockUsersListRepository: MockUsersListRepository!

    var userListViewModel: UsersListViewModel!
    
    var cancellableSet = Set<AnyCancellable>()

    override func setUpWithError() throws {
        persistenceManager = PersistenceManager(inMemory: true)
        
        mockImageRepository = MockImageRepository()
        mockUsersListRepository = MockUsersListRepository()
    }

    override func tearDownWithError() throws {
        persistenceManager = nil

        mockImageRepository = nil
        mockUsersListRepository = nil
        
        userListViewModel = nil
        
        cancellableSet.removeAll()
    }

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

}

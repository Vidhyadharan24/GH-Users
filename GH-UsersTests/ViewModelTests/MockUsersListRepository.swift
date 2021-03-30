//
//  MockUsersListRepository.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import UIKit
@testable import GH_Users

class MockUsersListRepository: UsersListRepositoryProtocol {
    var cachedUserList: [UserEntity]?
    var cacheError: Error?

    var liveUserList: [UserEntity]?
    var liveError: Error?

    func fetchUsersList(since: Int, cached: @escaping (Result<[UserEntity], Error>) -> Void, completion: @escaping (Result<[UserEntity], Error>) -> Void) -> Cancellable? {
        if let error = cacheError {
            cached(.failure(error))
        } else if let userList = cachedUserList {
            cached(.success(userList))
        }
        
        if let error = liveError {
            completion(.failure(error))
            return MockCancellable()
        }
        
        completion(.success(liveUserList ?? []))

        return MockCancellable()
    }
    

}

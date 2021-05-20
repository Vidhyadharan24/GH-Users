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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            if let error = self?.cacheError {
                cached(.failure(error))
            } else if let userList = self?.cachedUserList {
                cached(.success(userList))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let error = self?.liveError {
                completion(.failure(error))
            } else {
                completion(.success(self?.liveUserList ?? []))
            }
        }

        return MockCancellable()
    }
    

}

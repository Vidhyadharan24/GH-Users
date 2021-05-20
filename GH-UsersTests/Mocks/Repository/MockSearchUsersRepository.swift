//
//  MockSearchUsersRepository.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import UIKit
@testable import GH_Users

class MockSearchUsersRepository: LocalUsersSearchRepositoryProtocol {
    var userList: [UserEntity]?
    var error: Error?
    
    func fetchUsers(for queryString: String, cached: @escaping (Result<[UserEntity]?, Error>) -> Void) -> Cancellable? {
        if let error = error {
            cached(.failure(error))
            return MockCancellable()
        }
        cached(.success(userList))
        return MockCancellable()
    }
    

}

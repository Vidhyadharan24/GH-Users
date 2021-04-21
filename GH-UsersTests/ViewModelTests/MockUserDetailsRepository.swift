//
//  MockUserDetailsRepository.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import UIKit
@testable import GH_Users

class MockUserDetailsRepository: UserDetailsRepositoryProtocol {
    var cachedUserDetails: UserEntity?
    var cacheError: Error?

    var liveUserDetails: UserEntity?
    var liveError: Error?

    func fetchUserDetails(username: String, cached: @escaping (Result<UserEntity?, Error>) -> Void, completion: @escaping (Result<UserEntity?, Error>) -> Void) -> Cancellable? {
        if let error = cacheError {
            cached(.failure(error))
        } else if let userDetails = cachedUserDetails {
            cached(.success(userDetails))
        }
        
        if let error = liveError {
            completion(.failure(error))
            return MockCancellable()
        }
        
        completion(.success(liveUserDetails))

        return MockCancellable()
    }
    
    func save(note: String, username: String?, completion: @escaping (Error?) -> Void) {
    }
}

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

    var saveNoteError: Error?
    
    func fetchUserDetails(username: String, cached: @escaping (Result<UserEntity?, Error>) -> Void, completion: @escaping (Result<UserEntity?, Error>) -> Void) -> Cancellable? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let error = self?.cacheError {
                cached(.failure(error))
            } else if let userDetails = self?.cachedUserDetails {
                cached(.success(userDetails))
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let error = self?.liveError {
                completion(.failure(error))
            } else {
                completion(.success(self?.liveUserDetails))
            }
        }
        return MockCancellable()
    }
    
    func save(note: String, username: String?, completion: @escaping (Error?) -> Void) {
        completion(saveNoteError)
    }
}

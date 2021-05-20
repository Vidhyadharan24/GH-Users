//
//  MockLocalUsersSearchPersistenceService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockLocalUsersSearchPersistenceService: LocalUsersSearchPersistenceServiceProtocol {
    var usersListResponse: [UserEntity]?
    var persistenceError: PersistenceError?

    func getResponse(for request: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void) {
        if let error = persistenceError {
            completion(.failure(error))
            return
        }
        
        completion(.success(usersListResponse))
    }
}

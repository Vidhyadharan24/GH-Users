//
//  MockUserListPersistenceService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockUserListPersistenceService: UsersListPersistenceServiceProtocol {
    var usersListResponse: [UserEntity]?
    var persistenceError: PersistenceError?

    
    func getResponse(for request: UsersListRequest, completion: @escaping (Result<[UserEntity]?, PersistenceError>) -> Void) {
        if let error = persistenceError {
            completion(.failure(error))
            return
        }
        
        completion(.success(usersListResponse))
    }
    
    func save(response: UsersListResponse, completion: @escaping (PersistenceError?) -> Void) {
        completion(persistenceError)
    }
}

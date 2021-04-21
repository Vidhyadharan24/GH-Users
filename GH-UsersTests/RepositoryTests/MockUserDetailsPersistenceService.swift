//
//  MockUserDetailsPersistenceService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockUserDetailsPersistenceService: UserDetailsPersistenceServiceProtocol {
    var userDetails: UserEntity?
    var persistenceError: Error?
    
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, Error>) -> Void) {
        if let error = persistenceError {
            completion(.failure(error))
            return
        }
        
        completion(.success(userDetails))
    }
    
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (Error?) -> Void) {
        completion(persistenceError)
    }
    
    func save(note: String, request: UserDetailsRequest, completion: @escaping (Error?) -> Void) {
        completion(persistenceError)
    }
    

}

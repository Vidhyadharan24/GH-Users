//
//  MockUserDetailsPersistenceService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockUserDetailsPersistenceService: UserDetailsPersistanceServiceProtocol {
    var userDetails: UserEntity?
    var persistanceError: PersistanceError?
    
    func getResponse(for request: UserDetailsRequest, completion: @escaping (Result<UserEntity?, PersistanceError>) -> Void) {
        if let error = persistanceError {
            completion(.failure(error))
            return
        }
        
        completion(.success(userDetails))
    }
    
    func save(request: UserDetailsRequest, response: UserDetailsResponse, completion: @escaping (PersistanceError?) -> Void) {
        completion(persistanceError)
    }
    
    func save(note: String, request: UserDetailsRequest, completion: @escaping (PersistanceError?) -> Void) {
        completion(persistanceError)
    }
    

}

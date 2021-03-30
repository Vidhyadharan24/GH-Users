//
//  MockLocalUsersSearchPersistanceService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockLocalUsersSearchPersistanceService: LocalUsersSearchPersistanceServiceProtocol {
    var usersListResponse: [UserEntity]?
    var persistanceError: PersistanceError?

    func getResponse(for request: LocalUsersSearchQuery, completion: @escaping (Result<[UserEntity]?, PersistanceError>) -> Void) {
        if let error = persistanceError {
            completion(.failure(error))
            return
        }
        
        completion(.success(usersListResponse))
    }
}

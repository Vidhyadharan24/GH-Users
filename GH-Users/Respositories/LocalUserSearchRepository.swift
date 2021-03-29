//
//  LocalUserSearchRepository.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import Foundation

public protocol LocalUsersSearchRepositoryProtocol {
    func fetchUsers(for queryString: String,
                         cached: @escaping (Result<[UserEntity]?, Error>) -> Void) -> Cancellable?
}

final class LocalUsersSearchRepository: LocalUsersSearchRepositoryProtocol {
    private let persistantStorageService: LocalUsersSearchPersistanceServiceProtocol

    init(persistantStorageService: LocalUsersSearchPersistanceServiceProtocol) {
        self.persistantStorageService = persistantStorageService
    }
    
    func fetchUsers(for queryString: String, cached: @escaping (Result<[UserEntity]?, Error>) -> Void) -> Cancellable? {
        let request = LocalUsersSearchQuery(query: queryString)
        
        let task = RepositoryTask()
        
        persistantStorageService.getResponse(for: request) { (result) in
            guard !task.isCancelled else { return }

            switch result {
            case .success(let users):
                cached(.success(users ?? []))
            case .failure(let error):
                cached(.failure(error))
            }
        }
        
        return task
    }
}

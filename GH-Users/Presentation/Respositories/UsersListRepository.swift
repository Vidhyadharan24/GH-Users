//
//  UsersListRepository.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public protocol UsersListRepositoryProtocol {
    func fetchUsersList(since: Int,
                        cached: @escaping (Result<[UserEntity], Error>) -> Void,
                        completion: @escaping (Result<[UserEntity], Error>) -> Void) -> Cancellable?
}

final class UsersListRepository: UsersListRepositoryProtocol {
    
    private let networkDecodableService: NetworkDecodableServiceProtocol
    private let persistenceService: UsersListPersistenceServiceProtocol

    init(networkDecodableService: NetworkDecodableServiceProtocol, persistenceService: UsersListPersistenceServiceProtocol) {
        self.networkDecodableService = networkDecodableService
        self.persistenceService = persistenceService
    }
    
    public func fetchUsersList(since: Int, cached: @escaping (Result<[UserEntity], Error>) -> Void, completion: @escaping (Result<[UserEntity], Error>) -> Void) -> Cancellable? {
        let request = UsersListRequest(since: since)
        
        let task = RepositoryTask()
        
        persistenceService.getResponse(for: request) { (result) in
            guard !task.isCancelled else { return }

            switch result {
            case .success(let users):
                cached(.success(users ?? []))
            case .failure(let error):
                cached(.failure(error))
            }
        }
                    
        let endpoint = APIEndpoints.getUsers(with: request)
        task.task = self.networkDecodableService.request(with: endpoint) { result in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success(let response):
                self.persistenceService.save(response: response) { (error) in
                    guard !task.isCancelled else { return }
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.persistenceService.getResponse(for: request) { (result) in
                            guard !task.isCancelled else { return }
                            switch result {
                            case .success(let response):
                                completion(.success(response!))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}

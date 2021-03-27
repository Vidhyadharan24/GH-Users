//
//  UserDetailsRepository.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public protocol UserDetailsRepositoryProtocol {
    func fetchUserDetails(username: String,
                         cached: @escaping (Result<UserEntity?, Error>) -> Void,
                         completion: @escaping (Result<UserEntity?, Error>) -> Void) -> Cancellable?
}

final class UserDetailsRepository: UserDetailsRepositoryProtocol {
    
    private let networkDecodableService: NetworkDecodableServiceProtocol
    private let persistantStorageService: UserDetailsPersistanceServiceProtocol

    init(networkDecodableService: NetworkDecodableServiceProtocol, persistantStorageService: UserDetailsPersistanceServiceProtocol) {
        self.networkDecodableService = networkDecodableService
        self.persistantStorageService = persistantStorageService
    }
    
    func fetchUserDetails(username: String, cached: @escaping (Result<UserEntity?, Error>) -> Void, completion: @escaping (Result<UserEntity?, Error>) -> Void) -> Cancellable? {
        let request = UserDetailsRequest(username: username)
        let task = RepositoryTask()
        
        persistantStorageService.getResponse(for: request) { (result) in
            switch result {
            case .success(let user):
                cached(.success(user))
            case .failure(let error):
                cached(.failure(error))
            }
        
            guard !task.isCancelled else { return }
            let endpoint = APIEndpoints.getUserDetails(with: request)
            
            task.task = self.networkDecodableService.request(with: endpoint) { result in
                switch result {
                case .success(let response):
                    self.persistantStorageService.save(response: response) { (error) in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.persistantStorageService.getResponse(for: request) { (result) in
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
        }
        
        return task
    }

}

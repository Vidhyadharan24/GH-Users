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
    
    func save(note: String, username: String?)
}

final class UserDetailsRepository: UserDetailsRepositoryProtocol {
    
    private let networkDecodableService: NetworkDecodableServiceProtocol
    private let persistantPersistanceService: UserDetailsPersistanceServiceProtocol

    init(networkDecodableService: NetworkDecodableServiceProtocol, persistantPersistanceService: UserDetailsPersistanceServiceProtocol) {
        self.networkDecodableService = networkDecodableService
        self.persistantPersistanceService = persistantPersistanceService
    }
    
    func fetchUserDetails(username: String, cached: @escaping (Result<UserEntity?, Error>) -> Void, completion: @escaping (Result<UserEntity?, Error>) -> Void) -> Cancellable? {
        let request = UserDetailsRequest(username: username)
        let task = RepositoryTask()
        
        persistantPersistanceService.getResponse(for: request) { (result) in
            guard !task.isCancelled else { return }
            
            switch result {
            case .success(let user):
                cached(.success(user))
            case .failure(let error):
                cached(.failure(error))
            }
        
            let endpoint = APIEndpoints.getUserDetails(with: request)
            
            task.task = self.networkDecodableService.request(with: endpoint) { result in
                guard !task.isCancelled else { return }

                switch result {
                case .success(let response):
                    self.persistantPersistanceService.save(request: request, response: response) { (error) in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.persistantPersistanceService.getResponse(for: request) { (result) in
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
    
    func save(note: String, username: String?) {
        guard let name = username else { return }
        let request = UserDetailsRequest(username: name)

        persistantPersistanceService.save(note: note, request: request)
    }
}

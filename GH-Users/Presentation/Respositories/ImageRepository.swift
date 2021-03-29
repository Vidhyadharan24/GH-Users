//
//  ImageRepository.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import Foundation

public protocol ImageRepositoryProtocol {
    func fetchImage(with urlString: String, completion: @escaping (Result<Data?, Error>) -> Void) -> Cancellable?
}

final class ImageRepository {
    
    private let networkDecodableService: NetworkDecodableServiceProtocol
    private let imageCacheService: ImageCacheServiceProtocol

    init(networkDecodableService: NetworkDecodableServiceProtocol, imageCacheService: ImageCacheServiceProtocol) {
        self.networkDecodableService = networkDecodableService
        self.imageCacheService = imageCacheService
    }
}

extension ImageRepository: ImageRepositoryProtocol {
    
    public func fetchImage(with urlString: String, completion: @escaping (Result<Data?, Error>) -> Void) -> Cancellable? {
        let task = RepositoryTask()
        
        task.task = imageCacheService.getImageFor(url: urlString) { (result) in
            guard !task.isCancelled else { return }

            switch result {
            case .success(let imageData):
                completion(.success(imageData))
                return
            case .failure(let error):
                completion(.failure(error))
            }        
            
            let endpoint = APIEndpoints.imageEndPoint(with: urlString)
            task.task = self.networkDecodableService.request(with: endpoint) { result in
                guard !task.isCancelled else { return }
                switch result {
                case .success(let response):
                    self.imageCacheService.write(imageData: response, for: urlString, completion: { (result) in
                        guard !task.isCancelled else { return }
                        completion(.success(response))
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}

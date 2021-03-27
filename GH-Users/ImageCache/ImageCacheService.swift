//
//  ImageCacheService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import UIKit
import CryptoKit

public enum ImageCacheServiceError: Error {
    case noImage
}

public protocol ImageCacheServiceProtocol {
    typealias CompletionHandler = (Result<Data?, ImageCacheServiceError>) -> Void
    func getImageFor(url: String, completion: @escaping CompletionHandler) -> Cancellable
    
    func write(imageData: Data, for url: String, completion: @escaping CompletionHandler)
}

public class ImageCacheService: ImageCacheServiceProtocol {
    
    private lazy var imageQueue: OperationQueue = {
        let networkQueue = OperationQueue()
        networkQueue.maxConcurrentOperationCount = 1
        return networkQueue
    }()
    
    private var imagePersistanceManager: ImagePersistanceManagerProtocol
    
    private var imageMemoryCache: [String: Data] = [:]
    
    init(imagePersistanceManager: ImagePersistanceManagerProtocol) {
        self.imagePersistanceManager = imagePersistanceManager
        
        NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil,
                                               queue: imageQueue) { [weak self] (_) in
            self?.imageMemoryCache.removeAll()
        }
    }
    
    public func getImageFor(url: String, completion: @escaping CompletionHandler) -> Cancellable {
        let blockOperation = BlockOperation.init { [weak self] in
            guard let self = self else { return }
            let fileName = self.md5(string: url)
            
            if FileManager.default.fileExists(atPath: fileName) {
                if let data = self.imageMemoryCache[fileName] {
                    completion(.success(data))
                    return
                }
                let result = self.imagePersistanceManager.getImageFor(fileName: fileName)
                switch result {
                case .success(let data):
                    self.imageMemoryCache[fileName] = data
                    completion(.success(data))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(.noImage))
                }
            }
            completion(.failure(.noImage))
        }
        
        imageQueue.addOperation(blockOperation)
        
        return blockOperation
    }
    
    public func write(imageData: Data, for url: String, completion: @escaping CompletionHandler) {
        let blockOperation = BlockOperation.init { [weak self] in
            guard let self = self else { return }
            let fileName = self.md5(string: url)
            self.imageMemoryCache[fileName] = imageData
            
            let result = self.imagePersistanceManager.write(data: imageData, fileName: fileName)
            
            switch result {
            case .success(let data):
                self.imageMemoryCache[fileName] = data
                completion(.success(data))
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.noImage))
            }
        }
        
        imageQueue.addOperation(blockOperation)
    }
    
}

extension ImageCacheService {
    private func md5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

}
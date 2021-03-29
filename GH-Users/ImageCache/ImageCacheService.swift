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
    
    func write(imageData: Data, for url: String, completion: @escaping (Error?) -> Void)
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
        
        setupObservers()
    }
    
    func setupObservers() {
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
            
            if let data = self.imageMemoryCache[fileName] {
                return DispatchQueue.main.async { return completion(.success(data)) }
            }
            
            let result = self.imagePersistanceManager.getImageFor(fileName: fileName)
            switch result {
            case .success(let data):
                self.imageMemoryCache[fileName] = data
                DispatchQueue.main.async { return completion(.success(data)) }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async { return completion(.failure(.noImage)) }
            }
        }
        
        imageQueue.addOperation(blockOperation)
        
        return blockOperation
    }
    
    public func write(imageData: Data, for url: String, completion: @escaping (Error?) -> Void) {
        let blockOperation = BlockOperation.init { [weak self] in
            guard let self = self else { return }
            let fileName = self.md5(string: url)
            self.imageMemoryCache[fileName] = imageData
            
            let error = self.imagePersistanceManager.write(data: imageData, fileName: fileName)
            
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async { return completion(error) }
            } else {
                self.imageMemoryCache[fileName] = imageData
                DispatchQueue.main.async { return completion(nil) }
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

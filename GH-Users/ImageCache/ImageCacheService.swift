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
    typealias CompletionHandler = (Result<UIImage?, ImageCacheServiceError>) -> Void
    func getImageFor(url: String, completion: @escaping CompletionHandler) -> Cancellable
    
    func write(imageData: Data, for url: String)
}

public class ImageCacheService: ImageCacheServiceProtocol {
    
    private lazy var imageQueue: OperationQueue = {
        let networkQueue = OperationQueue()
        networkQueue.maxConcurrentOperationCount = 1
        return networkQueue
    }()
    
    private var imagePersistanceManager: ImagePersistanceManagerProtocol
    
    private var imageMemoryCache: [String: UIImage] = [:]
    
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
            guard let fileName = self?.md5(string: url) else { return }
            
            if FileManager.default.fileExists(atPath: fileName) {
                if let image = self?.imageMemoryCache[fileName] {
                    completion(.success(image))
                    return
                }
                if let image = UIImage(contentsOfFile: fileName) {
                    self?.imageMemoryCache[fileName] = image
                    completion(.success(image))
                    return
                }
            }
            completion(.failure(.noImage))
        }
        
        imageQueue.addOperation(blockOperation)
        
        return blockOperation
    }
    
    public func write(imageData: Data, for url: String) {
        let blockOperation = BlockOperation.init { [weak self] in
            guard let image = UIImage(data: imageData) else { return }
            guard let fileName = self?.md5(string: url) else { return }
            self?.imageMemoryCache[fileName] = image
            
            self?.imagePersistanceManager.write(image: image, fileName: fileName)
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

//
//  NetworkOperationsManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 25/03/21.
//

import Foundation

public protocol NetworkCancellable {
    func cancel()
}

extension BlockOperation: NetworkCancellable {}

public protocol NetworkOperationsManagerProtocol {
    typealias CompletionHandler = ((Data?, URLResponse?, Error?) -> Void)

    func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
}

public class NetworkOperationsManager: NetworkOperationsManagerProtocol {
    
    lazy var networkQueue: OperationQueue = {
        let networkQueue = OperationQueue()
        networkQueue.maxConcurrentOperationCount = 1
        return networkQueue
    }()
    
    public init() {}
    
    public func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let blockOperation = BlockOperation.init {
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        }
        networkQueue.addOperation(blockOperation)
        
        return blockOperation
    }
    
}


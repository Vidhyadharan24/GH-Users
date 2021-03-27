//
//  NetworkOperationsManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public protocol NetworkOperationsManagerProtocol {
    typealias CompletionHandler = ((Data?, URLResponse?, Error?) -> Void)

    func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> Cancellable
}

public class NetworkOperationsManager: NetworkOperationsManagerProtocol {
    
// REQUIRED TASK: All ​network calls​ must be ​queued​ and ​limited​ to ​1​ request at a time.
// Queuing network task in a an operation queue to limit the max request to 1 at a time.
    lazy var networkQueue: OperationQueue = {
        let networkQueue = OperationQueue()
        networkQueue.maxConcurrentOperationCount = 1
        return networkQueue
    }()
    
    public init() {}
    
    public func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> Cancellable {
        let blockOperation = BlockOperation.init {
            let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
            task.resume()
        }
        networkQueue.addOperation(blockOperation)
        
        return blockOperation
    }
    
}


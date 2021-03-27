//
//  NetworkSessionManager.swift
//  GH-Users
//
//  Created by Vidhyadharan on 25/03/21.
//

import Foundation

public protocol NetworkCancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable {}

public protocol NetworkSessionManagerProtocol {
    typealias CompletionHandler = ((Data?, URLResponse?, Error?) -> Void)

    func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable
}

public class NetworkSessionManager: NetworkSessionManagerProtocol {
    
    public init() {}
    
    public func request(urlRequest: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
        task.resume()
        return task
    }
    
}


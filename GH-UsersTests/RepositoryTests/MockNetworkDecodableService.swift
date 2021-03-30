//
//  MockNetworkDecodableService.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
@testable import GH_Users

class MockNetworkDecodableService: NetworkDecodableServiceProtocol {
    var error: NetworkDecodableServiceError?
    var decodable: Decodable?
    
    func request<T, E>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> Cancellable? where T : Decodable, T == E.Response, E : DecodableAPIRequest {
        if let error = error {
            completion(.failure(error))
            return MockCancellable()
        }
        completion(.success(decodable as! T))
        return MockCancellable()
    }
    
    func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> Cancellable? where E : DecodableAPIRequest, E.Response == Void {
        return MockCancellable()
    }
}

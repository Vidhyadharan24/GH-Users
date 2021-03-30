//
//  MockImageRepository.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 31/03/21.
//

import UIKit
@testable import GH_Users

class MockImageRepository: ImageRepositoryProtocol {
    var imageData: Data?
    var error: Error?
    
    func fetchImage(with urlString: String, completion: @escaping (Result<Data?, Error>) -> Void) -> Cancellable? {
        if let error = error {
            completion(.failure(error))
            return MockCancellable()
        }
        completion(.success(imageData))
        return MockCancellable()
    }
    

}

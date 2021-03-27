//
//  NetworkDecodableService.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public enum NetworkDecodableServiceError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkDataServiceError)
    case resolvedNetworkFailure(Error)
}

public protocol NetworkDecodableServiceProtocol {
    typealias CompletionHandler<T> = (Result<T, NetworkDecodableServiceError>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: DecodableAPIRequest>(with endpoint: E,
                                                       completion: @escaping CompletionHandler<T>) -> Cancellable? where E.Response == T
    @discardableResult
    func request<E: DecodableAPIRequest>(with endpoint: E,
                                         completion: @escaping CompletionHandler<Void>) -> Cancellable? where E.Response == Void
}

public final class NetworkDecodableService {
    private let networkService: NetworkDataService
    private let errorResolver: NetworkDecodableServiceErrorResolverProtocol
    private let errorLogger: NetworkDecodableServiceErrorLoggerProtocol
    
    public init(with networkService: NetworkDataService,
                errorResolver: NetworkDecodableServiceErrorResolverProtocol = NetworkDecodableServiceErrorResolver(),
                errorLogger: NetworkDecodableServiceErrorLoggerProtocol = NetworkDecodableServiceErrorLogger()) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension NetworkDecodableService: NetworkDecodableServiceProtocol {
    public func request<T: Decodable, E: DecodableAPIRequest>(with endpoint: E,
                                                              completion: @escaping CompletionHandler<T>) -> Cancellable? where E.Response == T {

        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, NetworkDecodableServiceError> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    public func request<E>(with endpoint: E, completion: @escaping CompletionHandler<Void>) -> Cancellable? where E : DecodableAPIRequest, E.Response == Void {
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                DispatchQueue.main.async { return completion(.success(())) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        }
    }

    // MARK: - Private
    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, NetworkDecodableServiceError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkDataServiceError) -> NetworkDecodableServiceError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkDataServiceError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

// MARK: - Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

public class RawDataResponseDecoder: ResponseDecoder {
    public init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(codingPath: [CodingKeys.default], debugDescription: "Expected Data type")
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}

// MARK: - Error Resolver

public protocol NetworkDecodableServiceErrorResolverProtocol {
    func resolve(error: NetworkDataServiceError) -> Error
}

public class NetworkDecodableServiceErrorResolver: NetworkDecodableServiceErrorResolverProtocol {
    public init() { }
    public func resolve(error: NetworkDataServiceError) -> Error {
        return error
    }
}

// MARK: - Logger

public protocol NetworkDecodableServiceErrorLoggerProtocol {
    func log(error: Error)
}

public final class NetworkDecodableServiceErrorLogger: NetworkDecodableServiceErrorLoggerProtocol {
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}



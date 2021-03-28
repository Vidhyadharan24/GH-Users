//
//  ApiConfig.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

public struct ApiConfig {
    public let baseURL: String?
    public let maxRetryCount: Int
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
     public init(baseURL: String? = nil,
                 maxRetryCount: Int = 5,
                 headers: [String: String] = [:],
                 queryParameters: [String: String] = [:]) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
        self.maxRetryCount = maxRetryCount
    }
}


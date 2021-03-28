//
//  DIContainer.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

final class AppDIContainer {
    
    lazy var appConfig = AppConfig()
    lazy var networkOperationManager = NetworkOperationsManager()
    
    // MARK: - Network
    lazy var apiDecodableService: NetworkDecodableServiceProtocol = {
        let config = ApiConfig(baseURL: appConfig.apiBaseURL, maxRetryCount: appConfig.maxRequestRetryCount)
        
        let apiDataService = NetworkDataService(config: config, sessionManager: networkOperationManager)
        return NetworkDecodableService(with: apiDataService)
    }()
    lazy var imageDecodableService: NetworkDecodableServiceProtocol = {
        let config = ApiConfig(maxRetryCount: appConfig.maxRequestRetryCount)
        let imagesDataService = NetworkDataService(config: config, sessionManager: networkOperationManager)
        return NetworkDecodableService(with: imagesDataService)
    }()
    
    // MARK: - DIContainers of scenes
    func makeUsersSceneDIContainer() -> UsersSceneDIContainer {
        return UsersSceneDIContainer(appConfig: appConfig, apiDecodableService: apiDecodableService,
                                     imageDecodableService: imageDecodableService)
    }
}

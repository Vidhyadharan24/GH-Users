//
//  AppConfig.swift
//  GH-Usersw
//
//  Created by Vidhyadharan on 27/02/21.
//

import Foundation

public struct AppConfig {
    lazy var apiBaseURL: String = {
        guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
            fatalError("ApiBaseURL must not be empty in plist")
        }
        return apiBaseURL
    }()    
    let maxRequestRetryCount = 5
    let persistantStorageFetchLimit = 30
}

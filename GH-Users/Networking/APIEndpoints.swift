//
//  APIEndpoints.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation

struct APIEndpoints {
    
    static func getUsers(with usersListRequest: UsersListRequest) -> Endpoint<UsersListResponse> {
        return Endpoint(path: "users",
                        method: .get,
                        queryParametersEncodable: ["since": usersListRequest.since])
    }
    
    static func getUserDetails(with userDetailsRequest: UserDetailsRequest) -> Endpoint<UserDetailsResponse> {
        return Endpoint(path: "users/\(userDetailsRequest.username)",
                        method: .get)
    }
    
    static func imageEndPoint(with urlString: String) -> Endpoint<Data> {
        return Endpoint(path: urlString,
                        isFullPath: true,
                        method: .get,
                        responseDecoder: RawDataResponseDecoder())
    }
}

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let usersListResponse = try? newJSONDecoder().decode(UsersListResponse.self, from: jsonData)

import Foundation

// MARK: - UsersListResponseElement
// REQUIRED TASK: Use Codable to inflate models fetched from api.
struct UsersListResponseElement: Codable {
    let login: String?
    let id: Int
    let avatarURL: String?
    let type: TypeEnum?

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case type
    }
}

enum TypeEnum: String, Codable {
    case organization = "Organization"
    case user = "User"
}

typealias UsersListResponse = [UsersListResponseElement]

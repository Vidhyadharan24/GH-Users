// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let userDetailsResponse = try? newJSONDecoder().decode(UserDetailsResponse.self, from: jsonData)

import Foundation

// MARK: - UserDetailsResponse
// REQUIRED TASK: Use Codable to inflate models fetched from api.
struct UserDetailsResponse: Codable {
    let login: String?
    let id: Int
    let avatarURL: String?
    let type: TypeEnum?
    let name, company, blog: String?
    let publicRepos, following: Int?

    enum CodingKeys: String, CodingKey {
        case login, id
        case avatarURL = "avatar_url"
        case type
        case name, company, blog
        case publicRepos = "public_repos"
        case following
    }
}

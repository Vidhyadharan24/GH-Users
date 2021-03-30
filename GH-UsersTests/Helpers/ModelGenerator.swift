//
//  ModelGenerator.swift
//  GH-UsersTests
//
//  Created by Vidhyadharan on 30/03/21.
//

import Foundation
import CoreData
@testable import GH_Users

class ModelGenerator {
    private static let avatarURL = "https://api.github.com/users/vidhyadhara24"

    private static func randomInt() -> Int {
        Int.random(in: 1..<1000)
    }

    static func generateUserListResponse(_ count: Int) -> UsersListResponse {
        return (1...count).map { generateUserElement(id: $0)}
    }

    static func generateUserElement(id: Int) -> UsersListResponseElement {
        return UsersListResponseElement(login: UUID().uuidString , id: id, avatarURL: avatarURL, type: .user)
    }

    static func generateUserDetails(id: Int) -> UserDetailsResponse {
        return UserDetailsResponse(login: UUID().uuidString, id: id, avatarURL: avatarURL, type: .user,
                                   name: UUID().uuidString, company: UUID().uuidString, blog: UUID().uuidString,
                                   publicRepos: randomInt(), following: randomInt())
    }
    
    static func generateUserEntityList(_ count: Int, in context: NSManagedObjectContext) -> [UserEntity] {
        return (1...count).map { generateUserEntity(id: $0, in: context) }
    }

    static func generateUserEntity(id: Int, in context: NSManagedObjectContext) -> UserEntity {
        let entity = UserEntity(context: context)
        entity.id = Int64(id)
        entity.idString = String(id)
        entity.avatarURL = avatarURL
        entity.login = UUID().uuidString
        entity.type = "user"
        
        return entity
    }

    static func generateUserDetailsEntity(id: Int, in context: NSManagedObjectContext) -> UserEntity {
        let entity = UserEntity(context: context)
        entity.id = Int64(id)
        entity.idString = String(id)
        entity.avatarURL = "https://api.github.com/users/vidhyadhara24"
        entity.login = UUID().uuidString
        entity.type = "user"

        entity.name = UUID().uuidString
        entity.blog = UUID().uuidString
        entity.company = UUID().uuidString
        entity.following = Int16(randomInt())
        entity.publicRepos = Int16(randomInt())
        
        entity.viewed = true

        return entity
    }
    
}

//
//  UserEntity+Mapping.swift
//  GH-Users
//
//  Created by Vidhyadharan on 27/03/21.
//

import Foundation
import CoreData

extension UserEntity {
    convenience init(user: UsersListResponseElement, insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.idString = String(user.id)
        self.id = Int64(user.id)
        self.avatarURL = user.avatarURL
        self.type = user.type?.rawValue
        self.login = user.login
    }
    
    func update(user: UserDetailsResponse) {
        self.idString = String(user.id)
        self.id = Int64(user.id)
        self.avatarURL = user.avatarURL
        self.type = user.type?.rawValue
        self.login = user.login
        self.name = user.name
        self.company = user.company
        self.blog = user.blog
        self.publicRepos = Int16(user.publicRepos ?? 0)
        self.following = Int16(user.following ?? 0)
        
        self.viewed = true
    }
}

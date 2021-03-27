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
        self.id = String(user.id)
        self.avatarURL = user.avatarURL
        self.type = user.type?.rawValue
        self.login = user.login
    }
}

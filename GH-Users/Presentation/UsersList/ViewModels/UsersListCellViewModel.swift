//
//  UsersListCellViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import Foundation

public class UserListCellViewModel {
    let id: String
    let imagePath: String?
        
    init(user: UserEntity) {
        self.id = user.id!
        self.imagePath = user.avatarURL
    }
}

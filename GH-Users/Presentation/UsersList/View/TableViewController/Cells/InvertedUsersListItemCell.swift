//
//  InvertedUsersListItemCell.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

class InvertedUsersListItemCell: UsersListItemCell {
    override func set(image: UIImage) {
        let newImage = image.invertImage()
        
        super.set(image: newImage)
    }
}


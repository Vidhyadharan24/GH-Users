//
//  InvertedUsersNoteListItemCell.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

class InvertedUsersNoteListItemCell: UsersListNoteItemCell {
    override func set(image: UIImage?) {
        // REQUIRED TASK: Every fourth avatar's colour should have its (image) colours inverted.
        let newImage = image?.invertImage()
        
        super.set(image: newImage)
    }
}


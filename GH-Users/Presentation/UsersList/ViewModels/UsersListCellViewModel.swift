//
//  UsersListCellViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

public protocol UserListCellViewModelProtocol {
    func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UsersListItemCellProtocol
}

public class UserListCellViewModel {
    let id: String
    let username: String?
    let imagePath: String?
    let typeText: String?
    let note: String?
    let viewed: Bool
    
    let imageRepository: ImageRepositoryProtocol

    init(user: UserEntity, imageRepository: ImageRepositoryProtocol) {
        self.id = user.idString!
        self.username = user.login
        self.imagePath = user.avatarURL
        self.typeText = String(format: NSLocalizedString("Account type: %@", comment: ""), user.type ?? "User")
        self.note = user.note
        self.viewed = user.viewed
        
        self.imageRepository = imageRepository
    }
}

extension UserListCellViewModel: UserListCellViewModelProtocol {
    public func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UsersListItemCellProtocol {
        let cell: UsersListItemCellProtocol
        
        let isInvertedCell = (indexPath.row + 1) % 4 == 0
        let isNoteAvailable = note != nil
        
        switch (isInvertedCell, isNoteAvailable) {
        case (false, false):
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UsersListItemCell.self)) as! UsersListItemCellProtocol
        case (true, false):
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InvertedUsersListItemCell.self)) as! UsersListItemCellProtocol
        case (false, true):
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UsersListNoteItemCell.self)) as! UsersListItemCellProtocol
        case (true, true):
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: InvertedUsersNoteListItemCell.self)) as! UsersListItemCellProtocol
        }
        
        cell.configure(with: self, imageRepository: imageRepository)
        return cell
    }
}

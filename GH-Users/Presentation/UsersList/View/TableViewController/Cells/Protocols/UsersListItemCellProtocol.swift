//
//  UsersListItemCellProtocol.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

public protocol UsersListItemCellProtocol: UITableViewCell {
    func configure(with viewModel: UserListCellViewModel, imageRepository: ImageRepositoryProtocol)
}

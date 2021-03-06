//
//  UsersListCellViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit
import Combine

protocol UserListCellViewModelInputProtocol {
    func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UsersListItemCellProtocol
    func cancelTasks()
}

protocol UserListCellViewModelOutputProtocol {
    var username: String? { get }
    var image: PassthroughSubject<UIImage?, Never> { get }
    var typeText: String? { get }
    var note: String? { get }
    var viewed: Bool { get }
}

protocol UserListCellViewModelProtocol: UserListCellViewModelInputProtocol, UserListCellViewModelOutputProtocol {}

public class UserListCellViewModel {
    private let id: String
    let username: String?
    private let imagePath: String?
    let image = PassthroughSubject<UIImage?, Never>()
    let typeText: String?
    private(set) var note: String?
    private(set) var viewed: Bool
    
    private let imageRepository: ImageRepositoryProtocol

    private var imageFetchTask: Cancellable? { willSet { imageFetchTask?.cancel() } }
    private var cancellableSet = Set<AnyCancellable>()

    init(user: UserEntity, imageRepository: ImageRepositoryProtocol) {
        self.id = user.idString!
        self.username = user.login
        self.imagePath = user.avatarURL
        self.typeText = String(format: NSLocalizedString("Account type: %@", comment: ""), user.type ?? "User")
        self.note = user.note
        self.viewed = user.viewed
        self.imageRepository = imageRepository

        setupObservers(user: user)
    }
    
    func setupObservers(user: UserEntity) {
        // Monitoring the changes to the note value, when the note value changes the tableview is reloaded but the viewmodel still has the old value, to sync the data monitoring and updating the note value here
        user.publisher(for: \.note)
            .sink {[weak self] (newNote) in
            self?.note = newNote
        }.store(in: &cancellableSet)
        
        // Monitoring the changes to the viewed value, when the viewed value changes the tableview is reloaded but the viewmodel still has the old value, to sync the data monitoring and updating the viewed value here
        user.publisher(for: \.viewed)
            .sink {[weak self] (newVal) in
            self?.viewed = newVal
        }.store(in: &cancellableSet)
    }
}

// BONUS TASK: Coordinator and/or MVVM patterns are used.
extension UserListCellViewModel: UserListCellViewModelProtocol {
    func cellFor(tableView: UITableView, at indexPath: IndexPath) -> UsersListItemCellProtocol {
        let cell: UsersListItemCellProtocol
        
        let isInvertedCell = (indexPath.row + 1) % 4 == 0
        let isNoteAvailable = note != nil && !note!.isEmpty
        
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
        
        cell.configure(with: self)
        
        if let url = imagePath {
            imageFetchTask = imageRepository.fetchImage(with: url) {[weak self] (result) in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self?.image.send(image)
                        return
                    }
                    self?.image.send(nil)
                case .failure(let error):
                    self?.image.send(nil)
                    print(error.localizedDescription)
                }
            }
        }
        
        return cell
    }
    
    public func cancelTasks() {
        self.imageFetchTask?.cancel()
    }
}

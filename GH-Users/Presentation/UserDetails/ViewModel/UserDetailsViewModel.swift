//
//  UserDetailsViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

protocol UserDetailsViewModelInputProtocol {
    func viewDidLoad()
    func save(note: String)
    func cancelTasks()
}

protocol UserDetailsViewModelOutputProtocol {
    var userDetails: CurrentValueSubject<UserEntity?, Never> { get }
    var image: CurrentValueSubject<UIImage?, Never> { get }
    var note:  NSObject.KeyValueObservingPublisher<UserEntity, String?> { get }
    var isCached: CurrentValueSubject<Bool, Never> { get }
    var error: CurrentValueSubject<String?, Never> { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
}

protocol UserDetailsViewModelProtocol: UserDetailsViewModelInputProtocol, UserDetailsViewModelOutputProtocol {}

public class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let user: UserEntity
    private let userDetailsRepository: UserDetailsRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    var userDetails = CurrentValueSubject<UserEntity?, Never>(nil)
    var image = CurrentValueSubject<UIImage?, Never>(nil)
    lazy var note = self.user.publisher(for: \.note)
    var isCached = CurrentValueSubject<Bool, Never>(false)
    var error = CurrentValueSubject<String?, Never>(nil)
    var emptyDataTitle = NSLocalizedString("Unable to load user details", comment: "")
    var errorTitle = NSLocalizedString("Error", comment: "")
    
    private var repositoryTask: Cancellable? { willSet { repositoryTask?.cancel() }}
    private var imageTask: Cancellable? { willSet { imageTask?.cancel() }}

    init(user: UserEntity, userDetailsRepository: UserDetailsRepositoryProtocol, imageRespository: ImageRepositoryProtocol) {
        self.user = user
        self.userDetailsRepository = userDetailsRepository
        self.imageRepository = imageRespository
    }
    
    func viewDidLoad() {
        if let url = user.avatarURL {
            imageTask = imageRepository.fetchImage(with: url) {[weak self] (result) in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self?.image.send(image)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        if let username = user.login {
            repositoryTask = userDetailsRepository.fetchUserDetails(username: username, cached: {[weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    self.userDetails.send(user)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, completion: { (result) in
                switch result {
                case .success(let user):
                    self.isCached.send(false)
                    self.userDetails.send(user)
                case .failure(let error):
                    if (self.userDetails.value != nil) {
                        self.isCached.send(true)
                    }
                    self.handle(error: error)
                }
            })
        }
    }
    
    func save(note: String) {
        userDetailsRepository.save(note: note, username: user.login)
    }
    
    private func handle(error: Error) {
        self.error.send(error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: ""))
    }
    
    func cancelTasks() {
        imageTask?.cancel()
        repositoryTask?.cancel()
    }
    
}

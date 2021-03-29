//
//  UserDetailsViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine
import Reachability

protocol UserDetailsViewModelInputProtocol {
    func viewDidLoad()
    func save(note: String)
    func cancelTasks()
}

protocol UserDetailsViewModelOutputProtocol {
    var userDetails: CurrentValueSubject<UserEntity?, Never> { get }
    var image: CurrentValueSubject<UIImage?, Never> { get }
    var publisRepos: String { get }
    var following: String { get }
    var name: String { get }
    var organisation: String { get }
    var blog: String { get }

    var note:  NSObject.KeyValueObservingPublisher<UserEntity, String?> { get }
    var isCached: CurrentValueSubject<Bool, Never> { get }
    var error: CurrentValueSubject<String?, Never> { get }
    var title: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
}

protocol UserDetailsViewModelProtocol: UserDetailsViewModelInputProtocol, UserDetailsViewModelOutputProtocol {}

public class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let user: UserEntity
    private let repository: UserDetailsRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    var userDetails = CurrentValueSubject<UserEntity?, Never>(nil)
    var image = CurrentValueSubject<UIImage?, Never>(nil)
    var publisRepos: String {
        String(format: NSLocalizedString("Public Repos: %d", comment: ""), Int(userDetails.value?.publicRepos ?? 0))
    }
    var following: String {
        String(format: NSLocalizedString("Following: %d", comment: ""), Int(userDetails.value?.following ?? 0))
    }
    var name: String {
        String(format: NSLocalizedString("Name: %@", comment: ""), userDetails.value?.name ?? "")
    }
    var organisation: String {
        String(format: NSLocalizedString("Organisation: %@", comment: ""), userDetails.value?.company ?? "")
    }
    var blog: String {
        String(format: NSLocalizedString("Blog: %@", comment: ""), userDetails.value?.blog ?? "")
    }
    lazy var note = self.user.publisher(for: \.note)

    
    let title = NSLocalizedString("Details", comment: "")
    var isCached = CurrentValueSubject<Bool, Never>(false)
    var error = CurrentValueSubject<String?, Never>(nil)
    var emptyDataTitle = NSLocalizedString("Unable to load user details", comment: "")
    var errorTitle = NSLocalizedString("Error", comment: "")
    
    private var repositoryTask: Cancellable? { willSet { repositoryTask?.cancel() }}
    private var imageTask: Cancellable? { willSet { imageTask?.cancel() }}
    private var cancellableSet = Set<AnyCancellable>()

    init(user: UserEntity, repository: UserDetailsRepositoryProtocol, imageRespository: ImageRepositoryProtocol) {
        self.user = user
        self.repository = repository
        self.imageRepository = imageRespository
    }
    
    func viewDidLoad() {
        setupObservers()

        loadUserDetails()
    }
    
    func setupObservers() {
        NotificationCenter.default.publisher(for: .reachabilityChanged, object: nil)
            .sink {[weak self] (note) in
                let reachability = note.object as! Reachability

                switch reachability.connection {
                case .wifi, .cellular:
                    self?.reloadIfRequired()
                case .unavailable, .none:
                  print("Network not reachable")
                }
            }.store(in: &cancellableSet)
        
        userDetails.sink {[weak self] (userEntity) in
            guard let url = userEntity?.avatarURL else { return }
            self?.imageTask = self?.imageRepository.fetchImage(with: url) {[weak self] (result) in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self?.image.send(image)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }.store(in: &cancellableSet)
    }
    
    private func reloadIfRequired() {
        loadUserDetails()
    }
        
    private func loadUserDetails() {
        guard let username = user.login else { return }
        repositoryTask = repository.fetchUserDetails(username: username, cached: {[weak self] (result) in
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
    
    private func handle(error: Error) {
        self.error.send(error.isInternetConnectionError ?
            NSLocalizedString("No internet connection", comment: "") :
            NSLocalizedString("Failed loading movies", comment: ""))
    }
    
    func save(note: String) {
        repository.save(note: note, username: user.login)
    }
    
    func cancelTasks() {
        imageTask?.cancel()
        repositoryTask?.cancel()
    }
    
}

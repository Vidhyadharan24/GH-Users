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
}

protocol UserDetailsViewModelOutputProtocol {
    var image: CurrentValueSubject<UIImage?, Never> { get }
    var publisRepos: String { get }
    var following: String { get }
    var name: String { get }
    var organisation: String { get }
    var blog: String { get }
    var viewed: Bool { get }
    var note:  NSObject.KeyValueObservingPublisher<UserEntity, String?> { get }
    var loading: CurrentValueSubject<Bool, Never> { get }
    var offline: CurrentValueSubject<Bool, Never> { get }
    var error: CurrentValueSubject<String?, Never> { get }
    var title: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var offlineErrorMessage: String { get }
}

protocol UserDetailsViewModelProtocol: UserDetailsViewModelInputProtocol, UserDetailsViewModelOutputProtocol {}

public class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let user: UserEntity
    private let repository: UserDetailsRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    private(set) var image = CurrentValueSubject<UIImage?, Never>(nil)
    var publisRepos: String {
        String(format: NSLocalizedString("Public Repos: %d", comment: ""), Int(user.publicRepos))
    }
    var following: String {
        String(format: NSLocalizedString("Following: %d", comment: ""), Int(user.following))
    }
    var name: String {
        String(format: NSLocalizedString("Name: %@", comment: ""), user.name ?? "")
    }
    var organisation: String {
        String(format: NSLocalizedString("Organisation: %@", comment: ""), user.company ?? "")
    }
    var blog: String {
        String(format: NSLocalizedString("Blog: %@", comment: ""), user.blog ?? "")
    }
    var viewed: Bool {
        user.viewed
    }
    private(set) lazy var note = self.user.publisher(for: \.note)

    let title = NSLocalizedString("Details", comment: "")
    var loading = CurrentValueSubject<Bool, Never>(false)
    var offline = CurrentValueSubject<Bool, Never>(false)
    var error = CurrentValueSubject<String?, Never>(nil)
    var emptyDataTitle = NSLocalizedString("Unable to load user details", comment: "")
    var errorTitle = NSLocalizedString("Error", comment: "")
    let offlineErrorMessage = NSLocalizedString("Offline", comment: "")

    private var repositoryTask: Cancellable? { willSet { repositoryTask?.cancel() }}
    private var imageTask: Cancellable? { willSet { imageTask?.cancel() }}
    private var cancellableSet = Set<AnyCancellable>()

    init(user: UserEntity, repository: UserDetailsRepositoryProtocol, imageRespository: ImageRepositoryProtocol) {
        self.user = user
        self.repository = repository
        self.imageRepository = imageRespository
    }
    
    deinit {
        cancelTasks()
    }
    
    func viewDidLoad() {
        setupObservers()
        loadUserDetails(username: self.user.login)
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
    }
    
    func loadImage() {
        guard let url = user.avatarURL else { return }
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
    
    private func reloadIfRequired() {
        // The viewed key when false denotes that the user details api has not been called, hence reloading
        guard user.viewed else { return }
        loadUserDetails(username: user.login)
    }
        
    private func loadUserDetails(username: String?) {
        guard let username = username else { return }
        self.loading.send(true)
        repositoryTask = repository.fetchUserDetails(username: username, cached: {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.loadImage()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, completion: { [weak self] (result) in
            guard let self = self else { return }
            self.loading.send(false)
            switch result {
            case .success(_):
                self.offline.send(false)
                self.loadImage()
            case .failure(let error):
                self.handle(error: error)
            }
        })
    }
    
    private func handle(error: Error) {
        if (error.isInternetConnectionError) {
            self.offline.send(true)
            self.error.send(NSLocalizedString("No internet connection", comment: ""))
            return
        }
        self.error.send(NSLocalizedString("Failed loading movies", comment: ""))
    }
    
    func save(note: String) {
        repository.save(note: note, username: user.login)
    }
    
    func cancelTasks() {
        imageTask?.cancel()
        repositoryTask?.cancel()
    }
    
}

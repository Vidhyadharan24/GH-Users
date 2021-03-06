//
//  UserDetailsViewModel.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine
import Reachability
import SkeletonView

enum UserDetailsViewModelLoading {
    case fullScreen
    case refresh
}

enum UserDetailsDataType {
    case cached
    case live
}

protocol UserDetailsViewModelInputProtocol {
    func viewDidLoad()
    func save(note: String)
    func noteSavedAlertClose()
    func noteSaveErrorAlertClose()
}

protocol UserDetailsViewModelOutputProtocol {
    var image: PassthroughSubject<UIImage?, Never> { get }
    var publisRepos: String { get }
    var following: String { get }
    var name: String { get }
    var organisation: String { get }
    var blog: String { get }
    var viewed: Bool { get }
    var note:  NSObject.KeyValueObservingPublisher<UserEntity, String?> { get }
    var loading: CurrentValueSubject<UserDetailsViewModelLoading?, Never> { get }
    var dataType: CurrentValueSubject<UserDetailsDataType, Never> { get }
    var offline: CurrentValueSubject<Bool, Never> { get }
    var error: PassthroughSubject<String?, Never> { get }
    var noteSavedAlertTitle: String { get }
    var noteSaved: PassthroughSubject<String?, Never> { get }
    var noteSaveError: PassthroughSubject<String?, Never> { get }
    var title: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
    var offlineErrorMessage: String { get }
}

protocol UserDetailsViewModelProtocol: UserDetailsViewModelInputProtocol, UserDetailsViewModelOutputProtocol {}

// BONUS TASK: Coordinator and/or MVVM patterns are used.
public class UserDetailsViewModel: UserDetailsViewModelProtocol {
    private let user: UserEntity
    private var userDetailsLoaded: Bool = false
    private let repository: UserDetailsRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    private(set) var image = PassthroughSubject<UIImage?, Never>()
    var publisRepos: String {
        String(format: NSLocalizedString("Public Repos: %d", comment: ""), Int(user.publicRepos))
    }
    var following: String {
        String(format: NSLocalizedString("Following: %d", comment: ""), Int(user.following))
    }
    var name: String { user.name ?? " "}
    var organisation: String { String(user.company ?? " ") }
    var blog: String { String(user.blog ?? " ") }
    var viewed: Bool { user.viewed }
    
    private(set) lazy var note = self.user.publisher(for: \.note)

    let title = NSLocalizedString("Details", comment: "")
    private(set) var loading = CurrentValueSubject<UserDetailsViewModelLoading?, Never>(nil)
    private(set) var dataType = CurrentValueSubject<UserDetailsDataType, Never>(.live)
    private(set) var offline = CurrentValueSubject<Bool, Never>(false)
    
    private(set) var error = PassthroughSubject<String?, Never>()
    let noteSavedAlertTitle = NSLocalizedString("Saved", comment: "")
    private(set) var noteSaved = PassthroughSubject<String?, Never>()
    private(set) var noteSaveError = PassthroughSubject<String?, Never>()
    
    let emptyDataTitle = NSLocalizedString("Unable to load user details", comment: "")
    let errorTitle = NSLocalizedString("Error", comment: "")
    let offlineErrorMessage = NSLocalizedString("Offline", comment: "")

    private var repositoryTask: Cancellable? { willSet { repositoryTask?.cancel() }}
    private var imageTask: Cancellable? { willSet { imageTask?.cancel() }}
    private var cancellableSet = Set<AnyCancellable>()

    init(user: UserEntity, repository: UserDetailsRepositoryProtocol, imageRespository: ImageRepositoryProtocol) {
        self.user = user
        self.repository = repository
        self.imageRepository = imageRespository
        
        setupObservers()
    }
    
    deinit {
        cancelTasks()
    }
    
    func viewDidLoad() {
        loadUserDetails(username: self.user.login)
    }
    
    func setupObservers() {
        // REQUIRED TASK: The app must ???automatically??? retry loading data once the connection is available.
        NotificationCenter.default.publisher(for: .reachabilityChanged, object: nil)
            .sink {[weak self] (note) in
                let reachability = note.object as! Reachability

                switch reachability.connection {
                case .wifi, .cellular:
                    self?.offline.send(false)
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
        guard userDetailsLoaded else { return }
        loadUserDetails(username: user.login)
    }
        
    private func loadUserDetails(username: String?) {
        guard let username = username else { return }
        self.loading.send(user.viewed ? .refresh : .fullScreen)
        repositoryTask = repository.fetchUserDetails(username: username, cached: {[weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.loadImage()
                self.dataType.send(.cached)
                self.userDetailsLoaded = true
            case .failure(let error):
                print(error.localizedDescription)
            }
        }, completion: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.loadImage()
                self.dataType.send(.live)
            case .failure(let error):
                self.handle(error: error)
            }
            self.loading.send(.none)
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
        repository.save(note: note, username: user.login) { (error) in
            if error != nil {
                self.noteSaveError.send(NSLocalizedString("Unable to save note", comment: ""))
            } else {
                self.noteSaved.send(NSLocalizedString("Note saved", comment: ""))
            }
        }
    }
    
    func noteSavedAlertClose() {
        self.noteSaved.send(nil)
    }
    
    func noteSaveErrorAlertClose() {
        self.noteSaveError.send(nil)
    }
    
    func cancelTasks() {
        imageTask?.cancel()
        repositoryTask?.cancel()
    }
    
}

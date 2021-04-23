//
//  UserDetailsViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

// BONUS TASK: Users list UI must be done in code and Profile - with Interface Builder.
class UserDetailsViewController: UIViewController {
    var viewModel: UserDetailsViewModelProtocol!
    var completion: (() -> Void)?
    
    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var offlineView: UIView!
    @IBOutlet private var offlineLabel: UILabel!
    
    @IBOutlet private var offlineViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var organisationLabel: UILabel!
    @IBOutlet private var blogLabel: UILabel!
    
    @IBOutlet private var publicResposLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    
    @IBOutlet private var notesTextView: UITextView! {
        didSet {
            notesTextView.layer.borderWidth = 2
            notesTextView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }

    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.layer.masksToBounds = true
            saveButton.layer.cornerRadius = 8
            saveButton.layer.borderWidth = 2
            saveButton.layer.borderColor = saveButton.titleColor(for: UIControl.State.normal)?.cgColor ?? UIColor.systemBlue.cgColor
        }
    }

    @IBOutlet private var errorLabel: UILabel!

    private var cancellableSet: Set<AnyCancellable> = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()

        setupViews()
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        completion?()
    }
}

extension UserDetailsViewController {
    func setupViews() {
        self.title = viewModel.title
        self.offlineLabel.text = viewModel.offlineErrorMessage
    }
    
    func bind(to viewModel: UserDetailsViewModelProtocol) {
        let size = imageView.bounds.size
        
        viewModel.image.sink {[weak self] (image) in
            self?.imageView.image = image?.resize(targetSize: size)
        }.store(in: &cancellableSet)
        
        viewModel.loading.sink {[weak self] (loading) in
            self?.updateLoading(loading)
        }.store(in: &cancellableSet)
        
        viewModel.note.sink {[weak self] in self?.notesTextView.text = $0 }.store(in: &cancellableSet)
        
        viewModel.offline.sink { [weak self] in self?.showHideOfflineView($0) }.store(in: &cancellableSet)
        
        viewModel.error.sink { [weak self] in self?.showError($0) }.store(in: &cancellableSet)
        
        viewModel.noteSaved.sink { [weak self] in self?.showNoteSavedMessage($0) }.store(in: &cancellableSet)
        
        viewModel.noteSaveError.sink { [weak self] in self?.showSaveNoteError($0) }.store(in: &cancellableSet)
    }
    
    public func updateLoading(_ loading: UserDetailsViewModelLoading?) {
        // BONUS TASK: Empty views such as list items (while data is still loading) should have Loading Shimmer aka ​Skeletons
        // Users SkeletonView from https://github.com/Juanpe/SkeletonView to display shimmering effect when there is no user data.

        if case .fullScreen = loading {
            self.scrollView.isHidden = false
            view.showAnimatedSkeleton()
        } else if case .refresh = loading {
            imageView.isSkeletonable = false
            nameLabel.isSkeletonable = false

            view.showAnimatedSkeleton()
        } else {
            view.hideSkeleton()
            update()
        }
    }
    
    public func update() {
        self.publicResposLabel.text = viewModel.publisRepos
        self.followingLabel.text = viewModel.following
        
        self.nameLabel.text = viewModel.name
        self.organisationLabel.text = viewModel.organisation
        self.blogLabel.text = viewModel.blog
    }
    
    // REQUIRED TASK: The app must handle ​no internet ​scenario, show appropriate UI indicators.
    private func showHideOfflineView(_ offline: Bool)  {
        if (offline) {
            let currentVal = offlineViewTopConstraint?.priority.rawValue ?? 0
            guard currentVal != 999 else { return }
            offlineViewTopConstraint?.priority = UILayoutPriority(999)
        } else {
            let currentVal = offlineViewTopConstraint?.priority ?? .defaultHigh
            guard currentVal != .defaultLow else { return }
            offlineViewTopConstraint?.priority = .defaultLow
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func showError(_ message: String?) {
        guard let msg = message, !viewModel.viewed else { return }
        self.errorLabel.text = msg
        self.scrollView.isHidden = true
    }
    
    private func showSaveNoteError(_ message: String?) {
        guard let msg = message else { return }
        let alert = UIAlertController(title: viewModel.errorTitle, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: {[weak self] (action) in
            self?.viewModel.noteSaveErrorAlertClose()
        }))
        self.present(alert, animated: true, completion: completion)
    }
    
    private func showNoteSavedMessage(_ message: String?) {
        guard let msg = message else { return }
        let alert = UIAlertController(title: viewModel.noteSavedAlertTitle, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertAction.Style.default, handler: {[weak self] (action) in
            self?.viewModel.noteSaveErrorAlertClose()
        }))
        self.present(alert, animated: true, completion: completion)
    }
    
    @IBAction func saveTapped(button: UIButton) {
        viewModel.save(note: self.notesTextView.text)
    }
}

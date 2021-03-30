//
//  UserDetailsViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

class UserDetailsViewController: UIViewController {
    var viewModel: UserDetailsViewModelProtocol!
    var completion: (() -> Void)?

    @IBOutlet private var offlineView: UIView!
    @IBOutlet private var offlineLabel: UILabel!
    
    @IBOutlet private var offlineViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var organisationLabel: UILabel!
    @IBOutlet private var blogLabel: UILabel!
    
    @IBOutlet private var publicResposLabel: UILabel!
    @IBOutlet private var followingLabel: UILabel!
    
    @IBOutlet private var notesTextView: UITextView!

    @IBOutlet private var saveButton: UIButton! {
        didSet {
            saveButton.layer.masksToBounds = true
            saveButton.layer.cornerRadius = 8
            saveButton.layer.borderWidth = 2
            saveButton.layer.borderColor = saveButton.titleColor(for: UIControl.State.normal)?.cgColor ?? UIColor.systemBlue.cgColor
        }
    }

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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.notesTextView.layer.shadowColor = UIColor.systemGray.cgColor
    }
}

extension UserDetailsViewController {
    func setupViews() {
        self.title = viewModel.title
        self.offlineLabel.text = viewModel.offlineErrorMessage
        notesTextView.layer.borderWidth = 2
        notesTextView.layer.borderColor = UIColor.systemGray.cgColor
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
    }
    
    public func updateLoading(_ loading: Bool) {
        if !viewModel.viewed {
            LoadingView.show()
        } else {
            LoadingView.hide()
        }
        update()
    }
    
    public func update() {
        self.publicResposLabel.text = viewModel.publisRepos
        self.followingLabel.text = viewModel.following
        
        self.nameLabel.text = viewModel.name
        self.organisationLabel.text = viewModel.organisation
        self.blogLabel.text = viewModel.blog
    }
    
    private func showHideOfflineView(_ offline: Bool)  {
        if (offline) {
            offlineViewTopConstraint?.priority = UILayoutPriority(999)
        } else {
            offlineViewTopConstraint?.priority = .defaultLow
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @IBAction func saveTapped(button: UIButton) {
        viewModel.save(note: self.notesTextView.text)
    }
}

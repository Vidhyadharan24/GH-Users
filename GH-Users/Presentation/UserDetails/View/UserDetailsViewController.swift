//
//  UserDetailsViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 29/03/21.
//

import UIKit
import Combine

class UserDetailsViewController: UIViewController {
    var viewModel: UserDetailsViewModel!
    var completion: (() -> Void)?

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
        bind(to: viewModel)
        viewModel.viewDidLoad()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        completion?()
    }
    
    func bind(to viewModel: UserDetailsViewModel) {
        let size = imageView.bounds.size
        
        viewModel.image.sink {[weak self] (image) in
            self?.imageView.image = image?.resize(targetSize: size)
        }.store(in: &cancellableSet)
        
        viewModel.userDetails.sink { (userEntity) in
            self.update(userEntity: userEntity)
        }.store(in: &cancellableSet)
        
        viewModel.note
            .sink { (string) in
            self.notesTextView.text = string
        }.store(in: &cancellableSet)
    }
    
    public func update(userEntity: UserEntity?) {
        guard let userEntity = userEntity else { return }
        self.publicResposLabel.text = String(format: NSLocalizedString("Public Repos %d", comment: ""), userEntity.publicRepos)
        self.followingLabel.text = String(format: NSLocalizedString("Following %d", comment: ""), userEntity.following)
        
    }
    
    @IBAction func saveTapped(button: UIButton) {
        viewModel.save(note: self.notesTextView.text)
    }
}

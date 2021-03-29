//
//  UsersListNoteItemCell.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit
import Combine

class UsersListNoteItemCell: UITableViewCell, UsersListItemCellProtocol {
    static let reuseIdentifier = String(describing: UsersListNoteItemCell.self)
    static let height = CGFloat(100)
    
    private let cornerRadius: CGFloat = 8
    private let borderWidth: CGFloat = 2
    private let borderColor: UIColor = UIColor.black
    
    private var viewModel: UserListCellViewModel? { willSet {viewModel?.cancelTasks() } }
    private var cancellableSet = Set<AnyCancellable>()

    private lazy var mainBackgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = cornerRadius
        return view
    }()
    
    private lazy var shadowView : UIView = {
        return ShadowView(cornerRadius: cornerRadius)
    }()
    
    private lazy var userImageView : UIImageView = {
        let imgView = RoundedImageView(borderWidth: borderWidth, borderColor: borderColor)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var noteImageView : UIImageView = {
        let imgView = RoundedImageView(borderWidth: borderWidth, borderColor: borderColor)
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private lazy var usernameLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        contentView.addSubview(shadowView)
        contentView.addSubview(mainBackgroundView)
        mainBackgroundView.addSubview(userImageView)
        mainBackgroundView.addSubview(noteImageView)
        mainBackgroundView.addSubview(usernameLabel)
        mainBackgroundView.addSubview(descriptionLabel)

        contentView.clipsToBounds = true
        
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
        
        mainBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainBackgroundView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            mainBackgroundView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            mainBackgroundView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            mainBackgroundView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
        ])
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = userImageView.heightAnchor.constraint(equalToConstant: 70)
        heightConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: mainBackgroundView.layoutMarginsGuide.leadingAnchor),
            userImageView.topAnchor.constraint(equalTo: mainBackgroundView.layoutMarginsGuide.topAnchor),
            userImageView.bottomAnchor.constraint(equalTo: mainBackgroundView.layoutMarginsGuide.bottomAnchor),
            userImageView.heightAnchor.constraint(equalTo: userImageView.widthAnchor, multiplier: 1.0),
            heightConstraint
        ])
        
        noteImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteImageView.trailingAnchor.constraint(equalTo: mainBackgroundView.layoutMarginsGuide.trailingAnchor),
            noteImageView.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor),
            noteImageView.heightAnchor.constraint(equalTo: noteImageView.widthAnchor, multiplier: 1.0),
            noteImageView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: noteImageView.leadingAnchor, constant: 8),
            usernameLabel.topAnchor.constraint(equalTo: userImageView.topAnchor)
        ])

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: usernameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.userImageView.image = nil
        _ = self.cancellableSet.map { $0.cancel() }
        self.cancellableSet.removeAll()
    }
    
    func set(image: UIImage?) {
        self.userImageView.image = image?.resize(targetSize: self.userImageView.frame.size)
    }

    public func configure(with viewModel: UserListCellViewModel) {
        self.usernameLabel.text = viewModel.username
        self.descriptionLabel.text = viewModel.typeText
        
        if (viewModel.viewed) {
            mainBackgroundView.backgroundColor = UIColor.systemGray6
        } else {
            mainBackgroundView.backgroundColor = UIColor.tertiarySystemBackground
        }
        
        viewModel.image.sink {[weak self] (image) in
            self?.set(image: image)
        }.store(in: &cancellableSet)
    }
}

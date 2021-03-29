//
//  UsersListItemCell.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

class UsersListItemCell: UITableViewCell, UsersListItemCellProtocol {
    private let cornerRadius: CGFloat = 8
    private let borderWidth: CGFloat = 2
    let borderColor: UIColor = UIColor.black

    private var imageFetchTask: Cancellable?

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
    
    private lazy var usernameLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textAlignment = .left
        return lbl
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 16)
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(shadowView)
        contentView.addSubview(mainBackgroundView)
        mainBackgroundView.addSubview(userImageView)
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
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: mainBackgroundView.layoutMarginsGuide.trailingAnchor),
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

        imageFetchTask?.cancel()
        imageFetchTask = nil
    }
    
    func set(image: UIImage) {
        self.userImageView.image = image.resize(targetSize: self.userImageView.frame.size)
    }
    
    public func configure(with viewModel: UserListCellViewModel, imageRepository: ImageRepositoryProtocol) {
        self.usernameLabel.text = viewModel.username
        self.descriptionLabel.text = viewModel.typeText
        
        if (viewModel.viewed) {
            mainBackgroundView.backgroundColor = UIColor.systemGray6
        } else {
            mainBackgroundView.backgroundColor = UIColor.systemBackground
        }
        
        if let url = viewModel.imagePath {
            imageFetchTask = imageRepository.fetchImage(with: url) {[weak self] (result) in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self?.set(image: image)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

//
//  UsersListViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit

class UsersListViewController: UIViewController {

    private let viewModel: UsersListViewModelProtocol
    private let imageRepository: ImageRepositoryProtocol
    
    static func create(viewModel: UsersListViewModelProtocol, imageRepository: ImageRepositoryProtocol) -> UsersListViewController {
        let controller = UsersListViewController(viewModel: viewModel, imageRepository: imageRepository)
                
        return controller
    }
        
    private init(viewModel: UsersListViewModelProtocol, imageRepository: ImageRepositoryProtocol) {
        self.viewModel = viewModel
        self.imageRepository = imageRepository
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = setUpRootView()
    }
    
    func setUpRootView() -> UIView {
        let rootView = UIView();
        rootView.backgroundColor = UIColor.blue
        return rootView
    }
}

extension UsersListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
    
}

//
//  UsersSearchTableViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit
import Combine

class UsersSearchTableViewController: UITableViewController {
    var viewModel: LocalUsersSearchViewModelProtocol!
    
    private var cancellableSet: Set<AnyCancellable> = []

    init(viewModel: LocalUsersSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bind(to: viewModel)
    }
    
    private func bind(to viewModel: LocalUsersSearchViewModelProtocol) {
        viewModel.userViewModels.sink { [weak self] _ in self?.reload() }.store(in: &cancellableSet)
        viewModel.error.sink { [weak self] in self?.showError($0) }.store(in: &cancellableSet)
    }

    func reload() {
        tableView.reloadData()
    }
    
    func didSearch(query: String) {
        viewModel.didSearch(query: query)
    }
    
    func didCancelSearch() {
        viewModel.didCancel()
    }

    // MARK: - Private

    private func setupViews() {
        tableView.register(UsersListItemCell.self, forCellReuseIdentifier: String(describing: UsersListItemCell.self))
        tableView.register(InvertedUsersListItemCell.self, forCellReuseIdentifier: String(describing: InvertedUsersListItemCell.self))
        tableView.register(UsersListNoteItemCell.self, forCellReuseIdentifier: String(describing: UsersListNoteItemCell.self))
        tableView.register(InvertedUsersNoteListItemCell.self, forCellReuseIdentifier: String(describing: InvertedUsersNoteListItemCell.self))

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
    }
    
    private func showError(_ error: String?) {
        guard let error = error, !error.isEmpty else { return }
//        showAlert(title: viewModel.errorTitle, message: error)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension UsersSearchTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userViewModels.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModel.userViewModels.value[indexPath.row]
        
        return vm.cellFor(tableView: tableView, at: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}

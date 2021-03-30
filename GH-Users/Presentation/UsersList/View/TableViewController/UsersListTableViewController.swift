//
//  UsersListTableViewController.swift
//  GH-Users
//
//  Created by Vidhyadharan on 28/03/21.
//

import UIKit
import SkeletonView

class UsersListTableViewController: UITableViewController {
    var viewModel: UsersListViewModelProtocol!

    var nextPageLoadingSpinner: UIActivityIndicatorView?
    
    init(viewModel: UsersListViewModelProtocol) {
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
    }

    // MARK: - Event calls from parent view controller
    
    func reload() {
        tableView.reloadData()
    }

    func updateLoading(_ loading: UsersListViewModelLoading?) {
        switch loading {
        case .nextPage:
            nextPageLoadingSpinner?.removeFromSuperview()
            nextPageLoadingSpinner = makeActivityIndicator(size: .init(width: tableView.frame.width, height: 44))
            tableView.tableFooterView = nextPageLoadingSpinner
        case .fullScreen:
            tableView.tableFooterView = nil
            // BONUS TASK: Empty views such as list items (while data is still loading) should have Loading Shimmer aka ​Skeletons
            // Users SkeletonView from https://github.com/Juanpe/SkeletonView to display shimmering effect when there is no user data.
            tableView.showAnimatedSkeleton()
        case .none:
            tableView.tableFooterView = nil
            tableView.hideSkeleton()
        }
    }

    // MARK: - Private

    // BONUS TASK: Users list UI must be done in code and Profile - with Interface Builder.
    private func setupViews() {
        tableView.register(UsersListItemCell.self, forCellReuseIdentifier: String(describing: UsersListItemCell.self))
        tableView.register(InvertedUsersListItemCell.self, forCellReuseIdentifier: String(describing: InvertedUsersListItemCell.self))
        tableView.register(UsersListNoteItemCell.self, forCellReuseIdentifier: String(describing: UsersListNoteItemCell.self))
        tableView.register(InvertedUsersNoteListItemCell.self, forCellReuseIdentifier: String(describing: InvertedUsersNoteListItemCell.self))
        
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        tableView.isSkeletonable = true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension UsersListTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userViewModels.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vm = viewModel.userViewModels.value[indexPath.row]

        if indexPath.row == viewModel.userViewModels.value.count - 1 {
            viewModel.didLoadNextPage()
        }

        let cell = vm.cellFor(tableView: tableView, at: indexPath)
        cell.hideSkeleton()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectItem(at: indexPath.row)
    }
}

extension UsersListTableViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: UsersListItemCell.self)
    }
}

extension UsersListTableViewController {
    func makeActivityIndicator(size: CGSize) -> UIActivityIndicatorView {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                style = UIActivityIndicatorView.Style.medium
            } else {
                style = UIActivityIndicatorView.Style.medium
            }
        } else {
            style = .gray
        }

        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicator.frame = .init(origin: .zero, size: size)

        return activityIndicator
    }
}


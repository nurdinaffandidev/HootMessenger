//
//  NewConversationViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 24/10/24.
//

import UIKit
import Combine

class NewConversationViewController: UIViewController {
    private var viewModel: NewConversationsViewModel
    private var uiEvents = PassthroughSubject<NewConversationsViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: NewConversationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        viewModel.bind(uiEvents.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                switch event {
                case .fetchUsersSuccess:
                    break // show users
                case .fetchUsersFail:
                    break // show error
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
    }
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.placeholder = "Search for Users..."
        searchBar.backgroundColor = .systemTeal
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = .black
            textfield.backgroundColor = .white
        }
        return searchBar
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.customView?.translatesAutoresizingMaskIntoConstraints = false
        button.title = "Cancel"
        button.style = .done
        button.target = self
        button.action = #selector(dismissView)
        button.tintColor = .white
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        table.delegate = self
//        table.dataSource = self
        table.isHidden = true
        return table
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No results"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .white
        searchBar.becomeFirstResponder()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton
    }
    
    // MARK: - Functions
    @objc func dismissView() {
        self.dismiss(animated: true)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
}

//
//  NewConversationViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 24/10/24.
//

import UIKit
import Combine
import JGProgressHUD

class NewConversationViewController: UIViewController {
    private var viewModel: NewConversationsViewModel
    private var uiEvents = PassthroughSubject<NewConversationsViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var filteredUsers: [SearchResult] = []
    
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
                case .filteredUsers:
                    self.filteredUsers = viewModel.results
                    print(spinnerLoader.subviews)
                    self.spinnerLoader.dismiss()
                    self.updateDisplayForSearchResult()
                case .fetchUsersFail:
                    spinnerLoader.dismiss()
                    alertUser(message: "Something went wrong please try again")
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        setupLayoutConstraints()
    }
    
    private lazy var spinnerLoader: JGProgressHUD = {
        let spinner = JGProgressHUD()
        spinner.style = .dark
        spinner.textLabel.text = "Loading"
        return spinner
    }()
    
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
        table.delegate = self
        table.dataSource = self
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
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton
    }
    
    func setupLayoutConstraints() {
        let safeLayoutGuide = view.safeAreaLayoutGuide
        noResultsLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(safeLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Functions
    @objc func dismissView() {
        self.dismiss(animated: true)
    }
    
    func updateDisplayForSearchResult() {
        if filteredUsers.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

// MARK: - Alerts
extension NewConversationViewController {
    func alertUser(message: String = "") {
        let alert = UIAlertController(
            title: "Woops",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title:"Dismiss",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true)
    }
}

// MARK: - SearchBar Delegate
extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        filteredUsers.removeAll()
        spinnerLoader.show(in: view)
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if viewModel.didFetchOnce {
            uiEvents.send(.filterUsers(query))
        }
        else {
            uiEvents.send(.fetchUsers { [weak self] in
                self?.uiEvents.send(.filterUsers(query))
            })
        }
    }
}

// MARK: - TableView Delegate
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredUsers[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

//
//  ProfileViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 7/11/24.
//

import UIKit
import Combine
import SnapKit

class ProfileViewController: UIViewController {
    private var viewModel: ProfileViewModel
    private var uiEvents = PassthroughSubject<ProfileViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    var data = [ProfileTableViewCellModel]()
    
    init(viewModel: ProfileViewModel) {
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
                case .logoutSuccess:
                    NotificationCenter.default.post(name: .didLoggedOutNotification, object: nil)
                case .logoutFail:
                    break // TODO: alert
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarTitle("Profile")
    }
    
    func setupNavBarTitle(_ title: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.sizeToFit()
        let titleView = UIBarButtonItem(customView: titleLabel)
        self.navigationController?.viewControllers.first?.navigationItem.leftBarButtonItem = titleView
        self.navigationController?.viewControllers.first?.navigationItem.rightBarButtonItem = nil
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            ProfileTableViewCell.self,
            forCellReuseIdentifier: ProfileTableViewCell.identifier
        )
       return tableView
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .lightGray
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.leading.top.trailing.bottom.equalToSuperview()
        }
    }
    
    func updateData() {
        data.append(
            ProfileTableViewCellModel(
                viewModelType: .info,
                title: "App Info",
                handler: nil
            )
        )
        data.append(
            ProfileTableViewCellModel(
                viewModelType: .logout,
                title: "Log Out",
                handler: {
                    [weak self] in
                    guard let self = self else { return }
                    let actionSheet = UIAlertController(
                        title: "Logging Out?",
                        message: "",
                        preferredStyle: .actionSheet
                    )
                    actionSheet.addAction(
                        UIAlertAction(
                            title: "Log Out",
                            style: .destructive,
                            handler: { [weak self] _ in
                                guard let self = self else { return }
                                UserDefaults.standard.setValue(nil, forKey: "email")
                                UserDefaults.standard.setValue(nil, forKey: "name")
                                uiEvents.send(.logout)
                            }
                        )
                    )
                    actionSheet.addAction(
                        UIAlertAction(
                            title: "Cancel",
                            style: .cancel,
                            handler: nil
                        )
                    )
                    self.present(actionSheet, animated: true)
                }
            )
        )
    }
    
    // MARK: - Functions

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        cell.setUp(with: viewModel)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
    
}

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"

    public func setUp(with viewModel: ProfileTableViewCellModel) {
        self.textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
        case .logout:
            textLabel?.textColor = .red
            textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            textLabel?.textAlignment = .left
        }
    }

}


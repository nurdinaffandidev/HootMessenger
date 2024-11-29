//
//  ProfileViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 7/11/24.
//

import UIKit
import Combine
import SnapKit
import SDWebImage

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
                case .downloadProfilePicUrlSuccess(let url):
                    self.updateProfileImage(path: url)
                case .downloadProfilePicUrlFail:
                    self.updateDefaultProfileImage()
                case .logoutSuccess:
                    NotificationCenter.default.post(name: .didLoggedOutNotification, object: nil)
                case .logoutFail:
                    break // TODO: alert
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiEvents.send(.viewDidLoad)
        setup()
        updateData()
        setupLayoutConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarTitle()
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
    
    private lazy var profilePicImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.systemTeal.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(
            systemName: "person.circle"
        )?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .systemTeal
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "TrebuchetMS", size: 25)
        label.textColor = .systemTeal
        return label
    }()
    
    private lazy var tableHeaderView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .leading
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.layoutMargins = UIEdgeInsets(
            top: 10,
            left: 16,
            bottom: 10,
            right: 16
        )
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        setupTableHeaderView()
    }
    
    func setupTableHeaderView() {
        tableHeaderView.addArrangedSubview(profilePicImageView)
        tableHeaderView.setCustomSpacing(10, after: profilePicImageView)
        tableHeaderView.addArrangedSubview(nameLabel)

        tableHeaderView.layoutIfNeeded()
        tableView.tableHeaderView = tableHeaderView
        
        tableHeaderView.snp.makeConstraints {
            $0.leading.equalTo(view.snp.leading)
            $0.trailing.equalTo(view.snp.trailing)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
        }
        
        profilePicImageView.layoutIfNeeded()
        profilePicImageView.layer.cornerRadius = profilePicImageView.width / 2
        
        let fullName = UserDefaults.standard.string(forKey: "fullName")
        if let fullName = fullName, !fullName.contains("google_no_last_name_found") {
            nameLabel.text = fullName
        } else {
            nameLabel.text = UserDefaults.standard.string(forKey: "firstName")
        }
        
    }
    
    func setupLayoutConstraints() {
        let safeAreaLayout = view.safeAreaLayoutGuide
        let margins = view.layoutMarginsGuide
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayout.snp.top)
            $0.bottom.equalTo(safeAreaLayout.snp.bottom)
        }
    }
    
    func updateProfileImage(path: URL) {
        profilePicImageView.tintColor = .clear
        profilePicImageView.sd_setImage(with: path, completed: nil)
    }
    
    func updateDefaultProfileImage() {
        profilePicImageView.image = UIImage(
            systemName: "person.circle"
        )?.withRenderingMode(.alwaysTemplate)
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
                                resetNavBarOnLogout()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y > 0 ? 
        updateNavigationBarOnScroll() : 
        CommonUtils.defaultNavigationBar(self, setupNavBarTitle())
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

// MARK: Navigation Bar
extension ProfileViewController {
    func setupNavBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Profile"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .systemTeal
        titleLabel.sizeToFit()
        let titleView = UIBarButtonItem(customView: titleLabel)
        self.navigationController?.viewControllers.first?.navigationItem.leftBarButtonItem = titleView
        self.navigationController?.viewControllers.first?.navigationItem.rightBarButtonItem = nil
        self.navigationController?.viewControllers.first?.navigationItem.titleView = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    func updateNavigationBarOnScroll() {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 103)
        gradient.colors = [UIColor.white.cgColor, UIColor.systemTeal.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.75)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        let bgImage = UIImage.fromLayer(layer: gradient)
        self.navigationController?.viewControllers.first?.navigationItem.leftBarButtonItem = nil
        self.navigationController?.navigationBar.setBackgroundImage(bgImage, for: .default)
        self.navigationController?.viewControllers.first?.navigationController?.navigationBar.tintColor = .systemTeal
        setupCenterTitle()
    }
    
    func setupCenterTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Profile"
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.sizeToFit()
        titleLabel.textColor = .systemTeal
        self.navigationController?.viewControllers.first?.navigationItem.titleView = titleLabel
    }
    
    func resetNavBarOnLogout() {
        self.navigationController?.viewControllers.first?.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.viewControllers.first?.navigationController?.navigationBar.tintColor = nil
        self.navigationController?.viewControllers.first?.navigationItem.titleView = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = .clear
    }
}


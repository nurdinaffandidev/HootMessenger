//
//  ConversationsViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import UIKit
import Combine

class ConversationsViewController: UIViewController {
    private var viewModel: ConversationsViewModel
    private var uiEvents = PassthroughSubject<ConversationsViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: ConversationsViewModel) {
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
                case .fetchConversationsSuccess:
                    break // show convo
                case .fetchConversationsFail:
                    break // show empty convo 
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBarTitle()
        setupComposeChatButton()
    }
    
    @objc func didTapComposeButton() {
        let viewModel = NewConversationsViewModel(service: viewModel.service)
        let viewController = NewConversationViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: viewController)
        self.present(nav, animated: true)
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = false
        return table
    }()
    
    private lazy var noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        setupLayoutConstraints()
    }
    
    func setupLayoutConstraints() {
        let safeAreaLayout = view.safeAreaLayoutGuide
        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(safeAreaLayout.snp.top)
            $0.bottom.equalTo(safeAreaLayout.snp.bottom)
        }
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:  indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        uiEvents.send(.routeToChat)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y > 0 ? updateNavigationBarOnScroll() : defaultNavigationBar()
    }
}

// MARK: Navigation Bar
extension ConversationsViewController {
    func setupNavBarTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "Chats"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .systemTeal
        titleLabel.sizeToFit()
        let titleView = UIBarButtonItem(customView: titleLabel)
        self.navigationController?.viewControllers.first?.navigationItem.leftBarButtonItem = titleView
        self.navigationController?.viewControllers.first?.navigationItem.titleView = nil
    }
    
    func setupComposeChatButton() {
        let composeChatButton = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(didTapComposeButton)
        )
        self.navigationController?.viewControllers.first?.navigationItem.rightBarButtonItem = composeChatButton
        self.navigationController?.viewControllers.first?.navigationItem.rightBarButtonItem?.tintColor = .systemTeal
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
        titleLabel.text = "Chats"
        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.sizeToFit()
        titleLabel.textColor = .systemTeal
        self.navigationController?.viewControllers.first?.navigationItem.titleView = titleLabel
    }
    
    func defaultNavigationBar() {
        self.navigationController?.viewControllers.first?.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.viewControllers.first?.navigationController?.navigationBar.tintColor = nil
        self.navigationController?.viewControllers.first?.navigationItem.titleView = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.barTintColor = .white
        setupNavBarTitle()
    }
}

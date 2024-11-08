//
//  ProfileViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 7/11/24.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {
    private var viewModel: ProfileViewModel
    private var uiEvents = PassthroughSubject<ProfileViewModel.UIEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
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
                case .logoutDone:
                    break
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .systemGreen
    }
}


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
                case .validationSuccess:
                    break
                case .validationFail:
                    uiEvents.send(.presentLoginScreen)
                }
            }.store(in: &cancellables)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setup
    func setup() {
        view.backgroundColor = .systemTeal
    }
}

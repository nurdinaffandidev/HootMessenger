//
//  ConversationsViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 3/11/24.
//

import Foundation
import Combine
import FirebaseAuth

class ConversationsViewModel {
    private let coordinator: Coordinating
    private var viewModelEvent = PassthroughSubject<ViewModelEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: Coordinating) {
        self.coordinator = coordinator
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Functions
    func validateAuthorization() {
        FirebaseAuth.Auth.auth().currentUser == nil ?
        viewModelEvent.send(.validationFail) :
        viewModelEvent.send(.validationSuccess)
    }
    
    func presentLoginScreen() {
        coordinator.presentLoginScreen()
    }
}

// MARK: Event Handling
extension ConversationsViewModel {
    enum UIEvent {
        case viewDidLoad
        case presentLoginScreen
    }
    
    enum ViewModelEvent {
        case validationSuccess
        case validationFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case.viewDidLoad:
                self.validateAuthorization()
            case .presentLoginScreen:
                self.presentLoginScreen()
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

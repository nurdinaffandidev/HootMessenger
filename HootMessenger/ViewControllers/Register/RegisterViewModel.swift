//
//  RegisterViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 29/10/24.
//

import Foundation
import Combine

final class RegisterViewModel {
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
    func routeToLoginPage() {
        coordinator.presentLoginScreen()
    }
}

// MARK: Event Handling
extension RegisterViewModel {
    enum UIEvent {
        case backButtonPressed
        case submitRegisterDetails(username: String, password: String)
        case routeToConversations
    }

    enum ViewModelEvent {
        case registerSuccess
        case registerFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .backButtonPressed:
                self.routeToLoginPage()
            case .submitRegisterDetails(let username, let password):
                break
            case .routeToConversations:
                break
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

//
//  LoginViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 26/10/24.
//

import Foundation
import Combine

final class LoginViewModel {
    private let coordinator: Coordinating
    private var viewModelEvent = PassthroughSubject<ViewModelEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: Coordinating) {
        self.coordinator = coordinator
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: Event Handling
extension LoginViewModel {
    enum UIEvent {
        case registerButtonPressed
        case submitLoginDetails(username: String, password: String)
        case routeToConversations
    }

    enum ViewModelEvent {
        case loginSuccess
        case loginFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .registerButtonPressed:
                break
            case .submitLoginDetails(let username, let password):
                break
            case .routeToConversations:
                break
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

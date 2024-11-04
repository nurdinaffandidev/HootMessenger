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
    private let service: APIServicing
    private var viewModelEvent = PassthroughSubject<ViewModelEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: Coordinating, service: APIServicing) {
        self.coordinator = coordinator
        self.service = service
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Functions
    func routeToRegisterScreen() {
        coordinator.presentRegisterScreen()
    }
    
    func submitLoginDetails(_ email: String, _ password: String) {
        
    }
}

// MARK: Event Handling
extension LoginViewModel {
    enum UIEvent {
        case registerButtonPressed
        case submitLoginDetails(email: String, password: String)
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
                self.routeToRegisterScreen()
            case .submitLoginDetails(let email, let password):
                self.submitLoginDetails(email, password)
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

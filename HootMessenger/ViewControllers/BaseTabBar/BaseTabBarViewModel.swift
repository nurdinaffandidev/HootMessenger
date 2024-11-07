//
//  BaseTabBarViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 6/11/24.
//

import Foundation
import Combine
import FirebaseAuth

class BaseTabBarViewModel {
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
    func validateAuthorization() {
        service.validateAuthorization() ?
        viewModelEvent.send(.validationFail) :
        viewModelEvent.send(.validationSuccess)
    }
    
    func presentLoginScreen() {
        coordinator.presentLoginScreen()
    }
}

// MARK: Event Handling
extension BaseTabBarViewModel {
    enum UIEvent {
        case viewDidAppear
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
            case .viewDidAppear:
                self.validateAuthorization()
            case .presentLoginScreen:
                self.presentLoginScreen()
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}


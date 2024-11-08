//
//  ProfileViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 7/11/24.
//

import Foundation
import Combine

class ProfileViewModel {
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
    
    func presentLoginScreen() {
        coordinator.presentLoginScreen()
    }
}

// MARK: Event Handling
extension ProfileViewModel {
    enum UIEvent {
        case viewDidLoad
        case logout
    }
    
    enum ViewModelEvent {
        case logoutDone
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                break
            case .logout:
                break
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

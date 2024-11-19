//
//  NewConversationsViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 19/11/24.
//

import Foundation
import Combine

class NewConversationsViewModel {
    private let service: APIServicing
    private var viewModelEvent = PassthroughSubject<ViewModelEvent, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(service: APIServicing) {
        self.service = service
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    // MARK: - Functions
    
}

// MARK: Event Handling
extension NewConversationsViewModel {
    enum UIEvent {
        case viewDidLoad
    }
    
    enum ViewModelEvent {
        case fetchUsersSuccess
        case fetchUsersFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                break
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

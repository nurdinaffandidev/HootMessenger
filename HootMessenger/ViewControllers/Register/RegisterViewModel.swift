//
//  RegisterViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 29/10/24.
//

import Foundation
import Combine
import UIKit

final class RegisterViewModel {
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
    func routeToLoginScreen() {
        coordinator.presentLoginScreen()
    }
    
    func submitRegisterationDetails(
        _ firstName: String,
        _ lastName: String,
        _ email: String,
        _ password: String,
        _ userImage: UIImage
    ) {
        Task {
            service.userExists(with: email) { exists in
                guard !exists else {
                    // user already exists
                    self.viewModelEvent.send(.registerUserExists)
                    return
                }
            }
            
            do {
                let result = try await service.createUser(
                    withEmail: email,
                    password: password
                )
                print("Created User: \(result.user)")
                
                let chatUser = ChatAppUser(
                    firstName: firstName,
                    lastName: lastName,
                    emailAddress: email
                )
                service.insertUser(with: chatUser)
                viewModelEvent.send(.registerSuccess)
            } catch let error {
                print("Create User Error: \(String (describing: error))")
                viewModelEvent.send(.registerFail)
            }
        }
    }
    
    func routeToConversationsScreen() {
        coordinator.dismissPresentedView()
    }
}

// MARK: Event Handling
extension RegisterViewModel {
    enum UIEvent {
        case backButtonPressed
        case submitRegisterDetails(
            firstName: String,
            lastName: String,
            email: String,
            password: String,
            userImage: UIImage
        )
        case routeToConversationsScreen
    }

    enum ViewModelEvent {
        case registerSuccess
        case registerUserExists
        case registerFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .backButtonPressed:
                self.routeToLoginScreen()
            case .submitRegisterDetails(
                let firstName,
                let lastName,
                let email,
                let password,
                let userImage
            ):
                self.submitRegisterationDetails(
                    firstName,
                    lastName,
                    email,
                    password,
                    userImage
                )
            case .routeToConversationsScreen:
                self.routeToConversationsScreen()
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

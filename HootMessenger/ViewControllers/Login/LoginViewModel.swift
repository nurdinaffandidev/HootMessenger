//
//  LoginViewModel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 26/10/24.
//

import Foundation
import Combine
import UIKit
import GoogleSignIn

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
        Task {
            do {
                let result = try await service.signIn(withEmail: email, password: password)
                NotificationCenter.default.post(name: .didLoggedInNotification, object: nil)
                print("Logged in User: \(result.user)")
                UserDefaults.standard.set(email, forKey: "email")
                viewModelEvent.send(.loginSuccess)
            } catch {
                viewModelEvent.send(.loginFail)
            }
        }
    }
    
    func routeToConversationsScreen() {
        coordinator.dismissPresentedView()
    }
    
    func performGoogleSignIn(_ viewController: UIViewController) {
        Task {
            let result = await service.signInWithGoogle(presentOver: viewController)
            guard let googleUser = result,
                  let email = googleUser.profile?.email,
                  let firstName = googleUser.profile?.givenName
            else {
                viewModelEvent.send(.googleSignInFail)
                return
            }
            
            let lastName = googleUser.profile?.familyName ?? "google_no_last_name_found"
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "fullName")
            UserDefaults.standard.set("\(firstName)", forKey: "firstName")
            UserDefaults.standard.set("\(lastName)", forKey: "lastName")
            
            let userExists = await service.userExists(with: email)
            if !userExists {
                let chatUser = ChatAppUser(
                    firstName: firstName,
                    lastName: lastName,
                    emailAddress: email
                )
                do {
                    try await service.insertUser(with: chatUser)
                    try await service.uploadProfilePictureGoogleSignIn(
                        user: chatUser,
                        googleUser: googleUser
                    )
                } catch let error {
                    if let storageError = error as? StorageError {
                        switch storageError {
                        case .failedToGetGoogleProfileImage:
                            try await service.uploadDefaultImage(user: chatUser)
                        default:
                            break
                        }
                        NotificationCenter.default.post(name: .didLoggedInNotification, object: nil)
                        viewModelEvent.send(.loginSuccess)
                    } else {
                        viewModelEvent.send(.loginFail)
                    }
                }
            }
            NotificationCenter.default.post(name: .didLoggedInNotification, object: nil)
            viewModelEvent.send(.loginSuccess)
        }
    }
}

// MARK: Event Handling
extension LoginViewModel {
    enum UIEvent {
        case registerButtonPressed
        case submitLoginDetails(email: String, password: String)
        case routeToConversationsScreen
        case performGoogleSignIn(_ vc: UIViewController)
    }

    enum ViewModelEvent {
        case loginSuccess
        case loginFail
        case googleSignInFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .registerButtonPressed:
                self.routeToRegisterScreen()
            case .submitLoginDetails(let email, let password):
                self.submitLoginDetails(email, password)
            case .routeToConversationsScreen:
                self.routeToConversationsScreen()
            case .performGoogleSignIn(let vc):
                self.performGoogleSignIn(vc)
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

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
    
    func logout() {
        do {
            try service.logout()
            viewModelEvent.send(.logoutSuccess)
        } catch {
            print("Error logging out")
            viewModelEvent.send(.logoutFail)
        }
    }
    
    func downloadProfilePicUrl() {
        Task {
            do {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
                let safeEmail = CommonUtils.safeEmail(emailAddress: email)
                let filename = safeEmail + "_profile_picture.png"
                let path = "images/"+filename
                let url = try await service.downloadUrl(path: path)
                viewModelEvent.send(.downloadProfilePicUrlSuccess(url))
            } catch {
                viewModelEvent.send(.downloadProfilePicUrlFail)
            }
        }
    }
}

// MARK: Event Handling
extension ProfileViewModel {
    enum UIEvent {
        case viewDidLoad
        case logout
    }
    
    enum ViewModelEvent {
        case downloadProfilePicUrlSuccess(_ url: URL)
        case downloadProfilePicUrlFail
        case logoutSuccess
        case logoutFail
    }
    
    func bind(_ uiEvents: AnyPublisher<UIEvent, Never>) -> AnyPublisher<ViewModelEvent, Never> {
        uiEvents.sink { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .viewDidLoad:
                self.downloadProfilePicUrl()
            case .logout:
                self.logout()
            }
        }.store(in: &cancellables)
        return viewModelEvent.eraseToAnyPublisher()
    }
}

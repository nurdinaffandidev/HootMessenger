//
//  Coordinator.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import Foundation
import UIKit

final class Coordinator: Coordinating {
    var navigationCoordinator: NavigationCoordinating
    var service: APIServicing = APIService.shared
    
    init(navigationController: NavigationCoordinating) {
        self.navigationCoordinator = navigationController
    }
    
    func presentLoginScreen() {
        let viewModel = LoginViewModel(coordinator: self, service: service)
        let viewController = LoginViewController(viewModel: viewModel)
        viewController.isModalInPresentation = true
        DispatchQueue.main.async {
            if self.navigationCoordinator.navigationController.isModalInPresentation {
                self.navigationCoordinator.navigationController.dismiss(animated: false)
            }
            self.navigationCoordinator.presentViewController(viewController, animated: true)
        }
    }
    
    func goToLoginScreen() {
        let viewModel = LoginViewModel(coordinator: self, service: service)
        DispatchQueue.main.async {
            self.navigationCoordinator.pushViewController(to: LoginViewController(viewModel: viewModel), animated: false)
        }
    }
    
    func presentRegisterScreen() {
        let viewModel = RegisterViewModel(coordinator: self, service: service)
        let viewController = RegisterViewController(viewModel: viewModel)
        viewController.isModalInPresentation = true
        DispatchQueue.main.async {
            if self.navigationCoordinator.navigationController.isModalInPresentation {
                self.navigationCoordinator.navigationController.dismiss(animated: false)
            }
            self.navigationCoordinator.presentViewController(viewController, animated: true)
        }
    }
    
    func goToConversationsScreen() {
        let viewModel = ConversationsViewModel(coordinator: self, service: service)
        DispatchQueue.main.async {
            self.navigationCoordinator.pushViewController(to: ConversationsViewController(viewModel: viewModel), animated: true)
        }
    }
    
    func goToChatScreen() {
        let viewModel = ChatViewModel(coordinator: self, service: service)
        DispatchQueue.main.async {
            self.navigationCoordinator.pushViewController(to: ChatViewController(viewModel: viewModel), animated: true)
        }
    }
    
    func dismissPresentedView() {
        DispatchQueue.main.async {
            self.navigationCoordinator.navigationController.dismiss(animated: true)
        }
    }
}

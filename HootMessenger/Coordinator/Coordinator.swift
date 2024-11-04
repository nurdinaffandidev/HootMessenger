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
    
    init(navigationController: NavigationCoordinating) {
        self.navigationCoordinator = navigationController
    }
    
    func presentLoginScreen() {
        let viewModel = LoginViewModel(coordinator: self)
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
        let viewModel = LoginViewModel(coordinator: self)
        DispatchQueue.main.async {
            self.navigationCoordinator.pushViewController(to: LoginViewController(viewModel: viewModel), animated: false)
        }
    }
    
    func presentRegisterScreen() {
        let viewModel = RegisterViewModel(coordinator: self)
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
        let viewModel = ConversationsViewModel(coordinator: self)
        DispatchQueue.main.async {
            self.navigationCoordinator.pushViewController(to: ConversationsViewController(viewModel: viewModel), animated: true)
        }
    }
}

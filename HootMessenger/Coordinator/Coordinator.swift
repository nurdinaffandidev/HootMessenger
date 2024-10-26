//
//  Coordinator.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import Foundation
import UIKit

final class Coordinator: Coordinating {
    var navigationController: NavigationCoordinating
    
    init(navigationController: NavigationCoordinating) {
        self.navigationController = navigationController
    }
    
    func presentLoginScreen() {
        let viewModel = LoginViewModel(coordinator: self)
        let viewController = LoginViewController(viewModel: viewModel)
        viewController.isModalInPresentation = true
        navigationController.presentViewController(viewController, animated: false)
    }
    
    func goToLoginScreen() {
        let viewModel = LoginViewModel(coordinator: self)
        navigationController.pushViewController(to: LoginViewController(viewModel: viewModel), animated: false)
    }
}

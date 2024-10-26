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
        navigationController.presentViewController(LoginViewController(viewModel: viewModel), animated: true)
    }
}

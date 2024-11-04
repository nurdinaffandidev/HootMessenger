//
//  NavigationCoordinator.swift
//  HootMessenger
//
//  Created by nurdin affandi on 26/10/24.
//

import Foundation
import UIKit

class NavigationCoordinator: NSObject, NavigationCoordinating {
    var navigationController = UINavigationController()
    var firstViewController: UIViewController?
    
    func start(animated: Bool) {
        let coordinator = Coordinator(navigationController: self)
        let viewModel = ConversationsViewModel(coordinator: coordinator)
        let firstViewController = ConversationsViewController(viewModel: viewModel)
        self.firstViewController = firstViewController
        navigationController.pushViewController(firstViewController, animated: animated)
    }
}

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
        let service = APIService.shared
        let viewModel = BaseTabBarViewModel(coordinator: coordinator, service: service)
        let firstViewController = BaseTabBarController(viewModel: viewModel)
        self.firstViewController = firstViewController
        navigationController.pushViewController(firstViewController, animated: animated)
    }
}

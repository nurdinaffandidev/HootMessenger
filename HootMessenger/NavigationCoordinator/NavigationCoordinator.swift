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
        let firstViewController = ConversationsViewController(coordinator: Coordinator(navigationController: self))
        self.firstViewController = firstViewController
        navigationController.pushViewController(firstViewController, animated: animated)
    }
}

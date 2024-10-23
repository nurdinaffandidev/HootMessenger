//
//  Coordinator.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import Foundation
import UIKit

final class Coordinator: NSObject, Coordinating {
    var navigationController = UINavigationController()
    var firstViewController: UIViewController?
    
    static let shared = Coordinator()
    
    func start(animated: Bool) {
        let firstViewController = ConversationsViewController()
        self.firstViewController = firstViewController
        navigationController.pushViewController(firstViewController, animated: animated)
    }
}

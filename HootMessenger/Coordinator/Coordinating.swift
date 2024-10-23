//
//  Coordinating.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import Foundation
import UIKit

protocol Coordinating: AnyObject {
    /// The navigation controller for the coordinator
    var navigationController: UINavigationController { get set }
    
    /**
     The NavigationCoordinator takes control and activates itself.
     - Parameters:
        - animated: Set the value to true to animate the transition. Pass false if you are setting up a navigation controller before its view is displayed.
     
    */
    func start(animated: Bool)
    
    func popViewController(animated: Bool, transitionType: CATransitionType)
    func popToViewController(to viewController: UIViewController, animated: Bool)
    func pushViewController(to viewController: UIViewController, animated: Bool)
}

extension Coordinating {
    /**
     Pops the top view controller from the navigation stack and updates the display.
     
     - Parameters:
     - animated: Set this value to true to animate the transition.
     */
    
    func popViewController(animated: Bool = true, transitionType: CATransitionType = .push) {
        navigationController.popViewController(animated: animated)
    }
    
    /**
     Pops view controllers until the specified view controller is at the top of the navigation stack.
     - Parameters:
     - to viewController: The view controller that you want to be at the top of the stack. This view controller must currently be on the navigation stack.
     - animated: Set this value to true to animate the transition.
     */
    func popToViewController(to viewController: UIViewController, animated: Bool = true) {
        navigationController.popToViewController(viewController, animated: animated)
    }
    
    /**
     Pushes a view controller onto the receiver’s stack and updates the display.
     - Parameters:
     - to viewController: The view controller to push onto the stack. This object cannot be a tab bar controller. If the view controller is already on the navigation stack, this method throws an exception.
     - animated: Set this value to true to animate the transition.
     */
    func pushViewController(to viewController: UIViewController, animated: Bool = true) {
        navigationController.pushViewController(viewController, animated: animated)
    }
}

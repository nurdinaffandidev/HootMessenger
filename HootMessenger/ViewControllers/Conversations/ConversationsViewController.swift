//
//  ConversationsViewController.swift
//  HootMessenger
//
//  Created by nurdin affandi on 23/10/24.
//

import UIKit

class ConversationsViewController: UIViewController {
    private let coordinator: Coordinating
    
    init(coordinator: Coordinating) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        if !isLoggedIn {
            coordinator.goToLoginScreen()
//            coordinator.presentLoginScreen()
        }
    }
}


//
//  CommonUtils.swift
//  HootMessenger
//
//  Created by nurdin affandi on 26/11/24.
//

import Foundation
import UIKit

class CommonUtils {
    static func defaultNavigationBar(_ view: UIViewController, _ closure: ()) {
        view.navigationController?.viewControllers.first?.navigationController?.navigationBar.backgroundColor = .white
        view.navigationController?.viewControllers.first?.navigationController?.navigationBar.tintColor = nil
        view.navigationController?.viewControllers.first?.navigationItem.titleView = nil
        view.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        view.navigationController?.navigationBar.barTintColor = .white
        closure
    }
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

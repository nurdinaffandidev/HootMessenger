//
//  FillMainContentViewController.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

open class FillMainContentViewController: BaseViewController, ViewControllerLayoutable {
    public typealias LayoutType = FillMainContentLayout
    
    open override func initializeLayout() {
        layout = FillMainContentLayout(view: view)
    }
}

extension FillMainContentViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}

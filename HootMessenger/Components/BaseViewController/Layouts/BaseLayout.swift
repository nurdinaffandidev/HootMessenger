//
//  BaseLayout.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

open class BaseLayout: Layout {
    weak var _view: UIView?
    open weak var view: UIView? {
        get {
            return _view
        }
        set {
            _view = newValue
        }
    }
    
    public init(view: UIView) {
        self.view = view
    }
    
    open func willSetupViews() { }
    
    open func setupViews() { }
    
    open func didSetupViews() { }
    
    open func willSetLayoutContraints() { }
    
    open func setLayoutContraints() { }
    
    open func didSetLayoutContraints() { }
}

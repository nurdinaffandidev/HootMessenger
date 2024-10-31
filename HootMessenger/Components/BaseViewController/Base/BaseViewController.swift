//
//  BaseViewController.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

open class BaseViewController: UIViewController {
    open var layout: Layout?
    
    open var shouldHideKeyboardWhenTappedAround = true
    
    open func initializeLayout() {
        layout = FillMainContentLayout(view: view)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        initializeLayout()
        
        willSetupViews()
        setupViews()
        didSetupViews()
        
        willSetLayoutContraints()
        setLayoutContraints()
        didSetLayoutContraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open func willSetupViews() {
        layout?.willSetupViews()
    }
    
    open func setupViews() {
        layout?.setupViews()
    }
    
    open func didSetupViews() {
        layout?.didSetupViews()
    }
    
    open func willSetLayoutContraints() {
        layout?.willSetLayoutContraints()
    }
    
    open func setLayoutContraints() {
        layout?.setLayoutContraints()
    }
    
    open func didSetLayoutContraints() {
        layout?.didSetLayoutContraints()
    }
}

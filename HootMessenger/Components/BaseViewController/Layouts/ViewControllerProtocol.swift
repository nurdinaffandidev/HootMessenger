//
//  ViewController.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

public protocol ViewControllerProtocol: AnyObject {
    func willSetupViews()
    func setupViews()
    func didSetupViews()
    
    func willSetLayoutContraints()
    func setLayoutContraints()
    func didSetLayoutContraints()
}

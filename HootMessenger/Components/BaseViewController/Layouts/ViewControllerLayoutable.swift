//
//  ViewControllerLayoutable.swift
//  FillMainLayout
//
//  Created by nurdin affandi on 28/10/24.
//

import Foundation
import UIKit

public protocol ViewControllerLayoutable: ViewControllerProtocol {
    associatedtype LayoutType where LayoutType: Layout
    var layout: Layout? { get set }
    func initializeLayout()
}

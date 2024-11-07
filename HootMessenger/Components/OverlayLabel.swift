//
//  OverlayLabel.swift
//  HootMessenger
//
//  Created by nurdin affandi on 6/11/24.
//

import Foundation
import UIKit

class OverlayLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(
            in: rect.inset(
                by: UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: 10,
                    right: 0
                )
            )
        )
    }
}

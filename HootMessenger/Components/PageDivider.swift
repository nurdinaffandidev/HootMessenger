//
//  PageDivider.swift
//  HootMessenger
//
//  Created by nurdin affandi on 12/11/24.
//

import Foundation
import UIKit

/// Page divider of type Solid thin
public class PageDivider: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        self.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.backgroundColor = .systemGray
    }
}


//
//  Extension++.swift
//  HootMessenger
//
//  Created by nurdin affandi on 26/10/24.
//

import Foundation
import UIKit

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
    
    public var topPadding: CGFloat {
        return window?.safeAreaInsets.top ?? .zero
    }
    
    public var bottomPadding: CGFloat {
        return window?.safeAreaInsets.bottom ?? .zero
    }

}

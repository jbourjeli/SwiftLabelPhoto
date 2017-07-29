//
//  UIColor+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/13/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

extension UIColor {
    open static func lemonChiffon() -> UIColor {
        return UIColor(red: 1.0, green: 250/255, blue: 205/255, alpha: 1.0)
    }
    
    // MARK: - Colors from bootstrap
    // http://v4-alpha.getbootstrap.com/components/buttons/
    
    open static func primary() -> UIColor {
        return UIColor(hexVal: 0x0275d8, alpha: 1.0)
    }
    
    open static func secondary() -> UIColor {
        return UIColor(hexVal: 0xffffff, alpha: 1.0)
    }
    
    open static func danger() -> UIColor {
        return UIColor(hexVal: 0xd9534f, alpha: 1.0)
    }
    
    open static func success() -> UIColor {
        return UIColor(hexVal: 0x5cb85c, alpha: 1.0)
    }
    
    open static func info() -> UIColor {
        return UIColor(hexVal: 0x5bc0de, alpha: 1.0)
    }
    
    open static func warning() -> UIColor {
        return UIColor(hexVal: 0xf0ad4e, alpha: 1.0)
    }
    
    // MARK: - Initializers
    
    convenience init(hexVal:Int, alpha: CGFloat) {
        self.init(red: CGFloat((hexVal >> 16) & 0xff)/255.0,
                  green: CGFloat((hexVal >> 8) & 0xff)/255.0,
                  blue: CGFloat(hexVal & 0xff) / 255.0,
                  alpha: alpha)
    }
}

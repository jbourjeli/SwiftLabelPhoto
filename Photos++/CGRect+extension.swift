//
//  CGRect+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/1/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

extension CGRect {
    public var aspectRatio: CGFloat {
        get {
            return self.size.aspectRatio
        }
    }
}

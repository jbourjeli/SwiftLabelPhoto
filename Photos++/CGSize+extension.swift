//
//  CGSize+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/3/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

extension CGSize {
    public var aspectRatio: CGFloat {
        get {
            return self.width / self.height
        }
    }
}

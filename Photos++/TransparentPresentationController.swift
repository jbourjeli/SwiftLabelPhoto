//
//  TransparentPresentationController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/29/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

class TransparentPresentationController: UIPresentationController {
    override public var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = self.containerView else { return CGRect.zero }
            
            return CGRect(x: CGFloat(0.0),
                          y: 0,
                          width: containerView.bounds.width,
                          height: containerView.bounds.height)
        }
    }
}

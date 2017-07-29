//
//  HalfScreenPresentationController.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/28/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public class HalfScreenPresentationController: UIPresentationController {
    public enum AnchorPoint {
        case Top, Bottom
    }
    
    open var anchor = AnchorPoint.Bottom
    
    public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, anchor: AnchorPoint = .Bottom) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        self.anchor = anchor
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = self.containerView else { return CGRect.zero }

            var frame: CGRect
            
            switch self.anchor {
            case .Top:
                frame = CGRect(x: CGFloat(0.0),
                               y: CGFloat(0.0),
                               width: containerView.bounds.width,
                               height: containerView.bounds.height/2)
            default:
                frame = CGRect(x: CGFloat(0.0),
                               y: containerView.bounds.height/2,
                               width: containerView.bounds.width,
                               height: containerView.bounds.height/2)
            }
            
            return frame
        }
    }
}

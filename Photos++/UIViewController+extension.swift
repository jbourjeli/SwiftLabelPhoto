//
//  UIViewController+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/10/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func blockUI(withMessage message: String? = nil) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.showWaitOverlayWithText(message ?? "")
        
        /*let blockUIViewController = BlockUIViewController()
         if let message = message {
         blockUIViewController.textLabel.text = message
         }
         blockUIViewController.activityIndicator.startAnimating()
         self.present(blockUIViewController, animated: false, completion: nil)
         */
    }
    
    public func unblockUI() {
        UIApplication.shared.endIgnoringInteractionEvents()
        self.removeAllOverlays()
        
        /*guard let blockUIViewController = self.presentedViewController as? BlockUIViewController else { return }
         
         blockUIViewController.activityIndicator.stopAnimating()
         self.dismiss(animated: false)*/
    }
}

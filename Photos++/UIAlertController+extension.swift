//
//  UIAlertController+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/14/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

public extension UIAlertController {
    public static func alert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        return alertController
    }
    
    public static func yesNoAlert(title: String, message: String, destructiveYes: Bool = false, yesHandler: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: (destructiveYes ? .destructive : .default),
                                      handler: yesHandler))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        return alert
    }
}


extension UIViewController {
    public enum AlertType: String {
        case error="Error"
        case warning="Warning"
        case success="Success"
    }
    
    public func presentAlert(ofType alertType: AlertType, withMessage message: String) {
        self.present(UIAlertController.alert(title: alertType.rawValue, message: message), animated: true, completion: nil)
    }
}

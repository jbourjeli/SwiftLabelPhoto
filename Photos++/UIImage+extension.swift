//
//  UIImage+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/6/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

extension UIImage {    
    public func scaleToSize(_ size: CGSize, andPreserveAspectRatio preserveAspectRatio: Bool) -> UIImage {
        let scaledSize: CGSize!
        
        if preserveAspectRatio {
            let aspectRatio = self.size.aspectRatio
            scaledSize = CGSize(width: size.height*aspectRatio,
                                height: size.height)
        } else {
            scaledSize = size
        }
        
        let scale = max(scaledSize.width/self.size.width, scaledSize.height/self.size.height)
        
        let width = self.size.width * scale;
        let height = self.size.height * scale;
        let imageRect = CGRect(x: (scaledSize.width - width)/2.0,
                               y: (scaledSize.height - height)/2.0,
                               width: width,
                               height: height)
        
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0);
        self.draw(in: imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage!;
    }
    
    public func normalized() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size),
                  blendMode: .normal,
                  alpha: 1)
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalized!
    }
}

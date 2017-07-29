//
//  FontAwesomeService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/23/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import CoreText

public enum FontAwesomeIcon: String{
    case faCheck="\u{f00c}"
    case faCheckSquareO="\u{f046}"
    case faMoney="\u{f0d6}"
    case faCC="\u{f09d}"
    case faCCAmex="\u{f1f3}"
    case faCCDiscover="\u{f1f2}"
    case faCCMastercard="\u{f1f1}"
    case faCCVisa="\u{f1f0}"
    case faBuilding="\u{f1ad}"
    case faHome="\u{f015}"
    case faCar="\u{f1b9}"
    case faEnvelope="\u{f0e0}"
    case faEnvelopeO="\u{f003}"
    case faPhone="\u{f095}"
    case faExternalLink="\u{f08e}"
    case faBan="\u{f05e}"
    case faTable="\u{f0ce}"
    case faRepeat="\u{f01e}"
    case faMinusCircle="\u{f056}"
    case faTrashO="\u{f014}"
    case faArchive="\u{f187}"
    case faEllipsisV="\u{f142}"
    case faEllipsisH="\u{f141}"
    case faFilter="\u{f0b0}"
    case faPencil="\u{f040}"
    case faCameraRetro="\u{f083}"
    case faShareSquareO="\u{f045}"
    case faShareAlt="\u{f1e0}"
    case faShare="\u{f064}"
    case faStar="\u{f005}"
    case faHandPaperO="\u{f256}"
    case faExclamationTriangle="\u{f071}"
    case faThumbsOUp="\u{f087}"
    case faPlus="\u{f067}"
    case faFolderOpen="\u{f07c}"
    case faUser="\u{f007}"
    case faSunO="\u{f185}"
    case faCloud="\u{f0c2}"
    case faBook="\u{f02d}"
    case faCog="\u{f013}"
    case faCogs="\u{f085}"
    case faGavel="\u{f0e3}"
    case faVolumeUp="\u{f028}"
    case faBars="\u{f0c9}"
    case faBarChart="\u{f080}"
    case faCommentO="\u{f0e5}"
    case faCommentsO="\u{f0e6}"
    case faTag="\u{f02b}"
    ;
}

public class FontAwesome {
    let icon: FontAwesomeIcon
    
    var textColor: UIColor {
        didSet {
            self.renderedImage = nil
        }
    }
    
    var size: CGSize {
        didSet {
            self.renderedImage = nil
        }
    }
    
    private var renderedImage: UIImage?
    
    public init(_ icon: FontAwesomeIcon) {
        self.icon = icon
        
        self.textColor = UIColor.black
        self.size = CGSize(width: 10, height: 10)
    }
    
    public convenience init(_ icon: FontAwesomeIcon, textColor: UIColor, size: CGSize) {
        self.init(icon)
        
        self.textColor = textColor
        self.size = size
    }
    
    public convenience init(_ icon: FontAwesomeIcon, size: CGSize) {
        self.init(icon)
        
        self.size = size
    }
    
    public func image() -> UIImage {
        if let renderedImage = self.renderedImage {
            return renderedImage
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(self.size.width / fontAspectRatio, self.size.height)
        let attributedString = NSAttributedString(
            string: self.icon.rawValue as String,
            attributes: [NSFontAttributeName: UIFont.fontAwesomeOfSize(fontSize: fontSize)!,
                         NSForegroundColorAttributeName: self.textColor,
                         NSParagraphStyleAttributeName: paragraph])
        
        UIGraphicsBeginImageContextWithOptions(self.size, false , 0.0)
        let boundingRect = CGRect(x:0,
                          y:(self.size.height - fontSize) / 2,
                          width:self.size.width,
                          height:fontSize)
        attributedString.draw(in: boundingRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.renderedImage = image
        return image!
    }
}

public class FontAwesomeUtils {
    public static let smallFont = UIFont.fontAwesomeOfSize(fontSize: 12)
    
    public static let regularFont = UIFont.fontAwesomeOfSize(fontSize: 16)
    
    public static let bigFont = UIFont.fontAwesomeOfSize(fontSize: 20)
}

public extension UIImage {
    public static func imageFromfontAwesomeIcon(name: FontAwesomeIcon, withTextColor textColor: UIColor, ofSize size: CGSize) -> UIImage {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center
        
        // Taken from FontAwesome.io's Fixed Width Icon CSS
        let fontAspectRatio: CGFloat = 1.28571429
        
        let fontSize = min(size.width / fontAspectRatio, size.height)
        let attributedString = NSAttributedString(string: name.rawValue as String,
                                                  attributes: [NSFontAttributeName: UIFont.fontAwesomeOfSize(fontSize: fontSize)!,
                                                               NSForegroundColorAttributeName: textColor,
                                                               NSParagraphStyleAttributeName: paragraph])
        UIGraphicsBeginImageContextWithOptions(size, false , 0.0)
        attributedString.draw(in: CGRect(x:0, y:(size.height - fontSize) / 2,
                                         width: size.width, height:fontSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

public extension UIFont {
    public static func fontAwesomeOfSize(fontSize: CGFloat) -> UIFont? {
        let name = "FontAwesome"
        if (UIFont.fontNames(forFamilyName: name).isEmpty ) {
            FontLoader.loadFont(name: name)
        }
        
        return UIFont(name: name, size: fontSize)
    }
}

private class FontLoader {
    class func loadFont(name: String) {
        let bundle = Bundle(for: FontLoader.self)
        var fontURL: URL
        let identifier = bundle.bundleIdentifier
        
        if identifier?.hasPrefix("org.cocoapods") == true {
            // If this framework is added using CocoaPods, resources is placed under a subdirectory
            fontURL = bundle.url(forResource: name, withExtension: "otf", subdirectory: "FontAwesome.swift.bundle")! as URL
        } else {
            fontURL = bundle.url(forResource: name, withExtension: "otf")! as URL
        }
        
        let data = NSData(contentsOf: fontURL as URL)!
        
        let provider = CGDataProvider(data: data)
        let font = CGFont(provider!)
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            let errorDescription: CFString = CFErrorCopyDescription(error!.takeUnretainedValue())
            let nsError = error!.takeUnretainedValue() as AnyObject as! NSError
            NSException(name: NSExceptionName.internalInconsistencyException, reason: errorDescription as String, userInfo: [NSUnderlyingErrorKey: nsError]).raise()
        }
    }
}

//
//  ShareViewController.swift
//  Label Photo
//
//  Created by Joseph Bourjeli on 10/24/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

import FWCore

class ShareViewController: SLComposeServiceViewController {

    fileprivate var selectedImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = kUTTypeImage as String
        
        for attachment in content.attachments as! [NSItemProvider] {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
                
                attachment.loadItem(forTypeIdentifier: contentType, options: nil) { [unowned self] data, error in
                    guard error == nil else {
                        self.presentAlert(ofType: .error, withMessage: "Error loading image. [\(error)]")
                        return
                    }
                    
                    if let imageURL = data as? URL {
                        let imageData = try! Data(contentsOf: imageURL)
                        if let image = UIImage(data: imageData) {
                            self.selectedImages.append(image)
                        } else {
                            self.presentAlert(ofType: .error,
                                              withMessage: "There was an error getting the image [byte count=\(imageData.count)]")
                        }
                    }
                }
            }
        }
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        guard self.selectedImages.count > 0 else {
            self.presentAlert(ofType: .error, withMessage: "Nothing to import.")
            return
        }
        
        
        let photoService = Service.photoModelService()
        var photos = [Photo]()
        self.selectedImages.forEach { selectedImage in
            let photo = photoService.photoFrom(image: selectedImage)
            if let contentText = self.contentText, contentText.isNotBlank() {
                photo.addComment(Comment.create(withText: contentText))
            }
            photos.append(photo)
        }
        photoService.add(photos: photos)
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

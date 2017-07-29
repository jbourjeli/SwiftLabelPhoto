//
//  File.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/5/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import PhotosUI
import Realm
import RealmSwift
import Kingfisher

enum PhotoError: Error {
    case NoAssetForImage,
    NoFileForImage,
    NoURLForImage
}

public class Photo: Object {
    private dynamic var originalImageURLData: Data?
    private dynamic var thumbnailData: Data?
    
    private var labels = List<Label>()
    private var comments = List<Comment>()
    
    var thumbnail: UIImage {
        get {
            if self.thumbnailData == nil {
                self.thumbnailData = Data()
            }
            
            return UIImage(data: self.thumbnailData!)!
        }
        set {
            self.thumbnailData = UIImagePNGRepresentation(newValue)
        }
    }
    
    var originalImageURL: URL? {
        get {
            if let originalImageURLData = self.originalImageURLData {
                return URL(dataRepresentation: originalImageURLData, relativeTo: nil)
            }
            
            return nil
        }
    }
        
    func fetchOriginalImage(completionHandler: @escaping (UIImage, Error?) -> Void) {
        if let originalImageURL = self.originalImageURL,
            ImageCache.default.isImageCached(forKey: originalImageURL.absoluteString).cached {
            ImageCache.default.retrieveImage(forKey: originalImageURL.absoluteString,
                                             options: nil,
                                             completionHandler: { (image, cacheType) in
                                                completionHandler(image!, nil)
                })
        } else {
            if let urlData = self.originalImageURLData {
                
                let imageURL = URL(dataRepresentation: urlData, relativeTo: nil)!
                if let scheme = imageURL.scheme {
                    let completionHandler: (UIImage, Error?) -> Void = { [weak self] (image, error) in
                        if let originalImageURL = self?.originalImageURL {
                            ImageCache.default.store(image, forKey: originalImageURL.absoluteString)
                            completionHandler(image, error)
                        }
                    }
                    
                    if scheme == "assets-library" { // Fetch from iOS photo library
                        self.fetchPhotoAsset(withURL: imageURL, resultHandler: completionHandler)
                    } else { // Fetch from local App
                        self.fetchLocalAsset(withURL: imageURL, resultHandler: completionHandler)
                    }
                }
            } else {
                completionHandler(self.thumbnail, PhotoError.NoURLForImage)
            }
        }
    }
    
    func exportToPHAsset(_ completionHandler: ((Error?) -> Void)? = nil) {
        self.fetchOriginalImage { (image, error) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (success, error) in
                completionHandler?(error)
            }
        }
    }
    
    convenience init(fromImage image: UIImage, withThumbnail thumbnail: UIImage, andOriginalImageURI originalImageURL: URL ) {
        self.init()
        
        self.thumbnail = thumbnail
        self.originalImageURLData = originalImageURL.dataRepresentation
        
        ImageCache.default.store(image, forKey: originalImageURL.absoluteString)
    }
    
    // MARK: - Convenience methods
    
    func isLink() -> Bool {
        guard let originalImageURL = self.originalImageURL else { return false }
        
        return !originalImageURL.isFileURL
    }
    
    var size: CGSize {
        get {
            return self.thumbnail.size
        }
    }
    
    // MARK: - Labels
    
    func numberOfLabels() -> Int {
        return self.labels.count
    }
    
    func hasLabel(label: Label) -> Bool {
        return self.labels.index(of: label) != nil
    }
    
    func labelAtIndex(index: Int) -> Label {
        return self.labels[index]
    }
    
    func addLabel(_ label: Label) {
        if !self.labels.contains(label) {
            self.labels.append(label)
        }
    }
    
    func removeLabel(_ label: Label) {
        if let indexOfLabel = self.labels.index(of: label) {
            self.labels.remove(at: indexOfLabel)
        }
    }
    
    // MARK: - Comments
    
    func numberOfComments() -> Int {
        return self.comments.count
    }
    
    func commentAtIndex(index: Int) -> Comment {
        return self.comments[index]
    }
    
    func addComment(_ comment: Comment) {
        self.comments.append(comment)
    }
    
    func removeComment(_ comment: Comment) {
        if let index = self.comments.index(of: comment) {
            self.comments.remove(objectAtIndex: index)
        }
    }
    
    
    // MARK: - Realm overrides
    
    override public static func ignoredProperties() -> [String] {
        return ["thumbnail", "originalImage"]
    }
    
    // MARK: - Privates
    
    fileprivate func fetchPhotoAsset(withURL url: URL, resultHandler: @escaping (UIImage, Error?) -> Void) {
        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
        if fetchResult.count == 1 {
            let imageManager = PHImageManager.default()
            let photoAsset = fetchResult.firstObject!
            imageManager.requestImageData(for: photoAsset,
                                          options:nil) { (imageData, dataUTI, orientation, info) in
                                            if let data = imageData {
                                                resultHandler(UIImage(data: data)!, nil)
                                            } else {
                                                print("ERROR: Info=\(info) : URL=\(url)")
                                                resultHandler(self.thumbnail, nil)
                                            }
            }
        } else {
            resultHandler(self.thumbnail, PhotoError.NoAssetForImage)
        }
    }
    
    fileprivate func fetchLocalAsset(withURL url: URL, resultHandler: @escaping (UIImage, Error?) -> Void) {
        if url.isFileURL {
            do {
                let image = try LocalPhotoRepository().loadImage(withFilename: url.lastPathComponent)
                resultHandler(image, nil)
            } catch let error {
                print("fetchLocalAsset. Error [\(error)]")
                resultHandler(self.thumbnail, PhotoError.NoFileForImage)
            }
            /*do {
                let data = try Data(contentsOf: url)
                resultHandler(UIImage(data: data)!, nil)
            } catch let error {
                print("fetchLocalAsset. Error [\(error)]")
                resultHandler(self.thumbnail, PhotoError.NoFileForImage)
            }*/
        }
    }
}

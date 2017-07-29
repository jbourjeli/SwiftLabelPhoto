//
//  PhotosService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/6/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit
import AVFoundation
import Realm
import RealmSwift
import Kingfisher

public class PhotosService: PhotoModelService {
    fileprivate static let thumbnailSize = CGSize(width: 300, height: 300)
    
    fileprivate var photos: Results<Photo>?
    
    fileprivate lazy var labels: Results<Label> = {
        return self.realm.objects(Label.self)
    }()
    
    fileprivate var filter: String?
    fileprivate var labelFilter: String?
    
    fileprivate var realm: Realm!
    
    fileprivate let photoRepo: PhotoRepository
    
    var photoAlbum: [Photo] {
        get {
            if self.photos == nil {
                self.photos = self.realm.objects(Photo.self)
            }
            
            return Array(photos!)
        }
    }
    
    init() {
        self.photoRepo = LocalPhotoRepository()
        
        self.migrateRealmToAppGroup()
        self.initRealm()
    }
    
    func allPhotos() -> [Photo] {
        if self.photos == nil {
            self.photos = self.realm.objects(Photo.self)
        }
        
        return self.photoAlbum
    }
        
    func numberOfPhotos() -> Int {
        return self.photoAlbum.count
    }
    
    func photoAtIndexPath(_ indexPath: IndexPath) -> Photo? {
        guard (indexPath as NSIndexPath).row < self.photoAlbum.count
            else { return nil }
        
        return self.photoAlbum[(indexPath as NSIndexPath).row]
    }
    
    func indexPathForPhoto(_ photo: Photo) -> IndexPath? {
        if let row = self.photoAlbum.index(of: photo) {
            return IndexPath(item: row, section: 0)
        }
        
        return nil
    }

    
    func newPhotoFromImage(_ image: UIImage, refURL: URL, andLabels labels: Label...) -> Photo {
        let thumbnail = self.createThumbnailFromImage(image)
        let newPhoto = Photo(fromImage: image, withThumbnail: thumbnail, andOriginalImageURI: refURL)
        
        for label in labels {
            newPhoto.addLabel(label)
            
            label.appendLabeledPhoto(photo: newPhoto)
        }
        
        return newPhoto
    }
    
    func photoFrom(image: UIImage, andLabels labels: Label...) -> Photo {
        // TODO: - This may result in saved images with no corresponding Photo (in case photo does not get saved)
        let refURL = try! self.saveImage(image: image)
        
        let thumbnail = self.createThumbnailFromImage(image)
        let photo = Photo(fromImage: image, withThumbnail: thumbnail, andOriginalImageURI: refURL)
        
        for label in labels {
            photo.addLabel(label)
            
            label.appendLabeledPhoto(photo: photo)
        }
        
        return photo
    }
    
    func saveImage(image: UIImage) throws -> URL {
        do {
            let filename = try self.photoRepo.saveImage(image.normalized())
            return URL(string: "file:///\(filename)")!
        } catch let error {
            print("PhotosService.saveImage error [\(error)]")
            
            throw error
        }
    }
    
    func addPhoto(_ photo: Photo) {
        try! self.realm.write {
            realm.add(photo)
        }
    }
    
    func add(photos: [Photo]) {
        try! self.realm.write { [unowned self] in
            self.realm.add(photos)
        }
    }
    
    func deletePhoto(_ photo: Photo) throws {
        if let imageURL = photo.originalImageURL, imageURL.isFileURL {
            do {
                try self.photoRepo.deleteImage(withFilename: imageURL.lastPathComponent)
                self.unlink(photo: photo)
            } catch let error as NSError {
                if let underlyingError = error.userInfo["NSUnderlyingError"] as? NSError {
                    if underlyingError.domain == "NSPOSIXErrorDomain" && underlyingError.code == 2 {
                        // Unable to delete due to File Not Found. 
                        // So it is safe to unlink the photo
                        self.unlink(photo: photo)
                    }
                }
                throw error
            }
        }
    }
    
    func unlink(photo: Photo) {
        if let originalImageURL = photo.originalImageURL {
            ImageCache.default.removeImage(forKey: originalImageURL.absoluteString)
        }
        
        try! self.realm.write {
            realm.delete(photo)
        }
    }
    
    func photo(_ photo: Photo, addLabel label: Label) {
        try! self.realm.write {
            photo.addLabel(label)
            
            label.appendLabeledPhoto(photo: photo)
        }
    }
    
    func photo(_ photo: Photo, removeLabel label: Label) {
        try! self.realm.write {
            photo.removeLabel(label)
            
            label.removeLabeledPhoto(photo: photo)
        }
    }
    
    func photo(_ photo: Photo, addCommentWithText text: String) {
        let comment = Comment()
        comment.text = text
        comment.createdDate = Date()
        
        self.photo(photo, addComment: comment)
    }
    
    func photo(_ photo: Photo, addComment comment: Comment) {
        try! self.realm.write {
            photo.addComment(comment)
        }
    }
    
    func photo(_ photo: Photo, removeComment comment: Comment) {
        try! self.realm.write {
            photo.removeComment(comment)
        }
    }
    
    func createThumbnailFromImage(_ image: UIImage) -> UIImage {
        return image.scaleToSize(PhotosService.thumbnailSize,
                                 andPreserveAspectRatio: true)
    }
    
    func setFilter(pattern: String?, caseSensitive: Bool) {
        self.filter = pattern
        self.photos = self.realm.objects(Photo.self)
        if let filter = self.filter, filter.isNotBlank() {
            var predicateFormat: String!
            if caseSensitive {
                predicateFormat = "ANY labels.longName CONTAINS %@"
            } else {
                predicateFormat = "ANY labels.longName CONTAINS[c] %@"
            }
            
            self.photos = self.photos?.filter(predicateFormat, filter)
        }
    }
    
    fileprivate func writeAsync(_ writeBlock: @escaping (Realm) -> Void) {
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async() {
            let realm = try! Realm()
            try! realm.write {writeBlock(realm)}
        }
    }
    
    fileprivate func initRealm() {
        let fileManager = FileManager.default
        if let appGroupURL: URL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.worksmartercomputing.photos") {
            let realmAppGroupURL = appGroupURL.appendingPathComponent("default.realm")

            Realm.Configuration.defaultConfiguration.fileURL = realmAppGroupURL
        }
        
        self.realm = try! Realm()
    }
    
    fileprivate func migrateRealmToAppGroup() {
        if let defaultRealmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let fileManager = FileManager.default
            if let appGroupURL: URL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.worksmartercomputing.photos") {
                let realmAppGroupURL = appGroupURL.appendingPathComponent("default.realm")
                if fileManager.fileExists(atPath: defaultRealmURL.path) && !fileManager.fileExists(atPath: realmAppGroupURL.path) {
                    do {
                        try fileManager.moveItem(atPath: defaultRealmURL.path, toPath: realmAppGroupURL.path)
                        print("Realm migration complete")
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
                Realm.Configuration.defaultConfiguration.fileURL = realmAppGroupURL
            }
        }
    }

}

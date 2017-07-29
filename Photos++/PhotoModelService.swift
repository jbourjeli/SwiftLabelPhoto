//
//  PhotoModelService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/13/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import UIKit

protocol PhotoModelService {
    func allPhotos() -> [Photo]
    
    func numberOfPhotos() -> Int
    func photoAtIndexPath(_ indexPath: IndexPath) -> Photo?
    func indexPathForPhoto(_ photo: Photo) -> IndexPath?
    
    func newPhotoFromImage(_ image: UIImage, refURL: URL, andLabels labels: Label...) -> Photo
    func photoFrom(image: UIImage, andLabels labels: Label...) -> Photo
    func addPhoto(_ photo: Photo)
    func add(photos: [Photo])
    func deletePhoto(_ photo: Photo) throws
    func unlink(photo: Photo)
    
    func photo(_ photo: Photo, addLabel label: Label)
    func photo(_ photo: Photo, removeLabel label: Label)

    func photo(_ photo: Photo, addCommentWithText text: String)
    func photo(_ photo: Photo, addComment comment: Comment)
    func photo(_ photo: Photo, removeComment comment: Comment)
    
    func setFilter(pattern: String?, caseSensitive: Bool)
}

extension PhotoModelService {
    func setFilter(pattern: String?) {
        self.setFilter(pattern: pattern, caseSensitive: false)
    }
}

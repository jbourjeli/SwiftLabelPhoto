//
//  Label.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/19/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation
import RealmSwift

public class Label: Object {
    dynamic var longName: String?
    
    private var photos: List<Photo> = List<Photo>()
    
    public convenience init(longName: String) {
        self.init()
        
        self.longName = longName
    }
    
    func numberOfLabeledPhotos() -> Int {
        return self.photos.count
    }
    
    func labeledPhotos() -> [Photo] {
        return Array(self.photos)
    }
    
    func labeledPhotoAtIndex(index: Int) -> Photo {
        return self.photos[index]
    }
    
    func appendLabeledPhoto(photo: Photo) {
        self.photos.append(photo)
    }
    
    func removeLabeledPhoto(photo: Photo) {
        if let i = self.photos.index(of: photo) {
            self.photos.remove(objectAtIndex: i)
        }
    }
}

//
//  Service.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/13/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

class Service {
    fileprivate let photoService: PhotosService
    fileprivate let labelService: LabelsService
    fileprivate let commentService: CommentModelService
    
    private init() {
        self.photoService = PhotosService()
        self.labelService = LabelsService()
        self.commentService = CommentsService()
    }
    
    static func labelModelService() -> LabelModelService {
        return one.labelService
    }
    
    static func photoModelService() -> PhotoModelService {
        return one.photoService
    }
    
    static func commentModelService() -> CommentModelService {
        return one.commentService
    }
    
    private static let one = Service()
}

//
//  CommentsService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

class CommentsService: BasicModelService<Comment>, CommentModelService {
    func numberOfComments() -> Int {
        return super.numberOfEntities()
    }
    
    func deleteComment(_ comment: Comment) {
        super.delete(comment)
    }
    
    func insertComment(_ comment: Comment) {
        super.save(comment)
    }
    
    func commentAtIndexPath(_ indexPath: IndexPath) -> Comment? {
        return super.entityAtIndexPath(indexPath)
    }
    
    func setCommentFilter(pattern: String?) {
        if let pat = pattern {
            super.applyFilter(predicate: NSPredicate(format: "text=%@", pat))
        } else {
            super.applyFilter(predicate: nil)
        }
    }
}

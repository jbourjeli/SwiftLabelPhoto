//
//  CommentModelService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

protocol CommentModelService {
    func numberOfComments() -> Int
    
    func deleteComment(_ comment: Comment)
    func insertComment(_ comment: Comment)
    
    func commentAtIndexPath(_ indexPath: IndexPath) -> Comment?
    
    func setCommentFilter(pattern: String?)
}

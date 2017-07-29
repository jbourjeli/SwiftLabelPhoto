//
//  Comment.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/26/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Realm
import RealmSwift

public class Comment: Object {
    public static func create(withText text: String, createdOn createdDate: Date = Date()) -> Comment {
        let comment = Comment()
        comment.text = text
        comment.createdDate = createdDate
        
        return comment
    }
    
    dynamic var text: String = ""
    dynamic var createdDate: Date = Date()
}

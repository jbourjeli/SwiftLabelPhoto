//
//  BasicModelService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

public class BasicModelService<T: Object> {
    
    let realm: Realm
    
    var predicate: NSPredicate?
    
    var entities: Results<T>
    
    public init() {
        self.realm = try! Realm()
        
        self.entities = self.realm.objects(T.self)
    }
    
    public func entityAtIndexPath(_ indexPath: IndexPath) -> T? {
        guard (indexPath as NSIndexPath).row < self.entities.count
            else { return nil }

        
        return self.entities[indexPath.row]
    }
    
    public func numberOfEntities() -> Int {
        return self.entities.count
    }
    
    public func delete(_ entity: T) {
        try! self.realm.write {
            self.realm.delete(entity)
        }
    }
    
    public func save(_ entity: T) {
        try! self.realm.write {
            self.realm.add(entity)
        }
    }
    
    public func applyFilter(predicate: NSPredicate?) {
        self.predicate = predicate
        if let predicate = self.predicate {
            self.entities = self.entities.filter(predicate)
        } else {
            self.entities = self.realm.objects(T.self)
        }
    }
}

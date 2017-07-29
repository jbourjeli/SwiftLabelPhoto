//
//  LabelsService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

class LabelsService: BasicModelService<Label>, LabelModelService {
    func numberOfLabels() -> Int {
        return super.numberOfEntities()
    }
    
    func insertLabel(_ label: Label) {
        super.save(label)
    }
    
    func deleteLabel(_ label: Label) {
        super.delete(label)
    }
    
    func labelAtIndexPath(_ indexPath: IndexPath) -> Label? {
        return super.entityAtIndexPath(indexPath)
    }
    
    func isLabelInUse(_ label: Label) -> Bool {
        return self.numberOfPhotosUsingLabel(label) > 0
    }
    
    func numberOfPhotosUsingLabel(_ label: Label) -> Int {
        return label.labeledPhotos().count
    }
    
    func setLabelFilter(pattern: String?) {        
        if let pattern = pattern, pattern.isNotBlank() {
            super.applyFilter(predicate: NSPredicate(format: "longName CONTAINS %@", pattern))
        } else {
            super.applyFilter(predicate: nil)
        }
    }
}

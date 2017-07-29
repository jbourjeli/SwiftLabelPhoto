//
//  LabelModelService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/13/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

protocol LabelModelService {
    func numberOfLabels() -> Int
    
    func deleteLabel(_ label: Label)
    func insertLabel(_ label: Label)
    
    func labelAtIndexPath(_ indexPath: IndexPath) -> Label?
    
    func isLabelInUse(_ label: Label) -> Bool
    func numberOfPhotosUsingLabel(_ label: Label) -> Int
    
    func setLabelFilter(pattern: String?)
}

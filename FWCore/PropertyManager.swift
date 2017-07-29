//
//  PropertyManager.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/27/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

public class PropertyManager {
    fileprivate let groupIdentifier = "group.com.worksmartercomputing.photos"
    
    public lazy var sharedDocumentURL: URL  = {
        return (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.groupIdentifier)?.appendingPathComponent("images"))!
    }()
    
    private init() {
    }
    
    public static let `default` = PropertyManager()
}

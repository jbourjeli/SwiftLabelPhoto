//
//  String+extension.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 9/21/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

extension String {
    public func isBlank() -> Bool {
        let whitespaceSet = CharacterSet.whitespacesAndNewlines
        let stringWithoutWhitespaces = self.components(separatedBy: whitespaceSet).joined()
    
        return stringWithoutWhitespaces == ""
    }
    
    public func isNotBlank() -> Bool {
        return !self.isBlank()
    }
}

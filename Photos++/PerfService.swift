//
//  PerfService.swift
//  Photos++
//
//  Created by Joseph Bourjeli on 10/6/16.
//  Copyright © 2016 WorkSmarterComputing. All rights reserved.
//

import Foundation

public class PerfService {
    public static func timeIt(_ function: () -> Void) -> TimeInterval {
        let startTime = Date()
        function()
        return Date().timeIntervalSince(startTime)
    }
}

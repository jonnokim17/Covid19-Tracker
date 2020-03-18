//
//  Extension+String.swift
//  Covid19 Tracker
//
//  Created by Jonathan Kim on 3/18/20.
//  Copyright © 2020 jonno. All rights reserved.
//

import Foundation

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

//
//  Argument.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Argument: LeafPattern {
    override internal var description: String {
        get {
            return "Argument(\(String(describing: name)), \(String(describing: value)))"
        }
    }
    
    override func singleMatch<T: Pattern>(_ left: [T]) -> SingleMatchResult {
        for i in 0..<left.count {
            if let pattern = left[i] as? Argument {
              return (i, Argument(self.name, value: (pattern ).value))
            }
        }
        return (0, nil)
    }
}

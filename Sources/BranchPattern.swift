//
//  BranchPattern.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/1/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class BranchPattern : Pattern {
    var children: [Pattern]
    override var description: String {
        get {
            return "BranchPattern(\(children))"
        }
    }

    convenience init(_ child: Pattern) {
        self.init([child])
    }

    init(_ children: [Pattern]) {
        self.children = children
    }
    
    override func fixIdentities(_ unq: [LeafPattern]? = nil) {
        let uniq: [LeafPattern] = unq ?? Array(Set(flat()))
        
        for i in 0..<children.count {
            let child = children[i]
            if let leafChild = child as? LeafPattern {
                assert(uniq.contains(leafChild))
                children[i] = uniq[uniq.firstIndex(of: leafChild)!]
            } else {
                child.fixIdentities(uniq)
            }
        }
    }
    
    override func flat<T: Pattern>(_: T.Type) -> [T] {
        if type(of: self) === T.self {
            return [self as! T]
        }
        var result = [T]()
        for child in children {
            result += child.flat(T.self)
        }
        return result
    }
}

func ==(lhs: BranchPattern, rhs: BranchPattern) -> Bool {
    return lhs.children == rhs.children
}

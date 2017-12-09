//
//  Option.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation

internal class Option: LeafPattern {
    internal var short: String?
    internal var long: String?
    internal var argCount: UInt
    override internal var name: String? {
        get {
            return self.long ?? self.short
        }
        set {
        }
    }
    override var description: String {
        get {
            var valueDescription : String = value?.description ?? "nil"
            if value is Bool, let val = value as? Bool
            {
                valueDescription = val ? "true" : "false"
            }
            return "Option(\(String(describing: short)), \(String(describing: long)), \(argCount), \(valueDescription))"
        }
    }
    
    convenience init(_ option: Option) {
        self.init(option.short, long: option.long, argCount: option.argCount, value: option.value)
        valueType = option.valueType
    }
    
    init(_ short: String? = nil, long: String? = nil, argCount: UInt = 0, value: AnyObject? = false as NSNumber) {
        assert(argCount <= 1)
        self.short = short
        self.long = long
        self.argCount = argCount

        super.init("", value: value)
        if argCount > 0 && value as? Bool == false {
            self.value = nil
        } else {
            self.value = value
        }
    }
    
    static func parse(_ optionDescription: String) -> Option {
        var short: String? = nil
        var long: String? = nil
        var argCount: UInt = 0
        var value: AnyObject? = kCFBooleanFalse
        var valueType: ValueType? = nil
        
        var (options, _, description) = optionDescription.strip().partition("  ")
        options = options.replacingOccurrences(of: ",", with: " ", options: [], range: nil)
        options = options.replacingOccurrences(of: "=", with: " ", options: [], range: nil)
        
        for s in options.components(separatedBy: " ").filter({!$0.isEmpty}) {
            if s.hasPrefix("--") {
                long = s
            } else if s.hasPrefix("-") {
                short = s
            } else if s.hasPrefix("<") && s.hasSuffix(">") {
                // Matched should be something like <id>. Check inside the brackets for a
                // value type specifier.
                let (_, _, type) = String(s.dropFirst().dropLast()).partition(":")
                switch type {
                    case "int", "Int", "integer", "Integer":
                        valueType = .int
                    case "string", "String":
                        valueType = .string
                    case "bool", "Bool", "boolean", "Boolean":
                        valueType = .bool
                    default:
                        break
                }
                argCount = 1

            } else {
                valueType = .string
                argCount = 1
            }
        }
        
        if argCount == 1 {
            let matched = description.findAll("\\[default: (.*)\\]", flags: .caseInsensitive)
            if matched.count > 0
            {
                switch valueType {
                    case .int?:
                        value = NSNumber(value: (matched[0] as NSString).integerValue)
                    case .bool?:
                        value = NSNumber(value: (matched[0] as NSString).boolValue)
                    case .string?:
                        value = matched[0] as NSString
                    default:
                        value =  matched[0] as AnyObject
                    }
            }
            else
            {
                value = nil
            }
        }

        let option = Option(short, long: long, argCount: argCount, value: value)
        if let valueType = valueType {
            option.valueType = valueType
        }
        return option
    }
    
    override func singleMatch<T: LeafPattern>(_ left: [T]) -> SingleMatchResult {
        for i in 0..<left.count {
            let pattern = left[i]
            if pattern.name == name {
                return (i, pattern)
            }
        }
        return (0, nil)
    }
}

func ==(lhs: Option, rhs: Option) -> Bool {
    let valEqual = lhs as LeafPattern == rhs as LeafPattern
    return lhs.short == rhs.short
        && lhs.long == lhs.long
        && lhs.argCount == rhs.argCount
        && valEqual
}

//
//  DocoptTestCaseParser.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 2/28/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import Foundation
@testable import Docopt

public struct DocoptTestCaseParser {
    public var testCases: [DocoptTestCase]!
    
    public init(_ stringOfTestCases: String) {
        testCases = parse(stringOfTestCases)
    }
    
    private func parse(_ stringOfTestCases: String) -> [DocoptTestCase] {
        let fixturesWithCommentsStripped: String = removeComments(stringOfTestCases)
        let fixtures: [String] = parseFixtures(fixturesWithCommentsStripped)
        let testCases: [DocoptTestCase] = parseFixturesArray(fixtures)
        
        return testCases
    }
    
    private func removeComments(_ string: String) -> String {
        let removeCommentsRegEx = try! RegularExpression(pattern: "(?m)#.*$", options: [])
        let fullRange: NSRange = NSMakeRange(0, string.characters.count)
        return removeCommentsRegEx.stringByReplacingMatches(in: string, options: [], range: fullRange, withTemplate: "")
    }
    
    private func parseFixtures(_ fixturesString: String) -> [String] {
        let fixtures: [String] = fixturesString.split("r\"\"\"")
        return fixtures.filter { !$0.strip().isEmpty }
    }
    
    private func parseFixturesArray(_ fixtureStrings: [String]) -> [DocoptTestCase] {
        var allTestCases = [DocoptTestCase]()
        let testBaseName: String = "Test"
        var testIndex: Int = 1
        for fixtureString in fixtureStrings {
            let newTestCases: [DocoptTestCase] = testCasesFromFixtureString(fixtureString)
            for testCase: DocoptTestCase in newTestCases {
                testCase.name = testBaseName + String(testIndex)
                testIndex += 1
            }
            
            allTestCases += newTestCases
        }
        
        return allTestCases
    }
    
    private func testCasesFromFixtureString(_ fixtureString: String) -> [DocoptTestCase] {
        var testCases = [DocoptTestCase]()
        let fixtureComponents: [String] = fixtureString.split("\"\"\"")
        assert(fixtureComponents.count == 2, "Could not split fixture: \(fixtureString) into components")
        let usageDoc: String = fixtureComponents[0]
        let testInvocationString: String = fixtureComponents[1]
        
        let testInvocations: [String] = parseTestInvocations(testInvocationString)
        for testInvocation in testInvocations {
            let testCase: DocoptTestCase? = parseTestCase(testInvocation)
            if let testCase = testCase {
                testCase.usage = usageDoc
                testCases.append(testCase)
            }
        }
        
        return testCases
    }
    
    private func parseTestCase(_ invocationString: String) -> DocoptTestCase? {
        let trimmedTestInvocation: String = invocationString.strip()
        var testInvocationComponents: [String] = trimmedTestInvocation.split("\n")
        assert(testInvocationComponents.count >= 2, "Could not split test case: \(trimmedTestInvocation) into components")
        
        let input: String = testInvocationComponents.remove(at: 0) // first line
        let expectedOutput: String = testInvocationComponents.joined(separator: "\n") // all remaining lines
        
        var inputComponents: [String] = input.split(" ")
        let programName: String = inputComponents.remove(at: 0) // first part
        
        var error : NSError?
        let jsonData: Data? = expectedOutput.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if jsonData == nil {
            NSLog("Error parsing \(expectedOutput) to JSON: \(error)")
            return nil
        }
        let expectedOutputJSON: AnyObject?
        do {
          expectedOutputJSON = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .allowFragments)
        } catch let error1 as NSError {
            error = error1
            expectedOutputJSON = nil
        }
        if (expectedOutputJSON == nil) {
            NSLog("Error parsing \(expectedOutput) to JSON: \(error)")
            return nil
        }
        
        return DocoptTestCase(programName, arguments: inputComponents, expectedOutput: expectedOutputJSON!)
    }
    
    private func parseTestInvocations(_ stringOfTestInvocations: String) -> [String] {
        let testInvocations: [String] = stringOfTestInvocations.split("$ ")
        return testInvocations.filter { !$0.strip().isEmpty }
    }
}

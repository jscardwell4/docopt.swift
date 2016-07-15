//
//  DocoptTestCasesTests.swift
//  docopt
//
//  Created by Pavel S. Mazurin on 3/4/15.
//  Copyright (c) 2015 kovpas. All rights reserved.
//

import XCTest
@testable import Docopt

class DocoptTestCasesTests: XCTestCase {
    override func setUp() {
        DocoptError.test = true
    }

    func testTestCasesFileExists() {
        let fileManager: FileManager = FileManager.default
        let filePath: String? = fixturesFilePath()
        XCTAssertNotNil(filePath, "Fixtures file testcases.docopt does not exist in testing bundle")
        if let filePath = filePath {
            let exists: Bool = fileManager.fileExists(atPath: filePath)
            XCTAssertTrue(exists, "Fixtures file testcases.docopt does not exist in testing bundle")
        }
    }
    
    func testFixturesFileCanBeOpened() {
        XCTAssertNotNil(fixturesFileContents(), "Could not read fixtures file")
    }
    
    func testTestCases() {
        let rawTestCases = fixturesFileContents()
        let parser = DocoptTestCaseParser(rawTestCases)
        
        for testCase in parser.testCases {
            let expectedOutput: AnyObject = testCase.expectedOutput
            var result: AnyObject = "user-error"
            let capture = NMBExceptionCapture(handler: nil, finally: nil)
            capture?.try {
                result = Docopt(testCase.usage, argv: testCase.arguments).result
            }

            if let expectedDictionary = expectedOutput as? NSDictionary,
               let resultDictionary = result as? NSDictionary {
                XCTAssertTrue(resultDictionary == expectedDictionary,
                    "Test \(testCase.name) failed. Expected:\n\(expectedDictionary)\n\n, got: \(resultDictionary)\n\n")
            } else if let expectedString = expectedOutput as? String,
                      let resultString = result as? String {
                XCTAssertTrue(resultString == expectedString,
                    "Test \(testCase.name) failed. Expected:\n\(expectedString)\n\n, got: \(resultString)\n\n")
            } else {
                XCTFail("Test \(testCase.name) failed. Expected:\n\(expectedOutput)\n\n, got: \(result)\n\n\(testCase.usage)\n\(testCase.arguments)\n\n")
            }
        }
    }
    
    private func fixturesFilePath() -> String? {
        let testBundle: Bundle = Bundle(for: self.dynamicType)
        return testBundle.pathForResource("testcases", ofType: "docopt")
    }
    
    private func fixturesFileContents() -> String {
        if let filePath = self.fixturesFilePath() {
            let fileContents = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
            return fileContents
        }
        return ""
    }
}

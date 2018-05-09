//
//  FastXMLPerformanceTest.swift
//  Copyright © 2018 Morgan Fitussi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import FastXML

class FastXMLPerformanceTest: XCTestCase {
    
    func testPerformanceOfDeepSchema() {
        self.measure {
            var deepXML = ""
            for index in 1...100000 {
                deepXML += "<tag\(index) prop1=\"foo\" prop2=\"bar\">"
            }
            deepXML += "value"
            for index in 1...100000 {
                deepXML += "</tag\(index)>"
            }
            
            let expectation = XCTestExpectation(description: "XML should be parsed")
            FastXML(xmldata: deepXML.data(using: .utf8)!) { (dict, error) in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }
    
    func testPerformanceOfDocument() {
        self.measure {
            var largeXML = "<root>"
            for index in 1...100000 {
                largeXML += "<tag\(index) prop1=\"foo\" prop2=\"bar\">Tag\(index)</tag\(index)>"
            }
            largeXML += "</root>"
            
            let expectation = XCTestExpectation(description: "XML should be parsed")
            FastXML(xmldata: largeXML.data(using: .utf8)!) { (dict, error) in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }

    func testPerformanceOfLargeDocumentWithUniqTagName() {
        self.measure {
            var largeXML = "<root>"
            for index in 1...10000 {
                largeXML += "<tag prop1=\"foo\" prop2=\"bar\">Tag\(index)</tag>"
            }
            largeXML += "</root>"
            
            let expectation = XCTestExpectation(description: "XML should be parsed")
            FastXML(xmldata: largeXML.data(using: .utf8)!) { (dict, error) in
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 2.0)
        }
    }


}

//
//  SwiftXMLTests.swift
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
@testable import SwiftXML

class SwiftXMLTests: XCTestCase {
    
    private typealias Node = [String: Any]
    
    private var error: Error?
    private var dataParsed: Node?
    
    private var xml: String = ""
    private let tag = "tag"
    private let otherTag = "other-tag"
    private let value = "hello world"
    
    private var expectation = XCTestExpectation(description: "XML should be parsed")
    
    override func setUp() {
        super.setUp()
        dataParsed = nil
        xml = ""
        error = nil
        expectation = XCTestExpectation(description: "XML should be parsed")
    }
    
    private func parse(xml: String) {
        let parser = SwiftXML(xmldata: xml.data(using: .utf8)!)
        parser.parse { (dict, error) in
            self.dataParsed = dict
            self.error = error
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testParseInvalidXML() {
        // Given
        xml = "invalid xml"
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? SwiftXML.Error, SwiftXML.Error.invalidXML)
        XCTAssertNil(dataParsed)
    }
    
    func testCannotParseEmptyData() {
        // Given
        let xml = ""
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? SwiftXML.Error, SwiftXML.Error.invalidXML)
        XCTAssertNil(dataParsed)
    }
    
    func testParseBasicXMLWithoutElement() {
        // Given
        let xml = """
        <\(tag)></\(tag)>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        XCTAssertNil(dataParsed![tag])
        XCTAssertFalse(dataParsed!.keys.contains(tag))
    }
    
    func testParseXMLWithElement() {
        // Given
        let xml = """
        <\(tag)>\(value)</\(tag)>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        XCTAssertTrue(dataParsed!.keys.contains(tag))
        XCTAssertEqual(dataParsed![tag] as? String, value)
    }
    
    func testAttributesCanBeParsed() {
        // Given
        let xml = """
        <\(tag) attr="my_attr">\(value)</\(tag)>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        let tagValue = (dataParsed![tag] as! [String: String])["text"] as? String
        let propertyValue = (dataParsed![tag] as! [String: String])["$attr"] as? String
        
        XCTAssertNotNil(dataParsed)
        XCTAssertTrue(dataParsed!.keys.contains(tag))
        XCTAssertEqual(tagValue, value)
        XCTAssertEqual(propertyValue, "my_attr")
    }
    
    func testParseXMLWithStackOfTags() {
        // Given
        let xml = """
        <ent1>
            <ent2>
                <ent21>Hello ent21</ent21>
                <ent22>Hello ent22</ent22>
            </ent2>
            <ent3>Hello ent3</ent3>
        </ent1>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        let ent1 = dataParsed!["ent1"] as? Node
        XCTAssertNotNil(ent1)
        let ent2 = ent1!["ent2"] as? Node
        XCTAssertNotNil(ent2)
        let ent21 = ent2!["ent21"] as? String
        XCTAssertEqual(ent21, "Hello ent21")
        let ent22 = ent2!["ent22"] as? String
        XCTAssertEqual(ent22, "Hello ent22")
        let ent3 = ent1!["ent3"] as? String
        XCTAssertEqual(ent3, "Hello ent3")
    }
    
    func testParseXMLWithStackOfTagsAndAttributes() {
        // Given
        let xml = """
        <ent1 prop="prop1">
            <ent2 prop="prop2">
                <ent21 prop="prop21">Hello ent21</ent21>
                <ent22 prop="prop22">Hello ent22</ent22>
            </ent2>
            <ent3 prop="prop3">Hello ent3</ent3>
        </ent1>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        let ent1 = dataParsed!["ent1"] as? Node
        XCTAssertNotNil(ent1)
        XCTAssertEqual(ent1!["$prop"] as? String, "prop1")
        let ent2 = ent1!["ent2"] as? Node
        XCTAssertNotNil(ent2)
        XCTAssertEqual(ent2!["$prop"] as? String, "prop2")
        let ent21 = ent2!["ent21"] as? Node
        XCTAssertEqual(ent21!["$prop"] as? String, "prop21")
        XCTAssertEqual(ent21!["text"] as? String, "Hello ent21")
        let ent22 = ent2!["ent22"] as? Node
        XCTAssertEqual(ent22!["$prop"] as? String, "prop22")
        XCTAssertEqual(ent22!["text"] as? String, "Hello ent22")
        let ent3 = ent1!["ent3"] as? Node
        XCTAssertEqual(ent3!["$prop"] as? String, "prop3")
        XCTAssertEqual(ent3!["text"] as? String, "Hello ent3")
    }
    
    func testParseArrayOfTags() {
        // Given
        let xml = """
        <ent1>
            <ent2>
                <ent21>Hello ent21 first</ent21>
                <ent21>Hello ent21 second</ent21>
            </ent2>
            <ent2>
                <ent22>Hello ent22 first</ent22>
                <ent22>Hello ent22 second</ent22>
            </ent2>
        </ent1>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        let ent1 = dataParsed!["ent1"] as? Node
        XCTAssertNotNil(ent1)
        let ent2 = ent1!["ent2"] as? [Node]
        XCTAssertNotNil(ent2)
        XCTAssertEqual(ent2?.count, 2)
    }
    
    
    func testParsingInternationalXML() {
        // Given
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <俄语 լեզու="ռուսերեն">данные</俄语>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        let tagValue = (dataParsed!["俄语"] as! [String: String])["text"]
        let propertyValue = (dataParsed!["俄语"] as! [String: String])["$լեզու"] as? String
        
        XCTAssertNotNil(dataParsed)
        XCTAssertTrue(dataParsed!.keys.contains("俄语"))
        XCTAssertEqual(tagValue, "данные")
        XCTAssertEqual(propertyValue, "ռուսերեն")
    }
    
    func testPerformance() {
        self.measure {
            var xmlString = ""
            for index in 1...100000 {
                xmlString += "<tag\(index) prop1=\"foo\" prop2=\"bar\">"
            }
            xmlString += "value"
            for index in 1...100000 {
                xmlString += "</tag\(index)>"
            }
            parse(xml: xmlString)
        }
    }
}

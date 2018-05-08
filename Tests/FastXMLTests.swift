//
//  FastXMLTests.swift
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

class FastXMLTests: XCTestCase {
    
    private typealias Node = [String: Any]
    
    private var error: Error?
    private var dataParsed: FastXML.Tag?
    
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
        let parser = FastXML(xmldata: xml.data(using: .utf8)!)
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
        XCTAssertEqual(error as? FastXML.Error, FastXML.Error.invalidXML)
        XCTAssertNil(dataParsed)
    }
    
    func testCannotParseEmptyData() {
        // Given
        let xml = ""
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? FastXML.Error, FastXML.Error.invalidXML)
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
        XCTAssertNotNil(dataParsed![tag].value, "Conforms to standard XML 1.1 - cf. 44")
        XCTAssertTrue(dataParsed!.tags.contains(tag))
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
        XCTAssertTrue(dataParsed!.tags.contains(tag))
        XCTAssertEqual(dataParsed![tag].value, value)
    }
    
    func testAttributesCanBeParsed() {
        // Given
        let xml = """
        <\(tag) attr="my_attr">\(value)</\(tag)>
        """
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        XCTAssertTrue(dataParsed!.tags.contains(tag))
        XCTAssertEqual(dataParsed![tag].value, value)
        XCTAssertEqual(dataParsed![tag]["$attr"].value, "my_attr")
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
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent21"].value, "Hello ent21")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent22"].value, "Hello ent22")
        XCTAssertEqual(dataParsed!["ent1"]["ent3"].value, "Hello ent3")
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
        XCTAssertEqual(dataParsed!["ent1"]["$prop"].value, "prop1")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["$prop"].value, "prop2")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent21"]["$prop"].value, "prop21")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent21"].value, "Hello ent21")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent22"]["$prop"].value, "prop22")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"]["ent22"].value, "Hello ent22")
        XCTAssertEqual(dataParsed!["ent1"]["ent3"]["$prop"].value, "prop3")
        XCTAssertEqual(dataParsed!["ent1"]["ent3"].value, "Hello ent3")
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
        XCTAssertEqual(dataParsed!["ent1"]["ent2"].count, 2)
        XCTAssertEqual(dataParsed!["ent1"]["ent2"][0]["ent21"][0].value, "Hello ent21 first")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"][0]["ent21"][1].value, "Hello ent21 second")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"][1]["ent22"][0].value, "Hello ent22 first")
        XCTAssertEqual(dataParsed!["ent1"]["ent2"][1]["ent22"][1].value, "Hello ent22 second")
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
        XCTAssertNotNil(dataParsed)
        XCTAssertTrue(dataParsed!.tags.contains("俄语"))
        XCTAssertEqual(dataParsed!["俄语"].value, "данные")
        XCTAssertEqual(dataParsed!["俄语"]["$լեզու"].value, "ռուսերեն")
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

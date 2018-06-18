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
        FastXML(xmldata: xml.data(using: .utf8)!) { (dict, error) in
            self.dataParsed = dict
            self.error = error
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testInvalidXML() {
        // Given
        xml = "invalid xml"
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? FastXML.Error, FastXML.Error.invalidXML)
        XCTAssertNil(dataParsed)
    }
    
    func testEmptyData() {
        // Given
        let xml = ""
        
        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(error)
        XCTAssertEqual(error as? FastXML.Error, FastXML.Error.invalidXML)
        XCTAssertNil(dataParsed)
    }
    
    func testBasicXMLWithoutElement() {
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
    
    func testXMLWithElement() {
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
    
    func testAttributeOnSimpleXML() {
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
    
    func testXMLWithStackOfTags() {
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

    func testXMLWithStackOfTagsAndAttributes() {
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

    func testArrayOfTags() {
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

    func testInternationalXML() {
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
    
    func testNamespaceOnRoot() {
        // Given
        let xml = """
            <root xmlns:h="http://www.w3.org/TR/html4/" xmlns:f="https://www.w3schools.com/furniture">
                <h:table>
                  <h:tr>
                    <h:td>Apples</h:td>
                    <h:td>Bananas</h:td>
                  </h:tr>
                </h:table>

                <h:table>
                  <h:tr>
                    <h:td>Apricot</h:td>
                    <h:td>Blueberry</h:td>
                    <f:td>foo</f:td>
                    <f:name>Fruits</f:name>
                  </h:tr>
                </h:table>

                <f:table>
                  <f:name>African Coffee Table</f:name>
                  <f:width>80</f:width>
                  <f:length>120</f:length>
                </f:table>
        </root>
        """

        // When
        parse(xml: xml)
        
        // Then
        XCTAssertNotNil(dataParsed)
        XCTAssertEqual(dataParsed?["root"].namespace["h"]?.URI, "http://www.w3.org/TR/html4/")
        dataParsed?["root"]["table"][0]["tr"]
        XCTAssertEqual(dataParsed?["root"]["table"][0]["tr"]["td"].first?.value, "Apples")
        XCTAssertEqual(dataParsed?["root"]["table"][0]["tr"]["td"].last?.value, "Bananas")
        XCTAssertEqual(dataParsed?["root"]["table"][1]["tr"]["td"][0].value, "Apricot")
//        XCTAssertEqual(dataParsed?["root"]["table"][1]["tr"]["td"][1].value, "Blueberry")
//        XCTAssertEqual(dataParsed?["root"]["table"][1]["tr"]["td"][2].value, dataParsed?["root"]["table"][1]["tr"]["f:td"].value)
//        XCTAssertEqual(dataParsed?["root"]["table"][1]["tr"]["f:td"].value, "foo")
//        XCTAssertEqual(dataParsed?["root"]["table"][1]["tr"]["name"].value, "Blueberry")
//
//        XCTAssertEqual(dataParsed?["root"].namespace["f"]?.URI, "https://www.w3schools.com/furniture")
//        XCTAssertEqual(dataParsed?["root"]["table"]["name"].value, "African Coffee Table")
//        XCTAssertEqual(dataParsed?["root"]["table"]["width"].value, "80")
//        XCTAssertEqual(dataParsed?["root"]["table"]["length"].value, "120")
    }
 

}

//
//  SwiftXML.swift
//
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

import Foundation

/// Fast XML parsing library
@objcMembers
class SwiftXML: NSObject {
    
    enum Error: Swift.Error {
        case invalidXML
    }
    
    typealias Handler = ([String: Any]?, Error?) -> Void
    private var handler: Handler?

    private let data: Data

    private typealias Element = (key: String, value: Any)
    private typealias Node = (element: Element, children: [Element]?)

    private var nodes: [String: Any] = [:]
    private var nodeValue: String?

    private var root: [Node] = []
    
    // MARK: Lifecycle
    
    /// Creates an instance with the specified `xmldata`
    ///
    /// - parameter xmldata: The XML data
    init(xmldata data: Data) {
        self.data = data
        super.init()
    }
    
    /// Parses the initiated XML data and calls the completion handler on finish
    ///
    /// - parameter handler: A closure to be executed once the XML has parsed or returns an error.
    ///
    func parse(then handler: @escaping Handler) {
        self.handler = handler
        
        let parser = XMLParser(data: self.data)
        parser.delegate = self
        
        guard parser.parse() else {
            handler(nil, SwiftXML.Error.invalidXML)
            return
        }
    }
    
}

extension SwiftXML: XMLParserDelegate {
    
    /// Recursively reduce the array of Element to Dictionary
    ///
    /// - parameter elements: A array of Element
    ///
    private func reduce(_ elements: [Element]) -> [String: Any] {
        return elements.reduce(into: [String: Any]()) {
            if let elements = $1.value as? [Element] {
                $0[$1.key] = reduce(elements)
            }
            else {
                $0[$1.key] = $1.value
            }
        }
    }
    
    
    // MARK: XMLParserDelegate
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // documents with a stack of tags
        if let rootNode = root.first, let elements = rootNode.children {
            handler?(reduce(elements), nil)
        }
        else {
            // simple XML data with uniq tag
            if let rootNode = root.first {
                handler?([rootNode.element.key: rootNode.element.value], nil)
            }
            // Invalid XML - plain text
            else {
                handler?([:], nil)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // Appends a new element to the stack
        root.append((element: (key: elementName, value: attributeDict), children: []))
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var node = root.last else { return }
        
        // Is it element with children?
        if let children = node.children, children.count > 0 {
            // Passes the children to value
            node.element.value = node.children
        }
        else {
            // Does element contains properties?
            if var element = node.element.value as? [String: Any], element.count > 0 {
                // Creates a new property for text value
                element["$text"] = nodeValue
                node.element.value = element
            }
            else {
                node.element.value = nodeValue
            }
        }

        // Removes the last element on the stack
        if root.count > 1 {
            _ = root.popLast()
        }

        // Appends the current element to his parent's children
        root[root.count - 1].children?.append(node.element)

        // deinit nodeValue
        nodeValue = nil
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        nodeValue = (nodeValue ?? "") + trimmedString
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        handler?(nil, parseError)
    }
}

//
//  FastXML.swift
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
class FastXML: NSObject {
    
    enum Error: Swift.Error {
        case invalidXML
    }
    
    typealias Handler = ([String : Any]?, Error?) -> Void
    private var handler: Handler?

    private let data: Data

    private typealias Element = (key: String, value: Any?, attributes: [String : String])
    private typealias Node = (element: Element, children: [Element]?)

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
            handler(nil, FastXML.Error.invalidXML)
            return
        }
    }
    
}

// MARK: XMLParserDelegate
extension FastXML: XMLParserDelegate {
    
    /// Recursively reduce the array of Element to Dictionary
    ///
    /// - parameter elements: A array of Element
    ///
    private func reduce(_ elements: [Element]?) -> [String: Any] {
        guard let elements = elements else { return [:] }
        return elements.reduce(into: [String : Any]()) {
            // this element contains tags
            if let elements = $1.value as? [Element] {
                // and attributes
                if $1.attributes.count > 0 {
                    // so transforms its attributes by adding `$` as prefix
                    let attributes = Dictionary(uniqueKeysWithValues: $1.attributes.map { ("$\($0.key)", $0.value) })
                    // and merges children's tags with attributes
                    $0[$1.key] = attributes.reduce(reduce(elements)) { (result, pair) in
                        // without this line we could not modify the dictionary
                        var result = result
                        result[pair.0] = pair.1
                        return result
                    }
                }
                else {
                    // if an element with the same key exists
                    if let existingElement = $0[$1.key] {
                        // if it's already an array
                        if var existingElement = existingElement as? [[String : Any]] {
                            // so we'll appends it
                            existingElement.append(reduce(elements))
                            $0[$1.key] = existingElement
                        }
                        else {
                            // otherwise creates an array, appends the previous element
                            // and the current element into it
                            var arrayOfElements: [[String : Any]] = []
                            arrayOfElements.append(existingElement as! [String : Any])
                            arrayOfElements.append(reduce(elements))
                            $0[$1.key] = arrayOfElements
                        }
                    }
                    else {
                        // new element for a new key
                        $0[$1.key] = reduce(elements)
                    }
                }
            }
            // is the tag's value
            else {
                // with attributes
                if $1.attributes.count > 0 {
                    // so transforms its attributes by adding `$` as prefix
                    var attributes = Dictionary(uniqueKeysWithValues: $1.attributes.map { ("$\($0.key)", $0.value) })
                    // and appends a `text` attribute with its value
                    attributes["text"] = $1.value as? String
                    $0[$1.key] = attributes
                }
                else {
                    // new element for a new key
                    $0[$1.key] = $1.value
                }
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        // documents with a stack of tags
        handler?(reduce(root.first?.children), nil)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // Appends a new element to the stack
        root.append((element: (key: elementName, value: nil, attributes: attributeDict), children: []))
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var node = root.last else { return }
        
        // Is it element with children?
        if let children = node.children, children.count > 0 {
            // Passes the children to value
            node.element.value = node.children
        }
        else {
            node.element.value = nodeValue
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
    
}

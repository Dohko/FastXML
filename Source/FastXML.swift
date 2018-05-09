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
    
    typealias Handler = (Tag?, Error?) -> Void
    private var handler: Handler?

    private let data: Data

    internal typealias Element = (key: String, value: Any?, attributes: [String : String])
    private typealias Node = (element: Element, children: [Element]?)

    private var nodeValue: String?

    private var root: [Node] = []
    private var reduced: [String : Any] = [:]
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
    
    func parserDidEndDocument(_ parser: XMLParser) {
        let children = root.first?.children ?? []
        handler?(Tag(children.toDictionary()), nil)
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


fileprivate extension Sequence where Iterator.Element == FastXML.Element {
    /// Recursively reduce the array of Element to Dictionary
    func toDictionary() -> [String: Any] {
        return reduce(into: [String : Any]()) {
            func addElement(_ newElement: () -> Any, forKey key: String, into dict: inout [String : Any]) {
                // if an element exists with the same key
                if let element = dict[key] {
                    // creates an array, appends the previous element
                    // and the current element into it
                    // Finally, compact it
                    var elements: [Any] = []
                    elements.append(element)
                    elements.append(newElement())
                    dict[key] = elements.compactMap { $0 }
                }
                else {
                    // new element for a new key
                    dict[key] = newElement()
                }
            }
            
            let elements = $1.value as? [Element]
            // element containing attributes
            if $1.attributes.count > 0 {
                // transforms its attributes by adding `$` as prefix
                var attributes = Dictionary(uniqueKeysWithValues: $1.attributes.map { ("$\($0.key)", $0.value) })
                // Tag with value
                if let text = $1.value as? String {
                    attributes["@text"] = text
                }
                else { // Tag containing elements
                    // merges children's tags with attributes
                    $0[$1.key] = attributes.reduce(elements?.toDictionary() ?? [:]) { (result, pair) in
                        // without this line we could not modify the dictionary
                        var result = result!
                        result[pair.0] = pair.1
                        return result
                    }
                }
                addElement({ attributes }, forKey: $1.key, into: &$0)
            }
            else {
                // if the tag contains elements, reduces it recursely
                // or sets its value
                // Conforms to XML standard 1.1
                // if value is nil, set a string empty value
                let newElement = elements?.toDictionary() ?? ($1.value ?? "")
                addElement({ newElement }, forKey: $1.key, into: &$0)
            }
        }
    }
}

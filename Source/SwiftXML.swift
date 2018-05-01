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
    private var nodeValue: String?
    private var currentNode: [String: Any] = [:]
    

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


// MARK: XMLParserDelegate
extension SwiftXML: XMLParserDelegate {
    
    func parserDidEndDocument(_ parser: XMLParser) {
        handler?(currentNode, nil)
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        var dict: [String: Any] = [:]
        dict["$parent"] = currentNode
        attributeDict.forEach { dict.updateValue($1, forKey: $0) }
        currentNode[elementName] = dict
        currentNode = currentNode[elementName] as! [String : Any]
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        func createNewElement(named: String, element: inout [String: Any], value: Any) -> Any {
            if let existingElement = element[named] {
                if var existingElement = existingElement as? [Any] {
                    existingElement.append(value)
                    return existingElement
                }
                else {
                    var arrayOfElements: [Any] = []
                    arrayOfElements.append(element[named]!)
                    arrayOfElements.append(value)
                    return arrayOfElements
                }
            }
            else {
                return value
            }
        }

        if let nodeValue = nodeValue, nodeValue.count > 0 {
            if var parent = currentNode["$parent"] as? [String : Any] {
                var newElementValue: Any
                if currentNode.keys.count > 1 { // currentNode includes `_parent` attribute
                    currentNode["$parent"] = nil
                    currentNode["$text"] = nodeValue
                    newElementValue = currentNode
                }
                else {
                    newElementValue = nodeValue
                }
                parent[elementName] = createNewElement(named: elementName, element: &parent, value: newElementValue)
                currentNode = parent
            }
            else if var node = currentNode[elementName] as? [String : Any] {
                node["$text"] = nodeValue
                currentNode[elementName] = node
            }
        }
        else {
            var parent = currentNode["$parent"] as! [String : Any]
            currentNode["$parent"] = nil
            parent[elementName] = createNewElement(named: elementName, element: &parent, value: currentNode)
            currentNode = parent
        }

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

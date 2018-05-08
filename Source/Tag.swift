//
//  Tag.swift
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
//

extension FastXML {
    
    public struct Tag {
        
        private let elements: [[String : Any]]?
        private let texts: [String]?
        
        /// Tag or attribute value
        var value: String? {
            guard let elements = elements,
                let elm = elements.first,
                let value = elm["@text"] as? String,
                elements.count == 1 else { return texts?.first ?? nil }
            return value
        }
        
        /// List of tags
        var tags: [String] {
            guard let elements = elements?
                .map({ return $0.keys })
                .flatMap({ $0 }) else { return [] }
            return Array(Set(elements))
        }
        
        /// List of attributes
        var attributes: [String] {
            guard let elements = elements, elements.count == 1 else { return [] }
            return elements.first!.keys.filter { $0.hasPrefix("$") }
        }
        
        /// First tag of the list
        var first: Tag? {
            if let element = elements?.first {
                return Tag(element)
            }
            else if let text = texts?.first {
                return Tag([text])
            }
            else {
                return nil
            }
        }
        
        /// last tag of the list
        var last: Tag? {
            if let element = elements?.last {
                return Tag(element)
            }
            else if let text = texts?.last {
                return Tag([text])
            }
            else {
                return nil
            }
        }
        
        /// number of tags in the list
        var count: Int {
            if let element = elements {
                return element.count
            }
            else if let texts = texts {
                return texts.count
            }
            else {
                return 1
            }
        }
        
        /// Creates a `Tag` instance using a single element.
        ///
        /// - parameter element: The dictionary to be used
        ///
        /// - returns: The new `Tag` instance.
        internal init(_ element: [String : Any]) {
            self.init([element])
        }
        
        /// Creates a `Tag` instance using an array of elements.
        ///
        /// - parameter elements: The array of element to be used
        ///
        /// - returns: The new `Tag` instance.
        internal init(_ elements: [[String : Any]]) {
            self.elements = elements
            self.texts = nil
        }
        
        /// Creates a `Tag` instance using an array of texts.
        ///
        /// - parameter texts: The array of texts to be used
        ///
        /// - returns: The new `Tag` instance.
        internal init(_ texts: [String]) {
            self.elements = nil
            self.texts = texts
        }
        
        subscript(key: String) -> Tag {
            get {
                guard let elements = elements, let element = elements.first else { return Tag([:]) }
                switch element[key] {
                case let elements as [[String : Any]]:
                    return Tag(elements)
                case let element as [String : Any]:
                    return Tag(element)
                case let texts as [String]:
                    return Tag(texts)
                case let text as String:
                    return Tag([text])
                default:
                    return Tag([:])
                }
            }
        }
        
        subscript(index: Int) -> Tag {
            get {
                if let elements = elements, index < elements.count {
                    return Tag(elements[index])
                }
                else if let texts = texts, index < texts.count {
                    return Tag([texts[index]])
                }
                else {
                    return Tag([:])
                }
            }
        }
    }
}

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
        
        private var elements: [Any] = []
        private var texts: [String]?
        
        /// Tag or attribute value
        var value: String? {
            guard let elements = elements.first as? [String : Any] else { return self.elements.first as? String }
            return elements["@text"] as? String
        }
        
        /// List of tags
        var tags: [String] {
            return keys.filter{ $0.hasPrefix("$") == false }
        }
        
        /// List of attributes
        var attributes: [String] {
            return keys.filter{ $0.hasPrefix("$") }
        }
        
        /// List of attributes and tags
        var keys: [String] {
            guard let elements = elements as? [[String : Any]], elements.count >= 1 else { return [] }
            return Array(Set(elements.map { $0.keys }.flatMap { $0 }.compactMap { $0 }))
        }
        
        /// First tag of the list
        var first: Tag? {
            guard let element = elements.first else { return nil }
            return Tag([element], namespaces: namespaces)
        }
        
        /// last tag of the list
        var last: Tag? {
            guard let element = elements.last else { return nil }
            return Tag([element], namespaces: namespaces)
        }
        
        /// number of tags in the list
        var count: Int {
            return elements.count
        }
        
        private(set) var URI: String?
        
        /// namespace for the current tag
        var namespace: [String : FastXML.Namespace] {
            let namespaces = attributes.namespaces
            return namespaces.reduce(into: [String : FastXML.Namespace]()) {
                if let elements = elements.first as? [String : Any] {
                    $0[$1.namespace] = Namespace(prefix: $1.namespace, URI: elements[$1] as! String)
                }
            }
        }
        
        private var previousNamespaces: [String] = []
        var namespaces: [String] {
            return previousNamespaces + attributes.namespaces.compactMap{ $0.namespace }
        }
        
        
        /// Creates a `Tag` instance using an array of elements.
        ///
        /// - parameter elements: The array of element to be used
        /// - parameter namespaces: Previous namespaces
        ///
        /// - returns: The new `Tag` instance.
        internal init(_ elements: [Any], namespaces: [String]) {
            self.elements = elements
            self.previousNamespaces = namespaces
        }

        
        
        subscript(key: String) -> Tag {
            get {
                if let tag = tag(for: key) {
                    return tag
                }
                else {
                    var namespaces = elements.compactMap { $0 as? [String : Any] }.map { Array($0.keys) }.flatMap { $0 }
                    namespaces = namespaces.filter { $0.index(of: ":") != nil && self.namespaces.contains($0.components(separatedBy: ":").first!) }
                    namespaces = Array(Set(namespaces))
                    guard namespaces.isEmpty == false else { return Tag([], namespaces: []) }
                    
                    let elms = elements
                        .compactMap { $0 as? [String : Any] }
                        .compactMap { $0.filter { namespaces.contains($0.key) }}
                        .filter { $0.isEmpty == false }.flatMap { $0 }
                        .reduce(into: [Any]()) {
                            if let values = $1.value as? [Any] {
                                $0.append(contentsOf: values)
                            }
                            else {
                                $0.append($1.value)
                            }
                        }
                    
                    elements
                        .compactMap { $0 as? [String : Any] }
                        .compactMap { $0.filter { namespaces.contains($0.key) }}
                        .filter { $0.isEmpty == false }
                        .flatMap { $0 }
                        .reduce(into: [Any]()) {
                            let aaa = $1
                            if let values = $1.value as? [Any] {
                                $0.append(contentsOf: values)
                                print($0)
                            }
                            else {
                                $0.append($1.value)
                            }
                    }
                    return Tag(elms, namespaces: self.namespaces)
                }
            }
        }
        
        private func tag(for key: String) -> Tag? {
            guard let element = elements.first as? [String : Any], elements.isEmpty == false else { return nil }
            switch element[key] {
            case let elements as [Any]:
                return Tag(elements, namespaces: namespaces)
            case let text as String:
                return Tag([["@text": text]], namespaces: namespaces)
            case let element as [String : Any]:
                return Tag([element], namespaces: namespaces)
            default:
                return nil
            }
        }
        
        subscript(index: Int) -> Tag {
            get {
                guard index < elements.count else { return Tag([], namespaces: namespaces) }
                return Tag([elements[index]], namespaces: namespaces)
            }
        }
        
    }
}


fileprivate extension Array where Element: StringProtocol {
    var namespaces: [String] {
        return filter { $0.lowercased().hasPrefix("$xmlns") } as! [String]
    }
}

fileprivate extension String {
    var namespace: String {
        // removes the "$" prefix
        // and returns the suffix
        return String(lowercased().dropFirst().split(separator: ":").last!)
    }
}

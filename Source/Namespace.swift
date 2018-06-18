//
//  Namespace.swift
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
    
    public struct Namespace {
        
        /// A qualified namespace
        private(set) var prefix: String
        
        /// A Uniform Resource Identifier (URI) is a string of characters which identifies an Internet Resource.
        /// The most common URI is the Uniform Resource Locator (URL) which identifies an Internet domain address. Another, not so common type of URI is the Uniform Resource Name (URN).
        private(set) var URI: String

        /// Creates a `Namespace` instance using a prefix, URI and previous namespaces.
        ///
        /// - parameter prefix: a qualified namespace
        /// - parameter URI: string of characters which identifies an Internet Resource
        /// - parameter namespaces: list of previous namespaces
        ///
        /// - returns: The new `Namespace` instance.
        internal init(prefix: String, URI: String) {
            self.prefix = prefix
            self.URI = URI
        }
        
    }
}

//
//  LinearProbingHashTable+Sequence.swift
//  LinearProbingHashTable
//
//  Created by Valeriano Della Longa on 2021/03/28.
//  Copyright © 2021 Valeriano Della Longa
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

extension LinearProbingHashTable: Sequence {
    public typealias Element = (key: Key, value: Value)
    
    /// An iterator over the members of a `LinearProbingHashTable<Key, Value>`.
    public struct Iterator: IteratorProtocol {
        private var bufferIterator: LPHTBuffer<Key, Value>.Iterator?
           
        fileprivate init(buffer: LPHTBuffer<Key, Value>?) {
            self.bufferIterator = buffer?.makeIterator()
        }
           
        public mutating func next() -> Element? {
            guard bufferIterator != nil else { return nil }
               
            let nextElement = bufferIterator?.next()
            if nextElement == nil { bufferIterator = nil }
               
            return nextElement
        }
        
    }
    
    /// A value equal to the number of key-value pairs stored in the hash table.
    ///
    /// - Complexity: O(1).
    public var underestimatedCount: Int { buffer?.count ?? 0 }
    
    /// Returns an iterator over the hash table's key-value pairs.
    ///
    /// Iterating over an hash table yields the key-value pairs as two-element
    /// tuples. You can decompose the tuple in a `for`-`in` loop, which calls
    /// `makeIterator()` behind the scenes, or when calling the iterator's
    /// `next()` method directly.
    ///
    ///     let hues: LinearProbingHashTable<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     for (name, hueValue) in hues {
    ///         print("The hue of \(name) is \(hueValue).")
    ///     }
    ///     // Prints "The hue of Heliotrope is 296."
    ///     // Prints "The hue of Coral is 16."
    ///     // Prints "The hue of Aquamarine is 156."
    ///
    /// - Returns:  An iterator over the hash table with elements of type
    ///             `(key: Key, value: Value)`.
    public func makeIterator() -> Iterator {
        Iterator(buffer: buffer)
    }
    
}

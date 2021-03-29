//
//  LinearProbingHashTable+Values.swift
//  LineraProbingHashTable
//
//  Created by Valeriano Della Longa on 2021/03/29.
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

extension LinearProbingHashTable {
    /// A collection containing just the values of the hash table.
    ///
    /// When iterated over, values appear in this collection in the same order as
    /// they occur in the hash table's key-value pairs.
    ///
    ///     let countryCodes: LinearProbingHashTable<String, String> = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     print(countryCodes)
    ///     // Prints "["BR": "Brazil", "JP": "Japan", "GH": "Ghana"]"
    ///
    ///     for v in countryCodes.values {
    ///         print(v)
    ///     }
    ///     // Prints "Brazil"
    ///     // Prints "Japan"
    ///     // Prints "Ghana"
    ///
    /// - Complexity: O(*n*) where *n* is lenght of this hash table.
    @inline(__always)
    public var values: Values {
        get { Values(self) }
        
        _modify {
            var values = Values(Self())
            swap(&values.ht, &self)
            defer {
                self = values.ht
            }
            yield &values
        }
    }
    
    /// A view of an hash table's values.
    public struct Values: MutableCollection {
        fileprivate var ht: LinearProbingHashTable
        
        fileprivate init(_ ht: LinearProbingHashTable) {
            self.ht = ht
        }
        
        // MARK: - Collection conformance
        public typealias Element = LinearProbingHashTable.Value
        
        public typealias Index = LinearProbingHashTable.Index
        
        public var count: Int { ht.count }
        
        public var underestimatedCount: Int { ht.count }
        
        public var isEmpty: Bool { ht.isEmpty }
        
        public var startIndex: Index { ht.startIndex }
        
        public var endIndex: Index { ht.endIndex }
        
        public func formIndex(after i: inout Index) {
            ht.formIndex(after: &i)
        }
        
        public func index(after i: Index) -> Index {
            ht.index(after: i)
        }
        
        public func formIndex(_ i: inout Index, offsetBy distance: Int) {
            ht.formIndex(&i, offsetBy: distance)
        }
        
        public func index(_ i: Index, offsetBy distance: Int) -> Index {
            ht.index(i, offsetBy: distance)
        }
        
        public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index) -> Bool {
            ht.formIndex(&i, offsetBy: distance, limitedBy: limit)
        }
        
        public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
            ht.index(i, offsetBy: distance, limitedBy: limit)
        }
        
        public subscript(position: Index) -> Element {
            get {
                ht[position].value
            }
            
            mutating set {
                ht.makeUnique()
                let m = ht.capacity + 1
                precondition((0..<m).contains(position.bIdx), "Index out of bounds.")
                precondition(ht.buffer?.keys[position.bIdx] != nil, "Invalid index for this hash table")
                ht.buffer!.values[position.bIdx] = newValue
            }
        }
        
    }
    
}

// MARK: - Equatable conformance
extension LinearProbingHashTable.Values: Equatable where Value: Equatable {
    public static func == (lhs: LinearProbingHashTable<Key, Value>.Values, rhs: LinearProbingHashTable<Key, Value>.Values) -> Bool {
        guard
            lhs.count == rhs.count
        else { return false}
        
        for (lElement, rElement) in zip(lhs, rhs) where lElement != rElement {
            
            return false
        }
        
        return true
    }
    
}

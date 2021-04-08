//
//  LinearProbingHashTable+Collection.swift
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

extension LinearProbingHashTable {
    /// The position of a key-value pair in an hash table.
    ///
    /// Hash table has two subscripting interfaces:
    ///
    /// 1. Subscripting with a key, yielding an optional value:
    ///
    ///        v = d[k]!
    ///
    /// 2. Subscripting with an index, yielding a key-value pair:
    ///
    ///        (k, v) = d[i]
    public struct Index: Comparable {
        var bIdx: Int
        
        init(asStartIndexOf hashTable: LinearProbingHashTable) {
            self.bIdx = hashTable.buffer?.startIndex ?? hashTable.capacity + 1
        }
        
        init(asEndIndexOf hashTable: LinearProbingHashTable) {
            self.bIdx = hashTable.capacity + 1
        }
        
        init?(asIndexForKey k: Key, of hashTable: LinearProbingHashTable) {
            if  let kIndex = hashTable.buffer?.index(forKey: k),
                hashTable.buffer!.keys[kIndex] == k
            {
                self.bIdx = kIndex
            } else {
                
                return nil
            }
        }
        
        func element(on hashTable: LinearProbingHashTable) -> Element? {
            guard hashTable.buffer != nil else { return nil }
            
            let m = hashTable.capacity + 1
            guard bIdx < m else { return nil }
            
            guard
                let k = hashTable.buffer!.keys[bIdx],
                let v = hashTable.buffer!.values[bIdx]
            else { return nil }
            
            return (k, v)
        }
        
        @discardableResult
        mutating func moveToNext(on hashTable: LinearProbingHashTable) -> Element? {
            bIdx += 1
            if let next = element(on: hashTable) { return next }
            let m = hashTable.capacity + 1
            while 0..<m ~= bIdx {
                if
                    let k = hashTable.buffer?.keys[bIdx],
                    let v = hashTable.buffer?.values[bIdx]
                {
                    
                    return (k, v)
                }
                
                bIdx += 1
            }
            
            return nil
        }
        
        // MARK: - Comparable Conformance
        public static func < (lhs: LinearProbingHashTable<Key, Value>.Index, rhs: LinearProbingHashTable<Key, Value>.Index) -> Bool {
            lhs.bIdx < rhs.bIdx
        }
        
        public static func == (lhs: LinearProbingHashTable<Key, Value>.Index, rhs: LinearProbingHashTable<Key, Value>.Index) -> Bool {
            lhs.bIdx == rhs.bIdx
        }
        
    }
    
}

extension LinearProbingHashTable: Collection {
    /// The number of key-value pairs in the hash table.
    ///
    /// - Complexity: O(1).
    public var count: Int { buffer?.count ?? 0 }
    
    /// A Boolean value that indicates whether the hash table is empty.
    ///
    /// Hash table are empty when created with an initializer or an empty
    /// dictionary literal.
    ///
    ///     var frequencies: LinearProbingHashTable<String, Int> = [:]
    ///     print(frequencies.isEmpty)
    ///     // Prints "true"
    ///
    /// - Complexity: O(1).
    public var isEmpty: Bool { buffer?.isEmpty ?? true }
    
    public var startIndex: Index {
        Index(asStartIndexOf: self)
    }
    
    public var endIndex: Index {
        Index(asEndIndexOf: self)
    }
    
    public func formIndex(after i: inout Index) {
        i.moveToNext(on: self)
    }
    
    public func index(after i: Index) -> Index {
        var j = i
        formIndex(after: &j)
        
        return j
    }
    
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
        for _ in stride(from: 0, to: distance, by: 1) {
            i.moveToNext(on: self)
        }
    }
    
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        var j = i
        formIndex(&j, offsetBy: distance)
        
        return j
    }
    
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
        precondition(distance >= 0 , "distance must not be negative")
        // Just ignore the limit when is less than i
        if limit < i { return index(i, offsetBy: distance) }
        
        // let's stride indices:
        var result = i
        for _ in stride(from: 0, to: distance, by: 1) {
            // When we're gonna end up after limit we return nil
            if result == limit { return nil }
            result.moveToNext(on: self)
        }
        
        return result
    }
    
    public subscript(position: Index) -> (key: Key, value: Value) {
        get {
            guard
                let e = position.element(on: self)
            else { preconditionFailure("Index out of bounds") }
            
            return e
        }
    }
    
}

extension LinearProbingHashTable {
    /// Removes and returns the key-value pair at the specified index.
    ///
    /// Calling this method might invalidate indices of the hash table previously stored.
    ///
    /// - Parameter index:  The position of the key-value pair to remove. `index`
    ///                     must be a valid index of the hash table,
    ///                     and must not equal the hash table's end index.
    /// - Returns: The key-value pair that correspond to `index`.
    ///
    /// - Complexity: Amortized O(1).
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
        guard
            let removedElement = index.element(on: self)
        else {
            preconditionFailure("Index out of bounds")
        }
        
        defer {
            removeValue(forKey: removedElement.key)
        }
        
        return removedElement
    }
    
    /// Returns the index for the given key.
    ///
    /// If the given key is found in the hash table, this method returns an index
    /// into the dictionary that corresponds with the key-value pair.
    ///
    ///     let countryCodes: LinearProbingHashTable<String, String> = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     let index = countryCodes.index(forKey: "JP")
    ///
    ///     print("Country code for \(countryCodes[index!].value): '\(countryCodes[index!].key)'.")
    ///     // Prints "Country code for Japan: 'JP'."
    ///
    /// - Parameter key: The key to find in the hash table.
    /// - Returns:  The index for `key` and its associated value if `key` is in
    ///             the hash table; otherwise, `nil`.
    public func index(forKey key: Key) -> Index? {
        Index(asIndexForKey: key, of: self)
    }
    
}

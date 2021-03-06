//
//  LinearProbingHashTable+Dictionary.swift
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

extension LinearProbingHashTable: ExpressibleByDictionaryLiteral {
    // MARK: - Computed Properties
    /// The total number of key-value pairs that the hash table can contain without
    /// allocating new storage.
    ///
    /// - Complexity: O(1)
    public var capacity: Int { buffer?.capacity ?? 0 }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
    /// Creates a new hash table from the key-value pairs in the given sequence.
    ///
    /// You use this initializer to create an hash table when you have a sequence
    /// of key-value tuples with unique keys. Passing a sequence with duplicate
    /// keys to this initializer results in a runtime error. If your
    /// sequence might have duplicate keys, use the
    /// `init(_:uniquingKeysWith:)` initializer instead.
    ///
    /// The following example creates a new hash table using an array of strings
    /// as the keys and the integers in a countable range as the values:
    ///
    ///     let digitWords = ["one", "two", "three", "four", "five"]
    ///     let wordToValue = LinearProbingHashTable(uniqueKeysWithValues: zip(digitWords, 1...5))
    ///     print(wordToValue["three"]!)
    ///     // Prints "3"
    ///     print(wordToValue)
    ///     // Prints "["three": 3, "four": 4, "five": 5, "one": 1, "two": 2]"
    ///
    /// - Parameter keysAndValues: A sequence of key-value pairs to use for
    ///   the new hash table. Every key in `keysAndValues` must be unique.
    /// - Returns: A new hash table initialized with the elements of
    ///   `keysAndValues`.
    /// - Precondition: The sequence must not have duplicate keys.
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Iterator.Element == (Key, Value) {
        self.init(keysAndValues) { _, _ in
            preconditionFailure("keys must be unique")
        }
    }
    
    /// Creates a new hash table from the key-value pairs in the given sequence,
    /// using a combining closure to determine the value for any duplicate keys.
    ///
    /// You use this initializer to create an hash table when you have a sequence
    /// of key-value tuples that might have duplicate keys. As the hash table is
    /// built, the initializer calls the `combine` closure with the current and
    /// new values for any duplicate keys. Pass a closure as `combine` that
    /// returns the value to use in the resulting hash table: the closure can
    /// choose between the two values, combine them to produce a new value, or
    /// even throw an error.
    ///
    /// The following example shows how to choose the first and last values for
    /// any duplicate keys:
    ///
    ///     let pairsWithDuplicateKeys = [("a", 1), ("b", 2), ("a", 3), ("b", 4)]
    ///
    ///     let firstValues = LinearProbingHashTable(pairsWithDuplicateKeys,
    ///                                  uniquingKeysWith: { (first, _) in first })
    ///     // ["b": 2, "a": 1]
    ///
    ///     let lastValues = LinearProbingHashTable(pairsWithDuplicateKeys,
    ///                                 uniquingKeysWith: { (_, last) in last })
    ///     // ["b": 4, "a": 3]
    ///
    /// - Parameters:
    ///   - keysAndValues:  A sequence of key-value pairs to use for
    ///                     the new hash table
    ///   - combine:    A closure that is called with the values for any
    ///                 duplicate keys that are encountered.
    ///                 The closure returns the desired value for the final hash table.
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Iterator.Element == (Key, Value) {
        if let other = keysAndValues as? LinearProbingHashTable<Key, Value> {
            self.init(other)
            
            return
        }
        
        var newBuffer: LPHTBuffer<Key, Value>? = nil
        let done: Bool = try keysAndValues
            .withContiguousStorageIfAvailable { kvBuffer in
                guard
                    kvBuffer.baseAddress != nil && kvBuffer.count > 0
                else { return true }
                
                newBuffer = LPHTBuffer(capacity: Swift.max(Self.minimumBufferCapacity, (kvBuffer.count * 3) / 2))
                for (key, value) in keysAndValues {
                    try newBuffer!.setValue(value, forKey: key, uniquingKeyWith: combine)
                }
                
                return true
            } ?? false
        if !done {
            var kvIter = keysAndValues.makeIterator()
            if let (firstKey, firstValue) = kvIter.next() {
                newBuffer = LPHTBuffer(capacity: Swift.max(Self.minimumBufferCapacity, (keysAndValues.underestimatedCount * 3) / 2))
                try newBuffer!.setValue(firstValue, forKey: firstKey, uniquingKeyWith: combine)
                while let (key, value) = kvIter.next() {
                    try newBuffer!.setValue(value, forKey: key, uniquingKeyWith: combine)
                    if newBuffer!.isFull {
                        newBuffer = newBuffer!.clone(newCapacity: newBuffer!.capacity * 2)
                    }
                }
            }
            
        }
        self.init(buffer: newBuffer)
    }
    
    /// Creates a new hash table whose keys are the groupings returned by the
    /// given closure and whose values are arrays of the elements that returned
    /// each key.
    ///
    /// The arrays in the "values" position of the new hash table each contain at
    /// least one element, with the elements in the same order as the source
    /// sequence.
    ///
    /// The following example declares an array of names, and then creates an
    /// hash table from that array by grouping the names by first letter:
    ///
    ///     let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    ///     let studentsByLetter = LinearProbingHashTable(grouping: students, by: { $0.first! })
    ///     // ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]]
    ///
    /// The new `studentsByLetter` hash table has three entries, with students'
    /// names grouped by the keys `"E"`, `"K"`, and `"A"`.
    ///
    /// - Parameters:
    ///   - values: A sequence of values to group into an hash table.
    ///   - keyForValue: A closure that returns a key for each element in
    ///     `values`.
    public init<S: Sequence>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element] {
        var newBuffer: LPHTBuffer<Key, Value>? = nil
        let done: Bool = try values
            .withContiguousStorageIfAvailable { vBuff in
                guard
                    vBuff.baseAddress != nil && vBuff.count > 0
                else { return true }
                newBuffer = LPHTBuffer(capacity: Swift.max(Self.minimumBufferCapacity, (vBuff.count * 3) / 2))
                for v in vBuff {
                    let k = try keyForValue(v)
                    newBuffer!.setValue([v], forKey: k, uniquingKeyWith: +)
                }
                
                return true
            } ?? false
        
        if !done {
            var valuesIter = values.makeIterator()
            if let firstValue = valuesIter.next() {
                newBuffer = LPHTBuffer(capacity: Swift.max(Self.minimumBufferCapacity, (values.underestimatedCount * 3) / 2))
                let fKey = try keyForValue(firstValue)
                newBuffer!.setValue([firstValue], forKey: fKey, uniquingKeyWith: +)
                while let value = valuesIter.next() {
                    let key = try keyForValue(value)
                    newBuffer!.setValue([value], forKey: key, uniquingKeyWith: +)
                    if newBuffer!.isFull {
                        newBuffer = newBuffer!.clone(newCapacity: newBuffer!.capacity * 2)
                    }
                }
            }
        }
        
        self.init(buffer: newBuffer)
    }
    
    fileprivate init(_ other: LinearProbingHashTable) {
        self.init(buffer: other.buffer)
    }
    
}

extension LinearProbingHashTable {
    /// Reserves enough space to store the specified number of key-value pairs.
    ///
    /// If you are adding a known number of key-value pairs to an hash table, use this
    /// method to avoid multiple reallocations. This method ensures that the
    /// hash table has unique, mutable, contiguous storage, with space allocated
    /// for at least the requested number of key-value pairs.
    /// This method might invalidate indices of the hash table previously stored.
    ///
    /// - Parameter minimumCapacity:    The requested number of
    ///                                 key-value pairs to store.
    /// - Complexity: O(*k*) where *k* is the final capacity for the hash table.
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        precondition(minimumCapacity >= 0, "minimumCapacity must not be negative")
        makeUniqueReserving(minimumCapacity: minimumCapacity)
    }
    
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the hash table, or `nil` if the key is not found.
    /// The setter of this subscript might invalidate indices of the hash table previously stored.
    ///
    /// The following example creates a new hash table and prints the value of a
    /// key found in the has table (`"Coral"`) and a key not found in the
    /// hash table (`"Cerise"`).
    ///
    ///     var hues: LinearProbingHashTable<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     print(hues["Coral"])
    ///     // Prints "Optional(16)"
    ///     print(hues["Cerise"])
    ///     // Prints "nil"
    ///
    /// When you assign a value for a key and that key already exists, the
    /// hash table overwrites the existing value. If the hash table doesn't
    /// contain the key, the key and value are added as a new key-value pair.
    ///
    /// Here, the value for the key `"Coral"` is updated from `16` to `18` and a
    /// new key-value pair is added for the key `"Cerise"`.
    ///
    ///     hues["Coral"] = 18
    ///     print(hues["Coral"])
    ///     // Prints "Optional(18)"
    ///
    ///     hues["Cerise"] = 330
    ///     print(hues["Cerise"])
    ///     // Prints "Optional(330)"
    ///
    /// If you assign `nil` as the value for the given key, the hash table
    /// removes that key and its associated value.
    ///
    /// In the following example, the key-value pair for the key `"Aquamarine"`
    /// is removed from the hash table by assigning `nil` to the key-based
    /// subscript.
    ///
    ///     hues["Aquamarine"] = nil
    ///     print(hues)
    ///     // Prints "["Coral": 18, "Heliotrope": 296, "Cerise": 330]"
    ///
    /// - Parameter key: The key to find in the hash table.
    /// - Returns: The value associated with `key` if `key` is in the hash table;
    ///   otherwise, `nil`.
    public subscript(_ key: Key) -> Value? {
        get {
            buffer?.getValue(forKey: key)
        }
        
        mutating set {
            guard
                let v = newValue
            else {
                removeValue(forKey: key)
                
                return
            }
            
            updateValue(v, forKey: key)
        }
    }
    
    /// Accesses the value with the given key. If the hash table doesn't contain
    /// the given key, accesses the provided default value as if the key and
    /// default value existed in the hash table.
    ///
    /// Use this subscript when you want either the value for a particular key
    /// or, when that key is not present in the hash table, a default value.
    /// The setter of this subscript might invalidate indices of the hash table previously stored.
    /// This example uses the subscript with a message to use in case an HTTP response
    /// code isn't recognized:
    ///
    ///     var responseMessages: LinearProbingHashTable<Int, String> = [
    ///         200: "OK",
    ///         403: "Access forbidden",
    ///         404: "File not found",
    ///         500: "Internal server error"
    ///     ]
    ///
    ///     let httpResponseCodes = [200, 403, 301]
    ///     for code in httpResponseCodes {
    ///         let message = responseMessages[code, default: "Unknown response"]
    ///         print("Response \(code): \(message)")
    ///     }
    ///     // Prints "Response 200: OK"
    ///     // Prints "Response 403: Access Forbidden"
    ///     // Prints "Response 301: Unknown response"
    ///
    /// When an hash table's `Value` type has value semantics, you can use this
    /// subscript to perform in-place operations on values in the hash table.
    /// The following example uses this subscript while counting the occurrences
    /// of each letter in a string:
    ///
    ///     let message = "Hello, Elle!"
    ///     var letterCounts: LinearProbingHashTable<Character, Int> = [:]
    ///     for letter in message {
    ///         letterCounts[letter, default: 0] += 1
    ///     }
    ///     // letterCounts == ["H": 1, "e": 2, "l": 4, "o": 1, ...]
    ///
    /// When `letterCounts[letter, defaultValue: 0] += 1` is executed with a
    /// value of `letter` that isn't already a key in `letterCounts`, the
    /// specified default value (`0`) is returned from the subscript,
    /// incremented, and then added to the hash table under that key.
    ///
    /// - Note: Do not use this subscript to modify hash table values if the
    ///   dictionary's `Value` type is a class. In that case, the default value
    ///   and key are not written back to the hash table after an operation.
    ///
    /// - Parameters:
    ///   - key: The key to look up in the hash table.
    ///   - defaultValue:   The default value to use if `key` doesn't exist
    ///                     in the hash table.
    /// - Returns:  The value associated with `key` in the hash table;
    ///             otherwise, `defaultValue`.
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            buffer?.getValue(forKey: key) ?? defaultValue()
        }
        
        _modify {
            makeUnique()
            var other = LinearProbingHashTable<Key, Value>()
            (self, other) = (other, self)
            var ptr: UnsafeMutablePointer<Value?>
            var b = other.buffer!
            var i = b.index(forKey: key)
            if b.keys[i] != nil {
                ptr = b.values.advanced(by: i)
            } else {
                if b.isFull {
                    let newCap = Swift.max(b.capacity * 2, b.count * 3 / 2)
                    b = b.clone(newCapacity: newCap)
                    i = b.index(forKey: key)
                }
                b.updateValue(defaultValue(), forKey: key)
                ptr = b.values.advanced(by: i)
            }
            
            defer {
                self = LinearProbingHashTable(buffer: b)
            }
            yield &ptr.pointee!
        }
        
    }
    
    /// Returns the value associated to the the given key. If such key doesn't exists in the hash
    /// table, then returns `nil`.
    ///
    /// - Parameter forKey: The key to lookup in the hash table.
    /// - Returns:  The value associated to the given key, if such key exists in the
    ///             hash table; otherwise `nil`.
    public func getValue(forKey k: Key) -> Value? {
        buffer?.getValue(forKey: k)
    }
        
    /// Updates the value stored in the hash table for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value. This method might invalidate indices of the hash table previously stored.
    ///
    ///     var hues: LinearProbingHashTable<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///
    ///     if let oldValue = hues.updateValue(18, forKey: "Coral") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     }
    ///     // Prints "The old value of 16 was replaced with a new one."
    ///
    /// If the given key is not present in the hash table, this method adds the
    /// key-value pair and returns `nil`.
    ///
    ///     if let oldValue = hues.updateValue(330, forKey: "Cerise") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     } else {
    ///         print("No value was found in the hash table for that key.")
    ///     }
    ///     // Prints "No value was found in the hash table for that key."
    ///
    /// - Parameters:
    ///   - value: The new value to add to the hash table.
    ///   - key:    The key to associate with `value`. If `key` already exists in
    ///             the hash table, `value` replaces the existing associated value.
    ///             If `key` isn't already a key of the hash table,
    ///             the `(key, value)` pair is added.
    /// - Returns:  The value that was replaced, or `nil` if a new key-value pair
    ///             was added.
    @discardableResult
    public mutating func updateValue(_ v: Value, forKey k: Key) -> Value? {
        makeUniqueEventuallyIncreasingCapacity()
        
        return buffer!.updateValue(v, forKey: k)
    }
        
    /// Removes the given key and its associated value from the hash table.
    ///
    /// If the key is found in the hash table, this method returns the key's
    /// associated value. This method might invalidate indices of the hash table previously stored.
    ///
    ///     var hues: LinearProbingHashTable<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     if let value = hues.removeValue(forKey: "Coral") {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 16 was removed."
    ///
    /// If the key isn't found in the hash table, `removeValue(forKey:)` returns
    /// `nil`.
    ///
    ///     if let value = hues.removeValueForKey("Cerise") {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for that key.""
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns:  The value that was removed, or `nil` if the key was not
    ///             present in the hash table.
    ///
    /// - Complexity: Amortized O(1).
    @discardableResult
    public mutating func removeValue(forKey k: Key) -> Value? {
        makeUniqueEventuallyReducingCapacity()
        
        return buffer?.removeElement(withKey: k)?.value
    }
        
    /// Removes all key-value pairs from the hash table.
    ///
    /// Calling this method might invalidate indices of the hash table previously stored.
    ///
    /// - Parameter keepCapacity:   Whether the hash table should keep its
    ///                             underlying buffer.
    ///                             If you pass `true`, the operation
    ///                             preserves the buffer capacity that
    ///                             the collection has, otherwise the underlying
    ///                             buffer is released.  The default is `false`.
    ///
    /// - Complexity: Amortized O(*n*), where *n* is the lenght of the hash table.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        guard buffer != nil else { return }
        
        guard keepCapacity else {
            self = Self()
            
            return
        }
        guard !isEmpty else { return }
        
        let prevCapacity = capacity
        self = Self(minimumCapacity: prevCapacity)
    }
    
    /// Merges the key-value pairs in the given sequence into the hash table,
    /// using a combining closure to determine the value for any duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the updated
    /// hash table, or to combine existing and new values. As the key-value
    /// pairs are merged with the hash table, the `combine` closure is called
    /// with the current and new values for any duplicate keys that are
    /// encountered.
    ///
    /// This method might invalidate indices of the hash table previously stored.
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     var dictionary: LinearprobingHashTable<String, Key> = ["a": 1, "b": 2]
    ///
    ///     // Keeping existing value for key "a":
    ///     dictionary.merge(zip(["a", "c"], [3, 4])) { (current, _) in current }
    ///     // ["b": 2, "a": 1, "c": 4]
    ///
    ///     // Taking the new value for key "a":
    ///     dictionary.merge(zip(["a", "d"], [5, 6])) { (_, new) in new }
    ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
    ///
    /// - Parameters:
    ///   - other:  A sequence of key-value pairs.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final hash table.
    public mutating func merge<S: Sequence>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S.Iterator.Element == (Key, Value) {
        if let other = keysAndValues as? LinearProbingHashTable<Key, Value> {
            try merge(other, uniquingKeysWith: combine)
            
            return
        }
        guard
            !isEmpty
        else {
            self = try LinearProbingHashTable(keysAndValues, uniquingKeysWith: combine)
            
            return
        }
        
        let mergedBuffer = try buffer!.merging(keysAndValues, uniquingKeysWith: combine)
        self = LinearProbingHashTable(buffer: mergedBuffer)
    }
    
    /// Merges the given hash table into this hash table, using a combining
    /// closure to determine the value for any duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the updated
    /// hash table, or to combine existing and new values. As the key-values
    /// pairs in `other` are merged with this hash table, the `combine` closure
    /// is called with the current and new values for any duplicate keys that
    /// are encountered.
    ///
    /// This method might invalidate indices of the hash table previously stored.
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     var dictionary: LinearProbiningHashTable<String, Int> = ["a": 1, "b": 2]
    ///     var other = LinearProbingHashTable<String, Int> = ["a": 3, "c": 4]
    ///
    ///     // Keeping existing value for key "a":
    ///     dictionary.merge(other) { (current, _) in current }
    ///     // ["b": 2, "a": 1, "c": 4]
    ///
    ///     // Taking the new value for key "a":
    ///     other = ["a": 5, "d": 6]
    ///     dictionary.merge(other) { (_, new) in new }
    ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
    ///
    /// - Parameters:
    ///   - other:  An hash table to merge.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final hash table.
    public mutating func merge(_ other: LinearProbingHashTable, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        guard !other.isEmpty else { return }
        
        guard !isEmpty else {
            self = LinearProbingHashTable(buffer: other.buffer)
            
            return
        }
        
        let mergedBuffer = try buffer!.merging(other.buffer!, uniquingKeysWith: combine)
        self = LinearProbingHashTable(buffer: mergedBuffer)
    }
    
    /// Creates an hash table by merging the given hash table into this
    /// hash table, using a combining closure to determine the value for
    /// duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the returned
    /// hash table, or to combine existing and new values. As the key-value
    /// pairs in `other` are merged with this hash table, the `combine` closure
    /// is called with the current and new values for any duplicate keys that
    /// are encountered.
    ///
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     let dictionary: LinearProbingHashTable<String, Int> = ["a": 1, "b": 2]
    ///     let other: LinearProbingHashTable<String, Int> = ["a": 3, "b": 4]
    ///
    ///     let keepingCurrent = dictionary.merging(other)
    ///           { (current, _) in current }
    ///     // ["b": 2, "a": 1]
    ///     let replacingCurrent = dictionary.merging(other)
    ///           { (_, new) in new }
    ///     // ["b": 4, "a": 3]
    ///
    /// - Parameters:
    ///   - other:  An hash table to merge.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final hash table.
    /// - Returns:  A new hash table with the combined keys and values
    ///             of this hash table and `other`.
    func merging(_ other: LinearProbingHashTable, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LinearProbingHashTable {
        guard !other.isEmpty else { return self }
        
        guard !isEmpty else { return other }
        
        var merged = self
        try merged.merge(other, uniquingKeysWith: combine)
        
        return merged
    }
    
    /// Creates an hash table by merging key-value pairs in a sequence into the
    /// hash table, using a combining closure to determine the value for
    /// duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the returned
    /// hash table, or to combine existing and new values. As the key-value
    /// pairs are merged with the hash table, the `combine` closure is called
    /// with the current and new values for any duplicate keys that are
    /// encountered.
    ///
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     let dictionary: LinearProbningHashTable<String, Int> = ["a": 1, "b": 2]
    ///     let newKeyValues = zip(["a", "b"], [3, 4])
    ///
    ///     let keepingCurrent = dictionary.merging(newKeyValues) { (current, _) in current }
    ///     // ["b": 2, "a": 1]
    ///     let replacingCurrent = dictionary.merging(newKeyValues) { (_, new) in new }
    ///     // ["b": 4, "a": 3]
    ///
    /// - Parameters:
    ///   - other:  A sequence of key-value pairs.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final hash table.
    /// - Returns:  A new hash table with the combined keys and values
    ///             of this hash table and `other`.
    func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LinearProbingHashTable where S : Sequence, S.Element == (Key, Value) {
        if let otherHT = other as? LinearProbingHashTable {
            
            return try merging(otherHT, uniquingKeysWith: combine)
        }
        
        guard
            !isEmpty
        else {
            return try LinearProbingHashTable(other, uniquingKeysWith: combine)
        }
        
        var merged = self
        try merged.merge(other, uniquingKeysWith: combine)
        
        return merged
    }
    
    /// Returns a new hash table containing the keys of this hash table with the
    /// values transformed by the given closure.
    ///
    /// - Parameter transform: A closure that transforms a value. `transform`
    ///   accepts each value of the hash table as its parameter and returns a
    ///   transformed value of the same or of a different type.
    /// - Returns:  An hash table containing the keys and transformed values
    ///             of this hash table.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the hash table.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LinearProbingHashTable<Key, T> {
        let mappedBuffer = try buffer?.mapValues(transform)
        
        return LinearProbingHashTable<Key, T>(buffer: mappedBuffer)
    }
    
    /// Returns a new hash table containing only the key-value pairs that have
    /// non-`nil` values as the result of transformation by the given closure.
    ///
    /// Use this method to receive an hash table with non-optional values when
    /// your transformation produces optional values.
    ///
    /// In this example, note the difference in the result of using `mapValues`
    /// and `compactMapValues` with a transformation that returns an optional
    /// `Int` value.
    ///
    ///     let data: LinearProbingHashTable<String, String> = ["a": "1", "b": "three", "c": "///4///"]
    ///
    ///     let m: LinearProbingHashTable<String, Int?> = data.mapValues { str in Int(str) }
    ///     // ["a": 1, "b": nil, "c": nil]
    ///
    ///     let c: LinearProbingHashTable<String, Int> = data.compactMapValues { str in Int(str) }
    ///     // ["a": 1]
    ///
    /// - Parameter transform:  A closure that transforms a value. `transform`
    ///                         accepts each value of the hash table as
    ///                         its parameter and returns an optional transformed
    ///                         value of the same or of a different type.
    /// - Returns:  An hash table containing the keys and non-`nil` transformed values
    ///             of this hash table.
    ///
    /// - Complexity:   O(*m* + *n*), where *n* is the length of the original
    ///                 hash table and *m* is the length of the resulting hash table.
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> LinearProbingHashTable<Key, T> {
        let mappedBuffer = try buffer?.compactMapValues(transform)
        
        return LinearProbingHashTable<Key, T>(buffer: mappedBuffer)
    }
    
    /// Returns a new hash table containing the key-value pairs of the hash table
    /// that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its
    ///   argument and returns a Boolean value indicating whether the pair
    ///   should be included in the returned hash table.
    /// - Returns: An hash table of the key-value pairs that `isIncluded` allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LinearProbingHashTable {
        let filtered: LPHTBuffer<Key, Value>? = try buffer?.filter(isIncluded)
        
        return LinearProbingHashTable(buffer: filtered)
    }
    
}

//
//  LinearProbingHashTable.swift
//  LinearProbingHashTable
//
//  Created by Valeriano Della Longa on 2021/03/27.
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

public struct LinearProbingHashTable<Key: Hashable, Value> {
    static var minimumBufferCapacity: Int { 4 }
    
    fileprivate(set) var buffer: LPHTBuffer<Key, Value>? = nil
    
    fileprivate(set) var id = ID()
    
    /// Creates an empty hash table.
    public init() { }
    
    /// Creates an empty hash table with preallocated space for at least the
    /// specified number of elements.
    ///
    /// Use this initializer to avoid intermediate reallocations of an hash table's
    /// storage buffer when you know how many key-value pairs you are adding to an
    /// hash table after creation.
    ///
    /// - Parameter minimumCapacity: The minimum number of key-value pairs that
    ///   the newly created hash table should be able to store without
    ///   reallocating its storage buffer.
    public init(minimumCapacity k: Int = 0) {
        precondition(k >= 0, "capacity must not be negative")
        
        guard k > 0 else { return }
        
        self.buffer = LPHTBuffer(capacity: Swift.max(k, Self.minimumBufferCapacity))
    }
    
    // MARK: - Computed Properties
    /// The total number of key-value pairs that the hash table can contain without
    /// allocating new storage.
    ///
    /// - Complexity: O(1)
    public var capacity: Int { buffer?.capacity ?? 0 }
    
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
    
    // MARK: - C.O.W. helpers
    init(buffer: LPHTBuffer<Key, Value>?, id: ID = ID()) {
        self.buffer = buffer
        self.id = id
    }
    
    @inline(__always)
    mutating func invalidatePreviouslyStoredIndices() {
        id = ID()
    }
    
    @inline(__always)
    mutating func makeUnique() {
        guard buffer != nil else {
            id = ID()
            buffer = LPHTBuffer(capacity: Self.minimumBufferCapacity)
            
            return
        }
        
        if !isKnownUniquelyReferenced(&buffer!) {
            buffer = buffer!.clone()
        }
    }
    
    @inline(__always)
    mutating func makeUniqueReserving(minimumCapacity k: Int) {
        assert(k >= 0, "minimumCapacity must not be negative")
        guard
            (buffer?.freeCapacity ?? 0) < k
        else {
            makeUnique()
            
            return
        }
        
        id = ID()
        let mCapacity = buffer == nil ? Swift.max(k, Self.minimumBufferCapacity) : Swift.max(((count + k) * 3) / 2, capacity * 2)
        buffer = buffer == nil ? LPHTBuffer(capacity: mCapacity) : buffer!.clone(newCapacity: mCapacity)
    }
    
    @inline(__always)
    mutating func makeUniqueEventuallyIncreasingCapacity() {
        guard
            (buffer?.isFull ?? false)
        else {
            makeUnique()
            
            return
        }
        
        id = ID()
        buffer = buffer?.clone(newCapacity: capacity * 2)
    }
    
    @inline(__always)
    mutating func makeUniqueEventuallyReducingCapacity() {
        guard buffer != nil else { return }
        
        guard
            !isEmpty
        else {
            buffer = nil
            id = ID()
            
            return
        }
        
        guard
            (buffer!.isTooSparse)
        else {
            makeUnique()
            
            return
        }
        
        id = ID()
        let mCapacity = Swift.max(capacity / 2, Self.minimumBufferCapacity)
        buffer = buffer!.clone(newCapacity: mCapacity)
    }
    
}


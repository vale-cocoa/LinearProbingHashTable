//
//  LPHTBuffer.swift
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

import Foundation
final class LPHTBuffer<Key: Hashable, Value>: NSCopying {
    fileprivate(set) var keys: UnsafeMutablePointer<Key?>
    
    fileprivate(set) var values: UnsafeMutablePointer<Value?>
    
    fileprivate(set) var count: Int = 0
    
    fileprivate(set) var startIndex: Int
    
    let capacity: Int
    
    init(capacity: Int) {
        precondition(capacity > 0, "capacity must be greater than 0")
        let m = capacity + 1
        self.keys = UnsafeMutablePointer.allocate(capacity: m)
        self.keys.initialize(repeating: nil, count: m)
        self.values = UnsafeMutablePointer.allocate(capacity: m)
        self.values.initialize(repeating: nil, count: m)
        self.capacity = capacity
        self.startIndex = m
    }
    
    fileprivate init(keys: UnsafeMutablePointer<Key?>, values: UnsafeMutablePointer<Value?>, capacity: Int, count: Int) {
        self.keys = keys
        self.values = values
        self.capacity = capacity
        self.count = count
        self.startIndex = 0
        self.recomputeStartIndex()
    }
    
    deinit {
        let m = capacity + 1
        keys.deinitialize(count: m)
        keys.deallocate()
        values.deinitialize(count: m)
        values.deallocate()
    }
    
    // MARK: - NSCopying conformance
    func copy(with zone: NSZone? = nil) -> Any {
        let m = capacity + 1
        let clonedKeys = UnsafeMutablePointer<Key?>.allocate(capacity: m)
        let clonedValues = UnsafeMutablePointer<Value?>.allocate(capacity: m)
        for idx in 0..<m {
            let clonedKey: Key? = ((keys[idx] as? NSCopying)?.copy(with: zone) as? Key) ?? keys[idx]
            clonedKeys.advanced(by: idx).initialize(to: clonedKey)
            
            let clonedValue: Value? = ((values[idx] as? NSCopying)?.copy(with: zone) as? Value) ?? values[idx]
            clonedValues.advanced(by: idx).initialize(to: clonedValue)
        }
        
        return Self.init(keys: clonedKeys, values: clonedValues, capacity: capacity, count: count)
    }
    
    func clone() -> LPHTBuffer {
        copy() as! LPHTBuffer<Key, Value>
    }
    
}

// MARK: - Convenience Initializers
extension LPHTBuffer {
    convenience init(other: LPHTBuffer) {
        let m = other.capacity + 1
        let clonedKeys = UnsafeMutablePointer<Key?>.allocate(capacity: m)
        let clonedValues = UnsafeMutablePointer<Value?>.allocate(capacity: m)
        for idx in 0..<m {
            let clonedKey: Key? = ((other.keys[idx] as? NSCopying)?.copy() as? Key?) ?? other.keys[idx]
            clonedKeys.advanced(by: idx).initialize(to: clonedKey)
            
            let clonedValue: Value? = ((other.values[idx] as? NSCopying)?.copy() as? Value?) ?? other.values[idx]
            clonedValues.advanced(by: idx).initialize(to: clonedValue)
        }
        
        self.init(keys: clonedKeys, values: clonedValues, capacity: other.capacity, count: other.count)
    }
    
}

// MARK: - Computed properties
extension LPHTBuffer {
    var isEmpty: Bool {
        count == 0
    }
    
    var isFull: Bool { count == capacity }
    
    var freeCapacity: Int { capacity - count }
    
    var isTooSparse: Bool { freeCapacity > capacity / 8 }
    
}

// MARK: - Static methods
extension LPHTBuffer {
    static func idx(forKey k: Key, in buffer: LPHTBuffer) -> Int? {
        let m = buffer.capacity + 1
        var hasher = Hasher()
        hasher.combine(k)
        let hv = hasher.finalize()
        var idx = (hv & 0x7fffffff) % m
        guard
            buffer.keys[idx] != k
        else { return idx }
        
        guard
            !buffer.isFull
        else { return nil }
        
        while buffer.keys[idx] != nil {
            idx = (idx + 1) % m
        }
        
        return idx
    }
    
    static func clone(buffer: LPHTBuffer, toNewCapacity newCap: Int) -> LPHTBuffer {
        precondition(newCap > 0, "new capacity must be greater than 0")
        precondition(newCap >= buffer.count, "new capacity must be greater than or equal to count of elements stored in buffer to clone")
        let clone = Self.init(capacity: newCap)
        let m = buffer.capacity + 1
        for bIdx in 0..<m where buffer.keys[bIdx] != nil {
            let clonedIdx = idx(forKey: buffer.keys[bIdx]!, in: buffer)!
            let clonedKey: Key! = ((buffer.keys[bIdx] as? NSCopying)?.copy() as? Key) ?? buffer.keys[bIdx]
            let clonedValue: Value! = ((buffer.values[bIdx] as? NSCopying)?.copy() as? Value) ?? buffer.values[bIdx]
            clone.keys[clonedIdx] = clonedKey
            clone.values[clonedIdx] = clonedValue
        }
        clone.count = buffer.count
        clone.recomputeStartIndex()
        
        return clone
    }
    
}

// MARK: - C.R.U.D. methods
extension LPHTBuffer {
    func getValue(forKey k: Key) -> Value? {
        guard
            let idx = index(forKey: k)
        else { return nil }
        
        return values[idx]
    }
    
    func updateValue(_ newValue: Value, forKey k: Key) -> Value? {
        guard
            let idx = index(forKey: k)
        else { preconditionFailure("cannot add new elements when is full") }
        
        let oldValue = values[idx]
        defer {
            values[idx] = newValue
            if keys[idx] == nil {
                keys[idx] = k
                count += 1
                recomputeStartIndex()
            }
        }
        
        return oldValue
    }
    
    func setValue(_ v: Value, forKey k: Key, uniquingKeyWith combine: (Value, Value) throws -> Value) rethrows {
        guard
            let idx = index(forKey: k)
        else { preconditionFailure("cannot add new elements when is full") }
        
        guard let oldValue = values[idx] else {
            keys[idx] = k
            values[idx] = v
            count += 1
            if idx < startIndex {
                startIndex = idx
            }
            
            return
        }
        
        let combinedValue = try combine(oldValue, v)
        values[idx] = combinedValue
    }
    
    func removeElement(withKey k: Key) -> (key: Key, value: Value)? {
        guard
            let idx = index(forKey: k),
            keys[idx] != nil
        else { return nil }
        
        let oldElement = (keys[idx]!, values[idx]!)
        defer {
            let m = capacity + 1
            keys[idx] = nil
            values[idx] = nil
            var bIdx = (idx + 1) % m
            while keys[bIdx] != nil {
                let k = keys[bIdx]!
                let nIdx = index(forKey: k)!
                if nIdx == bIdx {
                    break
                }
                let v = values[bIdx]!
                keys[bIdx] = nil
                values[bIdx] = nil
                keys[nIdx] = k
                values[nIdx] = v
                bIdx = (bIdx + 1) % m
            }
            
            count -= 1
            if isEmpty {
                startIndex = m
            } else {
                recomputeStartIndex()
            }
        }
        
        return oldElement
    }
    
}

// MARK: - Sequence conformance
extension LPHTBuffer: Sequence {
    typealias Element = (key: Key, value: Value)
    
    struct Iterator: IteratorProtocol {
        var idx: Int
        
        let m: Int
        
        unowned(unsafe) var buffer: LPHTBuffer
        
        init(_ buffer: LPHTBuffer) {
            self.buffer = buffer
            self.idx = buffer.startIndex
            self.m = buffer.capacity + 1
        }
        
        mutating func next() -> Element? {
            guard
                idx < m
            else { return nil }
            
            defer {
                advanceIdxToNextElement()
            }
            
            return (buffer.keys[idx]!, buffer.values[idx]!)
        }
        
        private mutating func advanceIdxToNextElement() {
            idx += 1
            while idx < m {
                if buffer.keys[idx] != nil { break }
                idx += 1
            }
        }
        
    }
    
    var underestimatedCount: Int { count }
    
    func makeIterator() -> Iterator {
        withExtendedLifetime(self) { Iterator($0) }
    }
    
}

// MARK: - map and filter values operations
extension LPHTBuffer {
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LPHTBuffer<Key, T> {
        let mapped = LPHTBuffer<Key, T>.init(capacity: capacity)
        try forEach {
            let transformed = try transform($0.value)
            mapped.setValue(transformed, forKey: $0.key, uniquingKeyWith: { _, _ in
                return transformed
            })
        }
        
        return mapped
    }
    
    func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> LPHTBuffer<Key, T> {
        let cMapped = LPHTBuffer<Key, T>.init(capacity: capacity)
        try forEach { element in
            let transformed = try transform(element.value)
            transformed.map { t in
                cMapped.setValue(t, forKey: element.key, uniquingKeyWith: { _, _ in
                    return t
                })
            }
        }
        
        return cMapped
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LPHTBuffer {
        let filtered = LPHTBuffer.init(capacity: capacity)
        try forEach { element in
            guard try isIncluded(element) else { return }
            
            filtered.setValue(element.value, forKey: element.key, uniquingKeyWith: { _ ,_ in return element.value })
        }
        
        return filtered
    }
    
}

// MARK: - merge operations
extension LPHTBuffer {
    func merging<S: Sequence>(_ elements: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LPHTBuffer where S.Iterator.Element == Element {
        if let other = elements as? LPHTBuffer<Key, Value> {
            
            return try merging(other, uniquingKeysWith: combine)
        }
        var merged: LPHTBuffer!
        let done: Bool = try elements.withContiguousStorageIfAvailable({ b in
            guard
                b.baseAddress != nil && b.count > 0
            else {
                merged = self.clone()
                
                return true
            }
            let mergedCapacity = self.count + b.count
            merged = LPHTBuffer.clone(buffer: self, toNewCapacity: mergedCapacity)
            
            for elementToMerge in b {
                try merged.setValue(elementToMerge.value, forKey: elementToMerge.key, uniquingKeyWith: combine)
            }
            
            return true
        }) ?? false
        if !done {
            merged = clone()
            var elementsIter = elements.makeIterator()
            while let elementToMerge = elementsIter.next() {
                if merged.isFull {
                    let bigger = LPHTBuffer<Key, Value>.clone(buffer: merged, toNewCapacity: merged.capacity * 2)
                    merged = bigger
                }
                try merged.setValue(elementToMerge.value, forKey: elementToMerge.key, uniquingKeyWith: combine)
            }
        }
        
        return merged
    }
    
    func merging(_ other: LPHTBuffer, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LPHTBuffer {
        guard !other.isEmpty else { return clone() }
        
        guard !isEmpty else { return other.clone() }
        
        let mergedCapacity = count + other.count
        let merged = LPHTBuffer<Key, Value>.clone(buffer: self, toNewCapacity: mergedCapacity)
        for elementToMerge in other {
            try merged.setValue(elementToMerge.value, forKey: elementToMerge.key, uniquingKeyWith: combine)
        }
        
        return merged
    }
    
}

// MARK: - Helpers
extension LPHTBuffer {
    func recomputeStartIndex() {
        let m = capacity + 1
        var i = 0
        while i < m {
            if keys[i] != nil { break }
            
            i += 1
        }
        
        startIndex = i
    }
    
    func index(forKey k: Key) -> Int? {
        Self.idx(forKey: k, in: self)
    }
    
}

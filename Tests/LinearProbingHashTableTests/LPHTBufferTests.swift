//
//  LPHTBufferTests.swift
//  LinearProbingHashTableTests
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

import XCTest
@testable import LinearProbingHashTable

final class LPHTBufferTests: XCTestCase {
    var sut: LPHTBuffer<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = LPHTBuffer(capacity: 1)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitCapacity() {
        let capacity = Int.random(in: 1...10)
        let m = capacity + 1
        sut = LPHTBuffer(capacity: capacity)
        
        XCTAssertEqual(sut.capacity, capacity)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.startIndex, m)
        for i in 0..<m {
            XCTAssertNil(sut.keys[i])
            XCTAssertNil(sut.values[i])
        }
    }
    
    func testInitOther() {
        let capacity = Int.random(in: 1...10)
        let other = LPHTBuffer<String, Int>(capacity: capacity)
        for _ in 0..<capacity {
            other.updateValue(randomValue(), forKey: randomKey())
        }
        sut = LPHTBuffer(other: other)
        XCTAssertNotEqual(sut.keys, other.keys)
        XCTAssertNotEqual(sut.values, other.values)
        XCTAssertEqual(sut.capacity, other.capacity)
        XCTAssertEqual(sut.count, other.count)
        XCTAssertEqual(sut.startIndex, other.startIndex)
        for i in 0..<other.capacity + 1 {
            XCTAssertEqual(sut.keys[i], other.keys[i])
            XCTAssertEqual(sut.values[i], other.values[i])
        }
        
    }
    
    // MARK: - NSCopying tests
    func testCopyWhenKeyAndValueImplementsNSCopying() {
        let capacity = 10
        let source = LPHTBuffer<CKey, CValue>(capacity: capacity)
        for i in 0..<capacity {
            let k = CKey(randomKey(ofLenght: i + 1))
            let v = CValue(randomValue())
            source.updateValue(v, forKey: k)
        }
        
        let copy = source.copy() as? LPHTBuffer<CKey, CValue>
        XCTAssertNotNil(copy)
        XCTAssertEqual(copy?.capacity, source.capacity)
        XCTAssertEqual(copy?.count, source.count)
        XCTAssertEqual(copy?.startIndex, source.startIndex)
        XCTAssertNotEqual(copy?.keys, source.keys)
        XCTAssertNotEqual(copy?.values, source.values)
        for i in 0..<(capacity + 1) where source.keys[i] != nil {
            XCTAssertFalse(source.keys[i] === copy?.keys[i], "key copy was not deep")
            XCTAssertEqual(source.keys[i], copy?.keys[i])
            XCTAssertFalse(source.values[i] === copy?.values[i], "value copy was not deep")
            XCTAssertEqual(source.values[i], copy?.values[i])
        }
    }
    
    func testCopyWhenKeyAndValueHaveValueSemantics() {
        let capacity = 10
        let source = LPHTBuffer<SKey, SValue>(capacity: capacity)
        for i in 0..<capacity {
            let k = SKey(k: randomKey(ofLenght: i + 1))
            let v = SValue(v: randomValue())
            source.updateValue(v, forKey: k)
        }
        
        let copy = source.copy() as? LPHTBuffer<SKey, SValue>
        XCTAssertNotNil(copy)
        XCTAssertEqual(copy?.capacity, source.capacity)
        XCTAssertEqual(copy?.count, source.count)
        XCTAssertEqual(copy?.startIndex, source.startIndex)
        XCTAssertNotEqual(copy?.keys, source.keys)
        XCTAssertNotEqual(copy?.values, source.values)
        for i in 0..<(capacity + 1) {
            XCTAssertEqual(source.keys[i], copy?.keys[i])
            XCTAssertEqual(source.values[i], copy?.values[i])
        }
    }
    
    func testClone() {
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        for i in 0..<capacity {
            sut.updateValue(randomValue(), forKey: randomKey(ofLenght: i + 1))
        }
        
        let clone = sut.clone()
        XCTAssertEqual(clone.capacity, sut.capacity)
        XCTAssertEqual(clone.count, sut.count)
        XCTAssertEqual(clone.startIndex, sut.startIndex)
        XCTAssertNotEqual(clone.keys, sut.keys)
        XCTAssertNotEqual(clone.values, sut.values)
        for i in 0..<(capacity + 1) {
            XCTAssertEqual(sut.keys[i], clone.keys[i])
            XCTAssertEqual(sut.values[i], clone.values[i])
        }
    }
    
    // MARK: - clone(buffer:newCapacity:) test
    func testCloneBufferNewCapacity_whenNewCapacityIsLessThanBufferCapacity() {
        let oldCapacity = Int.random(in: 8..<64)
        sut = LPHTBuffer(capacity: oldCapacity)
        let keys = allCasesLetters.dropLast(allCasesLetters.count - (oldCapacity / 2))
        for k in keys {
            sut.updateValue(randomValue(), forKey: k)
        }
        XCTAssertLessThan(sut.count, sut.capacity)
        let clone = LPHTBuffer<String, Int>.clone(buffer: sut, newCapacity: sut.count)
        XCTAssertEqual(clone.count, sut.count)
        XCTAssertEqual(clone.capacity, sut.count)
        for k in keys {
            XCTAssertEqual(clone.getValue(forKey: k), sut.getValue(forKey: k))
        }
    }
    
    // MARK: - Computed properties tests
    func testIsEmpty() {
        XCTAssertEqual(sut.count, 0)
        XCTAssertTrue(sut.isEmpty)
        sut.updateValue(randomValue(), forKey: randomKey())
        XCTAssertGreaterThan(sut.count, 0)
        XCTAssertFalse(sut.isEmpty)
    }
    
    func testIsFull() {
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        for i in 0..<capacity {
            XCTAssertNotEqual(sut.capacity, sut.count)
            XCTAssertFalse(sut.isFull)
            sut.updateValue(randomValue(), forKey: randomKey(ofLenght: i + 1))
        }
        XCTAssertEqual(sut.count, sut.capacity)
        XCTAssertTrue(sut.isFull)
    }
    
    func testFreeCapacity() {
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        for i in 0..<capacity {
            XCTAssertEqual(sut.freeCapacity, sut.capacity - sut.count)
            sut.updateValue(randomValue(), forKey: randomKey(ofLenght: i + 1))
        }
        XCTAssertEqual(sut.freeCapacity, 0)
    }
    
    func testIsSparse() {
        let capacity = Int.random(in: 8...64)
        sut = LPHTBuffer(capacity: capacity)
        for i in 0..<capacity {
            if sut.freeCapacity > capacity / 8 {
                XCTAssertTrue(sut.isTooSparse)
            } else {
                XCTAssertFalse(sut.isTooSparse)
            }
            sut.updateValue(randomValue(), forKey: randomKey(ofLenght: i + 1))
        }
        XCTAssertFalse(sut.isTooSparse)
    }
    
}

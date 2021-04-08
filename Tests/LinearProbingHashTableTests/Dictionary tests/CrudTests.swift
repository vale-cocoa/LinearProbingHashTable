//
//  CrudTests.swift
//  LinearProbingHashTableTests
//
//  Created by Valeriano Della Longa on 2021/04/01.
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

final class CrudTests: BaseLPHTTests {
    func testGetValueForKey_returnsSameResultAsBuffersGetValueForKey() {
        let keys = givenKeysAndValuesWithoutDuplicateKeys().map({ $0.key })
        whenIsEmpty()
        for k in keys {
            XCTAssertEqual(sut.getValue(forKey: k), sut.buffer?.getValue(forKey: k))
        }
        
        whenContainsHalfElements()
        for k in keys {
            XCTAssertEqual(sut.getValue(forKey: k), sut.buffer?.getValue(forKey: k))
        }
        
        whenContainsAllElements()
        for k in keys {
            XCTAssertEqual(sut.getValue(forKey: k), sut.buffer?.getValue(forKey: k))
        }
    }
    
    func testUpdateValueForKey_whenDoesntContainElementWithKey_thenAddsNewElementWithKeyAndValueAndReturnsNil() {
        whenIsEmpty()
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        for (k, v) in elements {
            let prevCount = sut.count
            XCTAssertNil(sut.updateValue(v, forKey: k))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testUpdateValueForKey_whenContainsElementWithKey_thenUpdatesValueOfElementWithKeyAndReturnsOldValue() {
        whenContainsAllElements()
        for k in containedKeys {
            let expectedValue = sut.getValue(forKey: k)!
            let newValue = expectedValue + 10
            let prevCount = sut.count
            XCTAssertEqual(sut.updateValue(newValue, forKey: k), expectedValue)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
        }
    }
    
    func testUpdateValueForKey_CopyOnWrite() {
        whenIsEmpty()
        var k = randomKey()
        var newValue = randomValue()
        var copy = sut!
        var expectedCopyValue = sut.updateValue(newValue, forKey: k)
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertEqual(copy.getValue(forKey: k), expectedCopyValue)
        
        whenContainsHalfElements()
        copy = sut!
        k = randomKey()
        newValue = randomValue()
        expectedCopyValue = sut.updateValue(newValue, forKey: k)
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertEqual(copy.getValue(forKey: k), expectedCopyValue)
        
        whenContainsAllElements()
        copy = sut
        k = randomKey()
        newValue = randomValue()
        expectedCopyValue = sut.updateValue(newValue, forKey: k)
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertEqual(copy.getValue(forKey: k), expectedCopyValue)
    }
    
    func testRemoveValueForKey_whenDoesntContainElementWithKey_thenDoesNotRemoveAnyElementAndReturnsNil() {
        whenIsEmpty()
        for _ in 0...10 {
            XCTAssertNil(sut.removeValue(forKey: randomKey()))
            XCTAssertEqual(sut.count, 0)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for _ in 0...10 {
            XCTAssertNil(sut.removeValue(forKey: randomKey()))
            XCTAssertEqual(sut.count, 0)
        }
        
        whenContainsHalfElements()
        for k in notContainedKeys {
            let prevCount = sut.count
            XCTAssertNil(sut.removeValue(forKey: k))
            XCTAssertEqual(sut.count, prevCount)
        }
    }
    
    func testRemoveValueForKey_whenContainsElementWithKey_thenRemovesElementAndReturnsItsValue() {
        whenContainsAllElements()
        for k in containedKeys {
            let expectedValue = sut.getValue(forKey: k)
            let prevCount = sut.count
            XCTAssertEqual(sut.removeValue(forKey: k), expectedValue)
            XCTAssertEqual(sut.count, prevCount - 1)
        }
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testRemoveValueForKey_CopyOnWrite() {
        whenContainsHalfElements()
        for k in notContainedKeys {
            let previousBuffer = sut.buffer!
            sut.removeValue(forKey: k)
            XCTAssertFalse(sut.buffer === previousBuffer, "has not cloned buffer")
        }
        
        for k in containedKeys {
            let previousBuffer = sut.buffer
            sut.removeValue(forKey: k)
            XCTAssertFalse(sut.buffer === previousBuffer, "has not cloned buffer")
        }
    }
    
    func testRemoveValueForKey_whenIsEmptyAndBufferIsTooSparse_thenReducesBufferCapacity() {
        whenIsEmpty(withCapacity: 10)
        XCTAssertTrue(sut.buffer!.isTooSparse)
        let prevBuffer = sut.buffer!
        
        sut.removeValue(forKey: randomKey())
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
        XCTAssertLessThan(sut.capacity, prevBuffer.capacity)
    }
    
    func testRemoveValueForKey_whenIsNotEmptyAndBufferIsTooSparse_thenReducesBufferCapacity() {
        whenContainsHalfElements()
        sut.makeUniqueReserving(minimumCapacity: sut.count * 8)
        XCTAssertTrue(sut.buffer!.isTooSparse)
        
        weak var prevBuffer = sut.buffer!
        let prevCapacity = sut.capacity
        
        sut.removeValue(forKey: randomKey())
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
        XCTAssertLessThan(sut.capacity, prevCapacity)
    }
    
    func testRemoveValueForKey_whenIsNotEmptyAndBufferIsNotTooSparse_thenDoesntReduceBufferCapacity() {
        whenContainsHalfElements()
        weak var prevBuffer = sut.buffer
        var prevCapacity = sut.capacity
        
        for k in notContainedKeys {
            XCTAssertNil(sut.removeValue(forKey: k), "has removed value but was not supposed to")
            XCTAssertTrue(sut.buffer === prevBuffer)
            XCTAssertEqual(sut.capacity, prevCapacity)
        }
        
        let k = containedKeys.randomElement()!
        prevCapacity = sut.capacity
        prevBuffer = sut.buffer
        
        XCTAssertNotNil(sut.removeValue(forKey: k), "has not removed value but was supposed to")
        XCTAssertTrue(sut.buffer === prevBuffer)
        XCTAssertEqual(sut.capacity, prevCapacity)
    }
    
    func testRemoveAll_whenBufferIsNil_thenNothingChanges() {
        whenIsEmpty()
        
        sut.removeAll(keepingCapacity: true)
        XCTAssertNil(sut.buffer)
        
        sut.removeAll(keepingCapacity: false)
        XCTAssertNil(sut.buffer)
    }
    
    func testRemoveAll_whenBufferIsNotNilAndKeepCapacityIsTrue_CopyOnWrite() {
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        var prevBuffer = sut.buffer!
        
        sut.removeAll(keepingCapacity: true)
        XCTAssertTrue(sut.buffer === prevBuffer, "has cloned buffer")
        
        whenContainsHalfElements()
        prevBuffer = sut.buffer!
        
        sut.removeAll(keepingCapacity: true)
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer to empty one")
        
        whenContainsAllElements()
        prevBuffer = sut.buffer!
        
        sut.removeAll(keepingCapacity: true)
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer to empty one")
    }
    
    func testRemoveAll_whenBufferIsNotNilAndKeepCapacityIsFalse_CopyOnWrite() {
        whenContainsHalfElements()
        var prevBuffer = sut.buffer!
        
        sut.removeAll(keepingCapacity: false)
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
        XCTAssertEqual(sut.capacity, 0)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        prevBuffer = sut.buffer!
        
        sut.removeAll(keepingCapacity: false)
        XCTAssertNil(sut.buffer)
        XCTAssertEqual(sut.capacity, 0)
    }
    
    func testSubscriptKey_getter_returnsSameOfGetValueForKey() {
        whenIsEmpty()
        for _ in 0..<10 {
            let k = randomKey()
            XCTAssertEqual(sut[k], sut.getValue(forKey: k))
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for _ in 0..<10 {
            let k = randomKey()
            XCTAssertEqual(sut[k], sut.getValue(forKey: k))
        }
        
        whenContainsHalfElements()
        for k in containedKeys {
            XCTAssertEqual(sut[k], sut.getValue(forKey: k))
        }
        
        for k in notContainedKeys {
            XCTAssertEqual(sut[k], sut.getValue(forKey: k))
        }
    }
    
    // Subscript setter relies on updateValue(_:forKey:) and removeValue(forKey:)
    // methods, hence testing for copy on write is already done in tests for those methods
    func testSubscriptKey_setter_whenNewValueIsNotNil_thenUpdatesElementWithKeyToNewValueOrCreatesNewElementWithKeyAndNewValue() {
        whenContainsHalfElements()
        for k in containedKeys {
            let prevValue = sut[k]!
            let newValue = prevValue + 10
            sut[k] = newValue
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
        }
        
        for k in notContainedKeys {
            let newValue = randomValue()
            sut[k] = newValue
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
        }
    }
    
    func testSubscriptKey_setter_whenNewValueIsNil_thenEventuallyRemovesElementWithKey() {
        whenIsEmpty()
        for _ in 0..<10 {
            sut[randomKey()] = nil
            XCTAssertNil(sut.buffer)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for _ in 0..<10 {
            sut[randomKey()] = nil
            XCTAssertEqual(sut.count, 0)
        }
        
        whenContainsHalfElements()
        for k in notContainedKeys {
            let expectedElement = sut[k]
            let prevCount = sut.count
            sut[k] = nil
            XCTAssertEqual(sut[k], expectedElement)
            XCTAssertEqual(sut.count, prevCount)
        }
        for k in containedKeys {
            let prevCount = sut.count
            sut[k] = nil
            XCTAssertNil(sut[k])
            XCTAssertEqual(sut.count, prevCount - 1)
        }
    }
    
    func testSubscriptKeyDefault_getter_whenNoElementForKey_thenReturnsDefault() {
        let defaultValue = randomValue() + 100
        whenIsEmpty()
        for k in notContainedKeys {
            XCTAssertEqual(sut[k, default: defaultValue], defaultValue)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for k in notContainedKeys {
            XCTAssertEqual(sut[k, default: defaultValue], defaultValue)
        }
        
        whenContainsHalfElements()
        for k in notContainedKeys {
            XCTAssertEqual(sut[k, default: defaultValue], defaultValue)
        }
    }
    
    func testSubscriptKeyDefault_getter_whenElementWithKey_thenReturnsElementValue() {
        let defaultValue = randomValue() + 100
        whenContainsAllElements()
        for k in containedKeys {
            let result = sut[k, default: defaultValue]
            XCTAssertEqual(result, sut.getValue(forKey: k))
        }
    }
    
    func testSubscriptKeyDefault_modify_whenNoElementWithKey_thenAddNewElementWithDefaultValueForKeyAndYieldSuchValue() {
        let defaultValue = 1000
        whenIsEmpty()
        for k in givenKeysAndValuesWithoutDuplicateKeys().map({ $0.key }) {
            sut[k, default: defaultValue] += 100
            XCTAssertEqual(sut.getValue(forKey: k), defaultValue + 100)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for k in givenKeysAndValuesWithoutDuplicateKeys().map({ $0.key }) {
            sut[k, default: defaultValue] += 100
            XCTAssertEqual(sut.getValue(forKey: k), defaultValue + 100)
        }
        
        whenContainsHalfElements()
        for k in notContainedKeys {
            sut[k, default: defaultValue] += 100
            XCTAssertEqual(sut.getValue(forKey: k), defaultValue + 100)
        }
    }
    
    func testSubscriptKeyDefault_modify_whenElementWithKey_thenYieldItsValue() {
        let defaultValue = 1000
        whenContainsHalfElements()
        for k in containedKeys {
            let expectedResult = sut.getValue(forKey: k)! + 100
            sut[k, default: defaultValue] += 100
            XCTAssertEqual(sut.getValue(forKey: k), expectedResult)
        }
    }
    
    func testSubscriptKeyDefault_modify_CopyOnWrite() {
        whenIsEmpty()
        var copy = sut!
        weak var prevBuffer = copy.buffer
        
        sut[randomKey(), default: 1000] += 100
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertTrue(copy.buffer === prevBuffer, "has changed copy's buffer")
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        copy = sut!
        prevBuffer = copy.buffer
        
        sut[randomKey(), default: 1000] += 100
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertTrue(copy.buffer === prevBuffer, "has changed copy's buffer")
        
        whenContainsHalfElements()
        copy = sut!
        prevBuffer = copy.buffer
        
        sut[randomKey(), default: 1000] += 100
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
        XCTAssertTrue(copy.buffer === prevBuffer, "has changed copy's buffer")
    }
    
    func testReserveCapacity_whenBufferIsNil_thenInstanciatesNewBufferWithCapacityGreaterThanOrEqualToMinimumCapacity() {
        for minCapacity in 0...10 {
            whenIsEmpty()
            sut.reserveCapacity(minCapacity)
            XCTAssertNotNil(sut.buffer)
            XCTAssertGreaterThanOrEqual(sut.capacity, minCapacity)
        }
    }
    
    func testReserveCapacity_whenBufferIsNotNilAndMinimumCapacityIsLessThanOrEqualToBufferFreeCapacity_thenBufferStaysTheSame() throws {
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for minCapacity in 1...sut.buffer!.freeCapacity {
            weak var prevBuffer = sut.buffer
            sut.reserveCapacity(minCapacity)
            XCTAssertTrue(sut.buffer === prevBuffer)
        }
        
        whenContainsHalfElements()
        try XCTSkipIf(sut.buffer!.freeCapacity == 0)
        for minCapacity in 1...sut.buffer!.freeCapacity {
            weak var prevBuffer = sut.buffer
            sut.reserveCapacity(minCapacity)
            XCTAssertTrue(sut.buffer === prevBuffer)
        }
    }
    
    func testReserveCapacity_whenBufferIsNotNilAndMinimumCapacityIsGreaterThanOrEqualToBufferFreeCapacity_thenClonesBufferToOneWithFreeCapacityGreaterThanOrEqualToMinCapacity() {
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        var minCapacity = sut.buffer!.freeCapacity + Int.random(in: 1...10)
        var prevBuffer = sut.buffer!
        
        sut.reserveCapacity(minCapacity)
        XCTAssertFalse(sut.buffer === prevBuffer)
        XCTAssertGreaterThanOrEqual(sut.buffer!.freeCapacity, minCapacity)
        XCTAssertEqual(sut.count, prevBuffer.count)
        for (k, v) in prevBuffer {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        whenContainsHalfElements()
        minCapacity = sut.buffer!.freeCapacity + Int.random(in: 1...10)
        prevBuffer = sut.buffer!
        sut.reserveCapacity(minCapacity)
        XCTAssertFalse(sut.buffer === prevBuffer)
        XCTAssertGreaterThanOrEqual(sut.buffer!.freeCapacity, minCapacity)
        XCTAssertEqual(sut.count, prevBuffer.count)
        for (k, v) in prevBuffer {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
}

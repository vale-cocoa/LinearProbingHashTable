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
        assertStartIndexIsCorrect(on: sut)
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
        assertStartIndexIsCorrect(on: sut)
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
        if copy != nil {
            assertStartIndexIsCorrect(on: copy!)
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
        if copy != nil {
            assertStartIndexIsCorrect(on: copy!)
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
        assertStartIndexIsCorrect(on: clone)
    }
    
    func testCloneNewCapacity_whenNewCapacityIsLessThanBufferCapacity() {
        let oldCapacity = Int.random(in: 8..<64)
        sut = LPHTBuffer(capacity: oldCapacity)
        let keys = allCasesLetters.dropLast(allCasesLetters.count - (oldCapacity / 2))
        for k in keys {
            sut.updateValue(randomValue(), forKey: k)
        }
        XCTAssertLessThan(sut.count, sut.capacity)
        let clone = sut.clone(newCapacity: sut.count)
        XCTAssertEqual(clone.count, sut.count)
        XCTAssertEqual(clone.capacity, sut.count)
        for k in keys {
            XCTAssertEqual(clone.getValue(forKey: k), sut.getValue(forKey: k))
        }
        assertStartIndexIsCorrect(on: clone)
    }
    
    func testCloneNewCapacity_whenNewCapacityIsEqualToBufferCapacity() {
        let oldCapacity = Int.random(in: 8..<64)
        sut = LPHTBuffer(capacity: oldCapacity)
        let keys = allCasesLetters.dropLast(allCasesLetters.count - (oldCapacity / 2))
        for k in keys {
            sut.updateValue(randomValue(), forKey: k)
        }
        let clone = sut.clone(newCapacity: oldCapacity)
        XCTAssertEqual(clone.count, sut.count)
        XCTAssertEqual(clone.capacity, oldCapacity)
        for k in keys {
            XCTAssertEqual(clone.getValue(forKey: k), sut.getValue(forKey: k))
        }
        assertStartIndexIsCorrect(on: clone)
    }
    
    func testCloneNewCapacity_whenNewCapacityIsGreaterThanBufferCapacity() {
        let oldCapacity = Int.random(in: 8..<64)
        sut = LPHTBuffer(capacity: oldCapacity)
        let keys = allCasesLetters.dropLast(allCasesLetters.count - (oldCapacity / 2))
        for k in keys {
            sut.updateValue(randomValue(), forKey: k)
        }
        let newCapacity = oldCapacity * Int.random(in: 2...8)
        let clone = sut.clone(newCapacity: newCapacity)
        XCTAssertEqual(clone.count, sut.count)
        XCTAssertEqual(clone.capacity, newCapacity)
        for k in keys {
            XCTAssertEqual(clone.getValue(forKey: k), sut.getValue(forKey: k))
        }
        assertStartIndexIsCorrect(on: clone)
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
    
    // MARK: - C.R.U.D. methods tests
    func testGetValueForKey_whenIsEmpty_thenReturnsNil() {
        let capacity = Int.random(in: 8...64)
        sut = LPHTBuffer(capacity: capacity)
        
        for (k, _) in givenKeysAndValuesWithoutDuplicateKeys() {
            XCTAssertNil(sut.getValue(forKey: k))
        }
    }
    
    func testGetValueForKey_whenIsNotEmpty_thenReturnsValueForKeyAccordingly() {
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count / 2
        sut = LPHTBuffer(capacity: capacity)
        let storedElements = allElements[0..<capacity]
        for (k, v) in storedElements {
            sut.updateValue(v, forKey: k)
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        let notStoredElements = allElements[capacity..<allElements.endIndex]
        for (k, _) in notStoredElements {
            XCTAssertNil(sut.getValue(forKey: k))
        }
    }
    
    func testUpdateValueForKey_whenNoElementWithKey_thenStoresNewElementAndReturnsNil() {
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in allElements {
            let prevCount = sut.count
            XCTAssertNil(sut.updateValue(v, forKey: k))
            XCTAssertEqual(sut.getValue(forKey: k), v)
            XCTAssertEqual(sut.count, prevCount + 1)
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    func testUpdateValueForKey_whenElementWithKey_thenUpdatesElementToNewValueAndReturnsOldValue() {
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in allElements {
            sut.updateValue(v, forKey: k)
            let newValue = v + 100
            let prevCount = sut.count
            let oldValue = sut.updateValue(newValue, forKey: k)
            XCTAssertEqual(oldValue, v)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    func testSetValueForKeyUniquingKeyWith_whenNoElementWithKey_thenCombineNeverExcutesAndAddsNewElement() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in allElements {
            let prevCount = sut.count
            sut.setValue(v, forKey: k, uniquingKeyWith: combine)
            XCTAssertFalse(hasExecuted)
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.getValue(forKey: k), v)
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    func testSetValueForKeyUniquingKeyWith_whenElementWithKey_thenCombineExecutesAndUpdatesValueOnElementToCombineResult() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { p, n in
            hasExecuted = true
            
            return p - n
        }
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in allElements {
            sut.updateValue(v, forKey: k)
            let newValue = v + 100
            let expectedValue = combine(v, newValue)
            let prevCount = sut.count
            hasExecuted = false
            sut.setValue(newValue, forKey: k, uniquingKeyWith: combine)
            XCTAssertTrue(hasExecuted)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.getValue(forKey: k), expectedValue)
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    func testSetValueForKeyUniquingKeyWith_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in  throw err }
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in allElements {
            sut.updateValue(v, forKey: k)
            do {
                try sut.setValue(0, forKey: k, uniquingKeyWith: combine)
                XCTFail("combine has not thrown")
            } catch {
                XCTAssertEqual(error as NSError, err)
            }
        }
    }
    
    func testRemoveElementWithKey_whenIsEmpty_thenAlwaysReturnsNil() {
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, _) in allElements {
            XCTAssertNil(sut.removeElement(withKey: k))
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    func testRemoveElementWithKey_whenIsNotEmpty_thenRemovesAndReturnsAccordingly() {
        let allElements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = allElements.count / 2
        sut = LPHTBuffer(capacity: capacity)
        let containedElements = allElements[0..<capacity]
        let notContainedElements = allElements[capacity..<allElements.endIndex]
        for (k, v) in containedElements {
            sut.updateValue(v, forKey: k)
        }
        
        for (k, _) in notContainedElements {
            let prevCount = sut.count
            XCTAssertNil(sut.removeElement(withKey: k))
            XCTAssertEqual(sut.count, prevCount)
            assertStartIndexIsCorrect(on: sut)
        }
        
        for (k, v) in containedElements {
            let prevCount = sut.count
            let removedElement = sut.removeElement(withKey: k)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertEqual(removedElement?.key, k)
            XCTAssertEqual(removedElement?.value, v)
            XCTAssertNil(sut.getValue(forKey: k))
            assertStartIndexIsCorrect(on: sut)
        }
    }
    
    // MARK: - Sequence conformance tests
    func testUnderestimatedCount() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
            XCTAssertEqual(sut.underestimatedCount, sut.count)
        }
    }
    
    func testMakeIterator() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        var iter = sut.makeIterator()
        XCTAssertTrue(iter.buffer === sut, "set a different buffer instance on iterator")
        XCTAssertEqual(iter.m, sut.capacity + 1)
        XCTAssertEqual(iter.idx, sut.startIndex)
        
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        iter = sut.makeIterator()
        XCTAssertTrue(iter.buffer === sut, "set a different buffer instance on iterator")
        XCTAssertEqual(iter.m, sut.capacity + 1)
        XCTAssertEqual(iter.idx, sut.startIndex)
    }
    
    func testIteratorNext() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        var iter = sut.makeIterator()
        XCTAssertNil(iter.next())
        
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        iter = sut.makeIterator()
        var iteratedKeys = Set<String>()
        while let (k, v) = iter.next() {
            XCTAssertTrue(iteratedKeys.insert(k).inserted, "key: \(keyKey) was already iterated")
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        XCTAssertNil(iter.next())
        XCTAssertEqual(iteratedKeys.count, sut.count)
    }
    
    // MARK: - mapValues(_:) tests
    func testMapValues_whenIsEmpty_thenTransformNeverExecutesAndReturnsEmptyBuffer() {
        var hasExecuted = false
        let transform: (Int) -> String = { _ in
            hasExecuted = true
            
            return ""
        }
        
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        let result = sut.mapValues(transform)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testMapValues_whenIsNotEmpty_thenTransformExecutesForEveryElementAndReturnsBufferWithMappedValues() {
        var countOfExecutions = 0
        let transform: (Int) -> String = {
            countOfExecutions += 1
            
            return "\($0)"
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        
        let result = sut.mapValues(transform)
        XCTAssertEqual(countOfExecutions, sut.count)
        assertStartIndexIsCorrect(on: result)
        for (k, v) in sut {
            let expectedValue = "\(v)"
            XCTAssertEqual(result.getValue(forKey: k), expectedValue)
        }
    }
    
    func testMapValues_whenTransformThrows_thenRethrows() {
        let transform: (Int) throws -> String = { _ in throw err }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        do {
            let _ = try sut.mapValues(transform)
            XCTFail("mapValues has not thrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - compactMapValues(_:) tests
    func testCompactMapValues_whenIsEmpty_thenTransformNeverExecutes() {
        var hasExecuted = false
        let transform: (Int) -> String? = { _ in
            hasExecuted = true
            
            return ""
        }
        
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        let result = sut.compactMapValues(transform)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testCompactMapValues_whenIsNotEmpty_thenTransformExecutesForEveryElementAndReturnsBufferWithCompactMappedValues() {
        var countOfExecutions = 0
        let transform: (Int) -> String? = {
            countOfExecutions += 1
            
            return $0 % 2 == 0 ? "\($0)" : nil
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        
        let result = sut.compactMapValues(transform)
        XCTAssertEqual(countOfExecutions, sut.count)
        assertStartIndexIsCorrect(on: result)
        for (k, v) in sut {
            let expectedValue = transform(v)
            XCTAssertEqual(result.getValue(forKey: k), expectedValue)
        }
    }
    
    func testCompactMapValues_whenTransformThrows_thenRethrows() {
        let transform: (Int) throws -> String? = { _ in throw err }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        do {
            let _ = try sut.compactMapValues(transform)
            XCTFail("compactMapValues has not thrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - filter(_:) -> LPHTBuffer tests
    func testFilter_whenIsEmpty_thenPredicateNeverExecutes() {
        var hasExecuted = false
        let predicate: ((key: String, value: Int)) -> Bool = { _ in
            hasExecuted = true
            
            return true
        }
        
        let capacity = Int.random(in: 1...10)
        sut = LPHTBuffer(capacity: capacity)
        let result = sut.filter(predicate)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFilter_whenIsNotEmpty_thenPredicateExecutesForEveryElementAndReturnsFilteredBuffer() {
        var countOfExecutions = 0
        let predicate: ((key: String, value: Int)) -> Bool = {
            countOfExecutions += 1
            
            return $0.value % 2 == 0
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        
        let result = sut.filter(predicate)
        XCTAssertEqual(countOfExecutions, sut.count)
        assertStartIndexIsCorrect(on: result)
        for (k, v) in sut {
            let expectedValue = v % 2 == 0 ? v : nil
            XCTAssertEqual(result.getValue(forKey: k), expectedValue)
        }
    }
    
    func testFilter_whenPredicateThrows_thenRethrows() {
        let predicate: ((key: String, value: Int)) throws -> Bool = { _ in throw err }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let capacity = elements.count
        sut = LPHTBuffer(capacity: capacity)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        do {
            let _ = try sut.filter(predicate)
            XCTFail("filter has not thrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - merging<S>(_:, uniquingKeysWith:) tests
    func testMergingSequence_whenIsEmptyAndSequenceIsEmpty_thenCombineNeverExecutesAndReturnsEmptyBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        
        sut = LPHTBuffer(capacity: Int.random(in: 1...10))
        var result = sut.merging([(String, Int)](), uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>([(String, Int)]())
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenIsEmptyAndSequenceDoesntContainDuplicateKeys_thenCombineNeverExecutesAndReturnsBufferWithSequenceElments() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: Int.random(in: 1...10))
        var result = sut.merging(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        for (k, v) in elements {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        for (k, v) in elements {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenIsEmptyAndSequenceContainsDuplicateKeys_thenCombineExecutesAndReturnsBufferWithSequenceElmentsCombinedAccordingly() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = {
            hasExecuted = true
            
            return $0 + $1
        }
        
        let elements = givenKeysAndValuesWithDuplicateKeys()
        let expectedResult = Dictionary(elements, uniquingKeysWith: combine)
        hasExecuted = false
        sut = LPHTBuffer(capacity: Int.random(in: 1...10))
        var result = sut.merging(elements, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenIsNotEmptyAndSequenceIsEmpty_thenCombineNeverExecutesAndReturnsClone() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        let other = [(String, Int)]()
        var result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertFalse(result === sut, "has returned same instance")
        for (k, v) in sut {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq(other)
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertFalse(result === sut, "has returned same instance")
        for (k, v) in sut {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenIsNotEmptyAndSequenceIsNotEmptyAndNoDuplicateKeys_thenCombineNeverExecutesAndReturnsMergedBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let sutCapacity = elements.count / 2
        let sutElements = Array(elements[0..<sutCapacity])
        sut = LPHTBuffer(capacity: sutCapacity)
        for (k, v) in sutElements {
            sut.updateValue(v, forKey: k)
        }
        let otherElements = Array(elements[sutCapacity..<elements.endIndex])
        var result = sut.merging(otherElements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        for (k, v) in elements {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(otherElements)
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        for (k, v) in elements {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenIsNotEmptyAndSequenceIsNotEmptyAndDuplicateKeys_thenCombinExecutesAndReturnsMergedBufferWithCombinedElements() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = {
            hasExecuted = true
            
            return $0 + $1
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        let otherElements = givenKeysAndValuesWithDuplicateKeys()
        var expectedResult = Dictionary(uniqueKeysWithValues: elements)
        expectedResult.merge(otherElements, uniquingKeysWith: combine)
        hasExecuted = false
        
        var result = sut.merging(otherElements, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        XCTAssertEqual(result.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
        
        // same test with sequence not implmenting withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(otherElements)
        hasExecuted = false
        result = sut.merging(seq, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        XCTAssertEqual(result.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingSequence_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count)
        for (k, v) in elements {
            sut.updateValue(v, forKey: k)
        }
        let otherElements = givenKeysAndValuesWithDuplicateKeys()
        do {
            let _ = try sut.merging(otherElements, uniquingKeysWith: combine)
            XCTFail("merging has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - merging(_:, uniquingKeysWith:) tests
    func testMergingOther_whenIsEmptyAndOtherIsEmpty_thenCombineNeverExecutesAndReturnsEmptyBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        
        sut = LPHTBuffer(capacity: Int.random(in: 1...10))
        let other = LPHTBuffer<String, Int>(capacity: Int.random(in: 10...20))
        let result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(result.isEmpty)
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingOther_whenIsEmptyAndOtherIsNotEmpty_thenCombineNeverExecutesAndReturnsCloneOfOther() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        sut = LPHTBuffer(capacity: Int.random(in: 1...10))
        let otherElements = givenKeysAndValuesWithoutDuplicateKeys()
        let other = LPHTBuffer<String, Int>(capacity: otherElements.count)
        for (k, v) in otherElements {
            other.updateValue(v, forKey: k)
        }
        let result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertFalse(result === other, "has returned same instance of other")
        XCTAssertEqual(result.count, other.count)
        for (k, v) in other {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingOther_whenIsNotEmptyAndOtherIsEmpty_thenCombineNeverExecutesAndReturnsCloneOfBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let other = LPHTBuffer<String, Int>(capacity: Int.random(in: 1...10))
        let sutElements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: sutElements.count)
        for (k, v) in sutElements {
            sut.updateValue(v, forKey: k)
        }
        let result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertFalse(result === sut, "has returned same instance of sut")
        XCTAssertEqual(result.count, sut.count)
        for (k, v) in sut {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingOther_whenBothArentEmptyAndHaveNoCommonKeys_thenCombineNeverExecutesAndReturnsMergedBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let sutElements = Array(elements[0..<(elements.count / 2)])
        let otherElements = Array(elements[(elements.count / 2)..<elements.endIndex])
        sut = LPHTBuffer(capacity: sutElements.count)
        for (k, v) in sutElements { sut.updateValue(v, forKey: k) }
        let other = LPHTBuffer<String, Int>(capacity: otherElements.count)
        for (k, v) in otherElements { other.updateValue(v, forKey: k) }
        
        hasExecuted = false
        let result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertEqual(result.count, elements.count)
        for (k, v) in elements {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingOther_whenBothArentEmptyAndHaveCommonKeys_thenCombineExecutesAndReturnsMergedBufferWithCombinedElements() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = {
            hasExecuted = true
            
            return $0 + $1
        }
        
        let sutElements = givenKeysAndValuesWithoutDuplicateKeys()
        let otherElements = sutElements[0..<(sutElements.count / 2)].map { ($0.key, $0.value - 10) }
        var expectedResult = Dictionary(uniqueKeysWithValues: sutElements)
        expectedResult.merge(otherElements, uniquingKeysWith: combine)
        sut = LPHTBuffer(capacity: sutElements.count)
        for (k, v) in sutElements { sut.updateValue(v, forKey: k) }
        let other = LPHTBuffer<String, Int>(capacity: otherElements.count)
        for (k, v) in otherElements { other.updateValue(v, forKey: k) }
        
        hasExecuted = false
        let result = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        XCTAssertEqual(result.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        assertStartIndexIsCorrect(on: result)
    }
    
    func testMergingOther_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        
        let sutElements = givenKeysAndValuesWithoutDuplicateKeys()
        let otherElements = sutElements[0..<(sutElements.count / 2)].map { ($0.key, $0.value - 10) }
        sut = LPHTBuffer(capacity: sutElements.count)
        for (k, v) in sutElements { sut.updateValue(v, forKey: k) }
        let other = LPHTBuffer<String, Int>(capacity: otherElements.count)
        for (k, v) in otherElements { other.updateValue(v, forKey: k) }
        do {
            let _ = try sut.merging(other, uniquingKeysWith: combine)
            XCTFail("merging has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    // MARK: - test index(forKey:)
    // Note range is 0..<(sut.capacity + 1)
    func testIndexForKey() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        
        let capacity = Int.random(in: 1..<(elements.count / 2))
        let range = 0..<(capacity + 1)
        sut = LPHTBuffer(capacity: capacity)
        for (k, _) in elements {
            let idx = sut.index(forKey: k)
            if range.contains(idx) {
                XCTAssertNil(sut.keys[idx])
                XCTAssertNil(sut.values[idx])
            } else {
                XCTFail("returned out of range index: \(idx)")
            }
        }
        
        for (k, v) in elements {
            if !sut.isFull {
                sut.updateValue(v, forKey: k)
                let idx = sut.index(forKey: k)
                if range.contains(idx) {
                    XCTAssertEqual(sut.keys[idx], k)
                    XCTAssertEqual(sut.values[idx], v)
                } else {
                    XCTFail("returned out of range index: \(idx)")
                }
            } else {
                let idx = sut.index(forKey: k)
                if range.contains(idx) {
                    XCTAssertNil(sut.keys[idx])
                    XCTAssertNil(sut.values[idx])
                } else {
                    XCTFail("returned out of range index: \(idx)")
                }
            }
        }
    }
    
    func testIndexForKey_ratioOfCollisions_withVeryBadHashingKeys_whenHalfCapacityTaken() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys().map { (VeryBadHashingKey(k: $0.key), $0.value) }
        let buffer = LPHTBuffer<VeryBadHashingKey, Int>(capacity: elements.count * 2)
        for (k, v) in elements.shuffled() {
            buffer.updateValue(v, forKey: k)
        }
        let ratioOfCollisions = buffer.keyCollisionsRatio(onKeys: elements.map({$0.0}))
        XCTAssertGreaterThan(ratioOfCollisions, 0.85)
    }
    
    func testIndexForKey_ratioOfCollisions_withBadHashingKeys_whenHalfCapacityTaken() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys().map { (BadHashingKey(k: $0.key), $0.value) }
        let buffer = LPHTBuffer<BadHashingKey, Int>(capacity: elements.count * 2)
        for (k, v) in elements.shuffled() {
            buffer.updateValue(v, forKey: k)
        }
        let ratioOfCollisions = buffer.keyCollisionsRatio(onKeys: elements.map({$0.0}))
        XCTAssertGreaterThan(ratioOfCollisions, 0.65)
    }
    
    func testIndexForKey_ratioOfCollisions_withSomeWhatBadHashingKeys_whenHalfCapacityTaken() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys().map { (SomeWhatBadHashingKey(k: $0.key), $0.value) }
        let buffer = LPHTBuffer<SomeWhatBadHashingKey, Int>(capacity: elements.count * 2)
        for (k, v) in elements.shuffled() {
            buffer.updateValue(v, forKey: k)
        }
        let ratioOfCollisions = buffer.keyCollisionsRatio(onKeys: elements.map({$0.0}))
        XCTAssertGreaterThan(ratioOfCollisions, 0.45)
    }
    
    func testIndexForKey_ratioOfCollisions_withStringKey_whenHalfCapacityTaken() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LPHTBuffer(capacity: elements.count * 2)
        for (k, v) in elements.shuffled() {
            sut.updateValue(v, forKey: k)
        }
        let ratioOfCollisions = sut.keyCollisionsRatio(onKeys: elements.map({$0.0}))
        XCTAssertLessThan(ratioOfCollisions, 0.45)
    }
    
}


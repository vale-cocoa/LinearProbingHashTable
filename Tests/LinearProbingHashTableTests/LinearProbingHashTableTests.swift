//
//  LinearProbingHashTableTests.swift
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

class BaseLPHTTests: XCTestCase {
    let minimumBufferCapacity = LinearProbingHashTable<String, Int>.minimumBufferCapacity
    
    var sut: LinearProbingHashTable<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        whenIsEmpty()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    var containedElements: Array<(String, Int)> {
        sut.buffer?.map { $0 } ?? []
    }
    
    var containedKeys: Set<String> {
        
        return Set(sut.buffer?.map({$0.key}) ?? [])
    }
    
    var notContainedKeys: Set<String> {
        guard !sut.isEmpty else { return Set() }
        
        let allKeys = givenKeysAndValuesWithoutDuplicateKeys().map({ $0.key })
        
        return Set(allKeys.filter({ self.sut.buffer?.getValue(forKey: $0) == nil }))
    }
    
    // MARK: - When
    func whenIsEmpty(withCapacity k: Int = 0) {
        guard k > 0 else {
            sut = LinearProbingHashTable()
            
            return
        }
        
        sut = LinearProbingHashTable(minimumCapacity: k)
    }
    
    func whenContainsHalfElements() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let halfCount = elements.count / 2
        let buffer = LPHTBuffer<String, Int>(capacity: elements.capacity)
        for (k, v) in elements.shuffled()[0..<halfCount] {
            buffer.updateValue(v, forKey: k)
        }
        sut = LinearProbingHashTable(buffer: buffer)
    }
    
    func whenContainsAllElements() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let buffer = LPHTBuffer<String, Int>(capacity: elements.capacity)
        for (k, v) in elements.shuffled() {
            buffer.updateValue(v, forKey: k)
        }
        
        sut = LinearProbingHashTable(buffer: buffer)
    }
    
    // MARK: - Base initializers tests.
    // These tests also guarantee that the "when" are valid.
    func testInit() {
        sut = LinearProbingHashTable()
        XCTAssertNil(sut.buffer)
        XCTAssertNotNil(sut.id)
    }
    
    func testInitMinimumCapacity() {
        let minimumCapacity = Int.random(in: 1..<100)
        sut = LinearProbingHashTable(minimumCapacity: minimumCapacity)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        if sut.buffer != nil {
            XCTAssertGreaterThanOrEqual(sut.buffer!.capacity, minimumCapacity)
        }
    }
    
    func testInitBuffer() {
        var buffer: LPHTBuffer<String, Int>? = nil
        
        sut = LinearProbingHashTable(buffer: buffer)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
        
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        buffer = LPHTBuffer(capacity: elements.capacity)
        for (k, v) in elements { buffer!.updateValue(v, forKey: k) }
        
        sut = LinearProbingHashTable(buffer: buffer)
        XCTAssertNotNil(sut.id)
        XCTAssertTrue(sut.buffer === buffer, "has not the same buffer instance")
    }
    
}

final class LinearProbingHashTableTests: BaseLPHTTests {
    func testCapacity() {
        whenIsEmpty()
        XCTAssertEqual(sut.capacity, 0)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertEqual(sut.capacity, sut.buffer?.capacity)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.capacity, sut.buffer?.capacity)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.capacity, sut.buffer?.capacity)
    }
    
    func testCount() {
        whenIsEmpty()
        XCTAssertEqual(sut.count, 0)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.count, sut.buffer!.count)
        while let k = containedKeys.randomElement() {
            sut.buffer!.removeElement(withKey: k)
            XCTAssertEqual(sut.count, sut.buffer?.count)
        }
    }
    
    func testIsEmpty() {
        whenIsEmpty()
        XCTAssertTrue(sut.isEmpty)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertTrue(sut.isEmpty)
        
        whenContainsHalfElements()
        XCTAssertFalse(sut.isEmpty)
        
        whenContainsAllElements()
        XCTAssertFalse(sut.isEmpty)
        while let k = containedKeys.randomElement() {
            sut.buffer?.removeElement(withKey: k)
            XCTAssertEqual(sut.isEmpty, sut.buffer?.isEmpty)
        }
    }
    
    func testInvalidatePreviouslyStoredIndices() {
        weak var prevID = sut.id
        sut.invalidatePreviouslyStoredIndices()
        XCTAssertFalse(sut.id === prevID, "has not changed id reference")
        
        let idx = sut.startIndex
        sut.invalidatePreviouslyStoredIndices()
        XCTAssertFalse(idx.isValidFor(sut), "previously stored index is still valid")
    }
    
    // MARK: - makeUnique() tests
    func testMakeUnique_whenBufferIsNil_thenChangesIDAndInstanciateANewBufferWithMinimumCapacity() {
        whenIsEmpty()
        weak var prevID = sut.id
        
        sut.makeUnique()
        XCTAssertFalse(sut.id === prevID, "has not changed id reference")
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.buffer?.capacity, minimumBufferCapacity)
    }
    
    func testMakeUnique_whenBufferIsNotNilAndUniquelyReferenced_thenDoesNothing() {
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        weak var prevID = sut.id
        weak var prevBuffer = sut.buffer
        
        sut.makeUnique()
        XCTAssertTrue(sut.id === prevID, "has changed id reference")
        XCTAssertTrue(sut.buffer === prevBuffer, "has changed buffer reference")
        
        whenContainsAllElements()
        prevID = sut.id
        prevBuffer = sut.buffer
        
        sut.makeUnique()
        XCTAssertTrue(sut.id === prevID, "has changed id reference")
        XCTAssertTrue(sut.buffer === prevBuffer, "has changed buffer reference")
    }
    
    func testMakeUnique_whenBufferIsNotNilAndNotUniquelyReferenced_thenClonesBufferAndDoesntChangeID() {
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        weak var prevID = sut.id
        var otherBufferStrongReference = sut.buffer
        
        sut.makeUnique()
        XCTAssertTrue(sut.id === prevID, "has changed id reference")
        XCTAssertFalse(sut.buffer === otherBufferStrongReference, "has not cloned buffer")
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.buffer?.isEmpty, otherBufferStrongReference?.isEmpty)
        
        whenContainsAllElements()
        prevID = sut.id
        otherBufferStrongReference = sut.buffer
        
        sut.makeUnique()
        XCTAssertTrue(sut.id === prevID, "has changed id reference")
        XCTAssertFalse(sut.buffer === otherBufferStrongReference, "has not cloned buffer")
        XCTAssertNotNil(sut.buffer)
        // Correct cloning of elements check is done in buffer's tests
    }
    
    // MARK: - makeUniqueReserving(minimumCapacity:) tests
    func testMakeUniqueReservingMinimumCapacity_whenBufferIsNil_thenInstanciateNewBufferWithCapacityGreaterThanOrEqualToMinimumCapacityAndChangesId() {
        for minCapaity in 0..<10 {
            whenIsEmpty()
            weak var prevID = sut.id
            
            sut.makeUniqueReserving(minimumCapacity: minCapaity)
            XCTAssertFalse(sut.id === prevID, "has not changed id")
            XCTAssertNotNil(sut.buffer)
            XCTAssertGreaterThanOrEqual(sut.capacity, minCapaity)
        }
    }
    
    func testMakeUniqueReservingMinimumCapacity_whenBufferIsNotNilAndUniquelyReferencedAndMinCapacityIsLessThanOrEqualToBufferFreeCapacity_thenNothingChanges() {
        whenContainsAllElements()
        for minCapacity in 0...sut.buffer!.freeCapacity {
            weak var prevID = sut.id
            weak var prevBuffer = sut.buffer
            
            sut.makeUniqueReserving(minimumCapacity: minCapacity)
            XCTAssertTrue(sut.id === prevID, "has changed id")
            XCTAssertTrue(sut.buffer === prevBuffer, "has changed buffer")
            XCTAssertNotNil(sut.buffer)
            // Correct cloning of elements check is done in buffer's tests
        }
    }
    
    func testMakeUniqueReservingMinimumCapacity_whenBufferIsNotNilAndNotUniquelyReferencedAndMinCapacityIsLessThanOrEqualToBufferFreeCapacity_thenClonesBufferAndDoesntChangeId() {
        whenContainsAllElements()
        for minCapacity in 0...sut.buffer!.freeCapacity {
            weak var prevID = sut.id
            let otherBufferStrongReference = sut.buffer
            
            sut.makeUniqueReserving(minimumCapacity: minCapacity)
            XCTAssertTrue(sut.id === prevID, "has changed id")
            XCTAssertFalse(sut.buffer === otherBufferStrongReference, "has not cloned buffer")
            // Correct cloning of elements check is done in buffer's tests
        }
    }
    
    func testMakeUniqueReservingCapacity_whenBufferIsNotNilAndMinCapacityIsGreaterThanBufferFreeCapacity_thenClonesBufferToOneWithLargerCapacityAndChangesId() {
        whenContainsAllElements()
        let lBound = sut.buffer!.capacity + 1
        let uBound = lBound * 2
        for minCapacity in lBound..<uBound {
            weak var prevID = sut.id
            let prevBuffer = sut.buffer
            
            sut.makeUniqueReserving(minimumCapacity: minCapacity)
            XCTAssertFalse(sut.id === prevID, "has not changed id reference")
            XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
            if sut.buffer != nil && prevBuffer != nil {
                XCTAssertGreaterThan(sut.buffer!.capacity, prevBuffer!.capacity)
                XCTAssertGreaterThanOrEqual(sut.buffer!.capacity, minCapacity)
                // Correct cloning of elements check is done in buffer's tests
            } else {
                XCTFail("either or both buffers are nil: both should not be nil")
            }
            
            // reset sut for next iteration
            whenContainsAllElements()
        }
    }
    
    // MARK: - makeUniqueEventuallyIncreasingCapacity() tests
    func testMakeUniqueEventuallyIncreasingCapacity_whenBufferIsNil_thenInstanciatesNewBufferAndChangesId() {
        whenIsEmpty()
        weak var prevID = sut.id
        
        sut.makeUniqueEventuallyIncreasingCapacity()
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        XCTAssertNotNil(sut.buffer)
    }
    
    func testMakeUniqueEventuallyIncreasingCapacity_whenBufferIsNotNilAndNotFullAndIsUniqueInstance_thenNothingChanges() {
        whenContainsAllElements()
        sut.makeUniqueReserving(minimumCapacity: 10)
        XCTAssertFalse(sut.buffer!.isFull)
        weak var prevID = sut.id
        weak var prevBuffer = sut.buffer
        
        sut.makeUniqueEventuallyIncreasingCapacity()
        XCTAssertTrue(sut.id === prevID, "has changed id")
        XCTAssertTrue(sut.buffer === prevBuffer, "has changed buffer")
    }
    
    func testMakeUniqueEventuallyIncreasingCapacity_whenBufferIsNotNilNotFullAndNotUniquelyReferenced_thenClonesBufferAndDoesntChangeID() {
        whenContainsAllElements()
        sut.makeUniqueReserving(minimumCapacity: 10)
        XCTAssertFalse(sut.buffer!.isFull)
        weak var prevID = sut.id
        let otherBufferStrongReference = sut.buffer!
        
        sut.makeUniqueEventuallyIncreasingCapacity()
        XCTAssertTrue(sut.id === prevID, "has changed id")
        XCTAssertNotNil(sut.buffer)
        XCTAssertFalse(sut.buffer === otherBufferStrongReference)
        // Correct cloning of elements check is done in buffer's tests
    }
    
    func testMakeUniqueEventuallyIncreasingCapacity_whenBufferIsNotNilAndFull_thenClonesBufferToLargerOneAndChangesId() {
        whenContainsAllElements()
        XCTAssertTrue(sut.buffer!.isFull)
        weak var prevID = sut.id
        let prevBuffer = sut.buffer!
        
        sut.makeUniqueEventuallyIncreasingCapacity()
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
        if sut.buffer != nil {
            XCTAssertGreaterThan(sut.buffer!.capacity, prevBuffer.capacity)
            XCTAssertFalse(sut.buffer!.isFull)
        } else {
            XCTFail("sut buffer should not be nil")
        }
    }
    
    // MARK: - makeUniqueEventuallyReducingCapacity() tests
    func testMakeUniqueEventuallyDecreasingCapacity_whenBufferIsNil_thenNothingChanges() {
        whenIsEmpty()
        weak var prevID = sut.id
        
        sut.makeUniqueEventuallyReducingCapacity()
        XCTAssertTrue(sut.id === prevID, "has changed id")
        XCTAssertNil(sut.buffer)
    }
    
    func testMakeUniqueEventuallyDecreasingCapacity_whenBufferIsNotNilAndEmpty_thenBufferIsSetToNilAndChangesId() {
        whenIsEmpty(withCapacity: 10)
        weak var prevID = sut.id
        
        sut.makeUniqueEventuallyReducingCapacity()
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        XCTAssertNil(sut.buffer)
    }
    
    func testMakeUniqueEventuallyReducingCapacity_whenBufferIsNotEmptyAndNotTooSparseAndUniqueReference_thenNothingChanges() {
        whenContainsAllElements()
        XCTAssertFalse(sut.buffer!.isTooSparse)
        weak var prevID = sut.id
        weak var prevBuffer = sut.buffer
        
        sut.makeUniqueEventuallyReducingCapacity()
        XCTAssertTrue(sut.id === prevID, "has changed id")
        XCTAssertTrue(sut.buffer === prevBuffer, "has changed buffer")
    }
    
    func testMakeUniqueEventuallyReducingCapacity_whenBufferIsNotEmptyAndNotTooSparseAndNotUniquelyReferenced_thenClonesBufferAndDoesntChangesID() {
        whenContainsAllElements()
        XCTAssertFalse(sut.buffer!.isTooSparse)
        weak var prevID = sut.id
        let otherBufferStrongReference = sut.buffer!
        
        sut.makeUniqueEventuallyReducingCapacity()
        XCTAssertTrue(sut.id === prevID, "has changed id")
        XCTAssertFalse(sut.buffer === otherBufferStrongReference, "has not cloned buffer")
        XCTAssertEqual(sut.buffer?.capacity, otherBufferStrongReference.capacity)
        // Correct cloning of elements check is done in buffer's tests
    }
    
    func testMakeUniqueEventuallyReducingCapacity_whenBufferIsNotEmptyAndTooSparse_thenClonesBufferToSmallerOneAndChangesID() {
        whenContainsAllElements()
        sut.makeUniqueReserving(minimumCapacity: sut.count * 8)
        XCTAssertTrue(sut.buffer!.isTooSparse)
        
        weak var prevID = sut.id
        let prevBuffer = sut.buffer!
        sut.makeUniqueEventuallyReducingCapacity()
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        XCTAssertFalse(sut.buffer === prevBuffer, "has not cloned buffer")
        if sut.buffer != nil {
            XCTAssertLessThan(sut.buffer!.capacity, prevBuffer.capacity)
            XCTAssertFalse(sut.buffer!.isFull)
            XCTAssertFalse(sut.buffer!.isTooSparse)
            // Correct cloning of elements check is done in buffer's tests
        } else {
            XCTFail("sut buffer should not be nil")
        }
    }
    
}

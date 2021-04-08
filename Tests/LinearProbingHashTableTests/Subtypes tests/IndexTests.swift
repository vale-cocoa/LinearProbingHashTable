//
//  IndexTests.swift
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

final class IndexTests: BaseLPHTTests {
    func testInitAsStartIndexOf_whenIsEmpty() {
        whenIsEmpty()
        var idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
    }
    
    func testInitAsStartIndexOf_whenIsNotEmpty() {
        whenContainsHalfElements()
        let m = sut.capacity + 1
        let idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        guard
            (0..<m).contains(idx.bIdx)
        else {
            XCTFail("has returned an index out of bounds")
            
            return
        }
        
        var expectedIdx = 0
        while expectedIdx < m && sut.buffer?.keys[expectedIdx] == nil {
            expectedIdx += 1
        }
        XCTAssertEqual(idx.bIdx, expectedIdx)
        var iter = sut.makeIterator()
        let firstElement = iter.next()!
        XCTAssertEqual(sut.buffer?.keys[idx.bIdx], firstElement.key)
        XCTAssertEqual(sut.buffer?.values[idx.bIdx], firstElement.value)
    }
    
    func testInitAsEndIndexOf_whenIsEmpty() {
        whenIsEmpty()
        var idx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        idx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
    }
    
    func testInitAsEndIndexOf_whenIsNotEmpty() {
        whenContainsHalfElements()
        let idx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
    }
    
    func testInitAsIndexForKeyOf_whenIsEmpty_thenReturnsNil() {
        let allKeys = givenKeysAndValuesWithoutDuplicateKeys().map { $0.key }
        whenIsEmpty()
        for k in allKeys {
            XCTAssertNil(LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut))
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for k in allKeys {
            XCTAssertNil(LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut))
        }
    }
    
    func testInitAsIndexForKeyOf_whenIsNotEmptyAndContainsElementWithKey_thenReturnsValidIndexForTheKey() {
        whenContainsHalfElements()
        let m = sut.capacity + 1
        for (k, v) in sut {
            if let idx = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut) {
                if (0..<m).contains(idx.bIdx) {
                    XCTAssertEqual(sut.buffer?.keys[idx.bIdx], k)
                    XCTAssertEqual(sut.buffer?.values[idx.bIdx], v)
                } else {
                    XCTFail("has returned and index out of bounds")
                }
            } else {
                XCTFail("has returned nil for a stored key")
            }
        }
    }
    
    func testInitAsIndexForKeyOf_whenIsNotEmptyAndDoesntContainElementWithKey_thenReturnsNil() {
        whenContainsHalfElements()
        for k in notContainedKeys {
            XCTAssertNil(LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut))
        }
    }
    
    func testElementOn_whenIsEmpty_thenReturnsNil() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for i in 0...10 {
            idx.bIdx = i
            XCTAssertNil(idx.element(on: sut))
        }
    }
    
    func testElementOn_whenIsNotEmptyAndBIdxValueIsGreaterThanCapacity_thenReturnsNil() {
        whenContainsHalfElements()
        var idx = sut.startIndex
        let m = sut.capacity + 1
        idx.bIdx = Int.random(in: m...(m+10))
        XCTAssertNil(idx.element(on: sut))
    }
    
    func testElementOn_whenIsNotEmptyAndBIdxIsLessThanOrEqualToCapacityAndPointsToANilKey_thenReturnsNil() {
        whenContainsHalfElements()
        var idx = sut.startIndex
        for i in 0..<(sut.capacity + 1) where sut.buffer?.keys[i] == nil {
            idx.bIdx = i
            XCTAssertNil(idx.element(on: sut))
        }
    }
    
    func testElementOn_whenIsNotEmptyAndBIdxIsLessThanOrEqualToCapacityAndPointsToANonNilElement_thenReturnsThatElement() {
        whenContainsHalfElements()
        var idx = sut.startIndex
        for i in 0..<(sut.capacity + 1) where sut.buffer?.keys[i] != nil && sut.buffer?.values[i] != nil {
            idx.bIdx = i
            let e = idx.element(on: sut)
            XCTAssertNotNil(e)
            XCTAssertEqual(e?.key, sut.buffer?.keys[idx.bIdx])
            XCTAssertEqual(e?.value, sut.buffer?.values[idx.bIdx])
        }
    }
    
    func testMoveToNextOn_increasesAtLeastByOneBIdx() {
        whenContainsHalfElements()
        var idx = sut.startIndex
        for _ in 0..<100 {
            let prevBIdx = idx.bIdx
            idx.moveToNext(on: sut)
            XCTAssertGreaterThanOrEqual(idx.bIdx, prevBIdx + 1)
        }
    }
    
    func testMoveToNextOn_whenBIdxIsLessThanCapacityAndThereIsNoElementAfterBIdxInBuffer_thenReturnsNil() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.startIndex
        idx.bIdx = 0
        XCTAssertNil(idx.moveToNext(on: sut))
        
        whenContainsHalfElements()
        sut.buffer?.keys[sut.capacity] = nil
        sut.buffer?.values[sut.capacity] = nil
        var lastBIdx = sut.capacity
        while sut.buffer?.keys[lastBIdx] == nil {
            lastBIdx -= 1
        }
        idx.bIdx = lastBIdx
        
        XCTAssertNil(idx.moveToNext(on: sut))
    }
    
    func testMoveToNextOn_whenBIdxIsGreaterThanCapacity_thenReturnsNil() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.startIndex
        idx.bIdx = sut.capacity + 1
        XCTAssertNil(idx.moveToNext(on: sut))
        
        whenContainsHalfElements()
        idx = sut.startIndex
        idx.bIdx = sut.capacity + 1
        XCTAssertNil(idx.moveToNext(on: sut))
    }
    
    func testMoveToNextOn_whenBIdxIsLessThanCapacityAndThereIsAnElementAfterBIdxInBuffer_thenAdvancesBIdxToThatValueAndReturnsTheElement() throws {
        whenContainsHalfElements()
        var idx = sut.startIndex
        var expectedBIdxValue = idx.bIdx + 1
        while expectedBIdxValue <= sut.capacity && sut.buffer?.keys[expectedBIdxValue] == nil {
            expectedBIdxValue += 1
        }
        let e = idx.moveToNext(on: sut)
        try XCTSkipIf(e == nil && sut.buffer?.keys[expectedBIdxValue] == nil)
        XCTAssertEqual(idx.bIdx, expectedBIdxValue)
        XCTAssertEqual(e?.key, sut.buffer?.keys[expectedBIdxValue])
        XCTAssertEqual(e?.value, sut.buffer?.values[expectedBIdxValue])
    }
    
    func testEqual_returnsTrueWhenHaveSameBIdxValue() {
        whenContainsHalfElements()
        var lhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        var rhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for _ in 0..<(sut.capacity + 1) {
            XCTAssertEqual(lhs, rhs)
            lhs.bIdx += 1
            rhs.bIdx += 1
        }
    }
    
    func testEqual_returnsFalseWhenHaveDifferentBIdxValue() {
        whenContainsAllElements()
        var lhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        var rhs = lhs
        lhs.bIdx += 1
        for _ in 0..<(sut.capacity + 1) {
            XCTAssertNotEqual(lhs, rhs)
            lhs.bIdx += 1
            rhs.bIdx += 1
        }
    }
    
    func testIsLessThan_returnsTrueWhenLHSHasBIdxValueLessThanRHS() {
        whenContainsAllElements()
        var lhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        var rhs = lhs
        rhs.bIdx += 1
        for _ in 0..<(sut.capacity + 1) {
            XCTAssertLessThan(lhs, rhs)
            lhs.bIdx += 1
            rhs.bIdx += 1
        }
    }
    
}

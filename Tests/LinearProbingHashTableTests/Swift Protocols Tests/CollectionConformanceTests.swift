//
//  CollectionConformanceTests.swift
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

final class ConformanceTests: BaseLPHTTests {
    func testStartIndex_returnsSameOfIndexInitAsStartIndexOf() {
        whenIsEmpty()
        var expectedResult = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(sut.startIndex, expectedResult)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        expectedResult = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(sut.startIndex, expectedResult)
        
        whenContainsHalfElements()
        expectedResult = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(sut.startIndex, expectedResult)
        
        whenContainsAllElements()
        expectedResult = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertEqual(sut.startIndex, expectedResult)
    }
    
    func testEndIndex_returnsSameOfIndexInitAsEndIndexOf() {
        whenIsEmpty()
        var expectedResult = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(sut.endIndex, expectedResult)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        expectedResult = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(sut.endIndex, expectedResult)
        
        whenContainsHalfElements()
        expectedResult = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(sut.endIndex, expectedResult)
        
        whenContainsAllElements()
        expectedResult = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertEqual(sut.endIndex, expectedResult)
    }
    
    func testStartIndexAndEndIndex_whenIsEmpty_thenAreEqual() {
        whenIsEmpty()
        XCTAssertEqual(sut.startIndex, sut.endIndex)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertEqual(sut.startIndex, sut.endIndex)
    }
    
    func testStarIndexAndEndIndex_whenIsNotEmpty_thenStartIndexIsLessThanEndIndex() {
        whenContainsHalfElements()
        XCTAssertLessThan(sut.startIndex, sut.endIndex)
        
        whenContainsAllElements()
        XCTAssertLessThan(sut.startIndex, sut.endIndex)
    }
    
    // MARK: - index(after:) tests
    // These tests are also testing formIndex(after:) method
    func testIndexAfter_whenIsEndIndex_thenReturnsEndIndex() {
        whenIsEmpty()
        XCTAssertGreaterThan(sut.index(after: sut.endIndex), sut.endIndex)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertGreaterThan(sut.index(after: sut.endIndex), sut.endIndex)
        
        whenContainsHalfElements()
        XCTAssertGreaterThan(sut.index(after: sut.endIndex), sut.endIndex)
        
        whenContainsAllElements()
        XCTAssertGreaterThan(sut.index(after: sut.endIndex), sut.endIndex)
    }
    
    func testIndexAfter_returnsSameIndexMoveToNextOn() {
        whenContainsHalfElements()
        var idx = sut.startIndex
        for _ in 0..<sut.count {
            let result = sut.index(after: idx)
            var expectedResult = idx
            expectedResult.moveToNext(on: sut)
            
            XCTAssertEqual(result, expectedResult)
            idx = result
        }
        XCTAssertEqual(idx, sut.endIndex)
    }
    
    // MARK: - index(_:offsetBy:) tests
    // These tests are also testing formIndex(_:offsetBy:) method
    func testIndexOffsetBy_whenDistanceIsZeroThanReturnsSameIndex() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for _ in 0..<sut.count {
            XCTAssertEqual(sut.index(idx, offsetBy: 0), idx)
            idx.moveToNext(on: sut)
        }
        XCTAssertGreaterThan(sut.index(after: idx), idx)
    }
    
    func testIndexOffsetBy_whenDistanceIsGreaterThanZero_thenReturnsAnIndexOffssetedByThatDistance() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for i in 0..<sut.count {
            var distance = i
            distance += Int.random(in: 0...10)
            var expectedResult = idx
            for _ in stride(from: 0, to: distance, by: 1) { expectedResult.moveToNext(on: sut) }
            XCTAssertEqual(sut.index(idx, offsetBy: distance), expectedResult)
            
            idx.moveToNext(on: sut)
        }
    }
    
    // MARK: - index(_:offsetBy:limitedBy:) tests
    func testIndexOffsetByLimitedBy_whenDistanceIsZero_thenReturnsSameIndex() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for _ in 0..<sut.count {
            var limit = sut.startIndex
            for _ in 0..<sut.count {
                XCTAssertEqual(sut.index(idx, offsetBy: 0, limitedBy: limit), idx)
                sut.formIndex(after: &limit)
            }
            sut.formIndex(after: &idx)
        }
    }
    
    func testIndexOffsetByLimitedBy_whenLimitIsLessThanIndex_thenIngnoresLimit() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for i in 0..<sut.count {
            let limit = idx
            sut.formIndex(after: &idx)
            for distance in stride(from: 0, to: sut.count - i, by: 1) {
                if let result = sut.index(idx, offsetBy: distance, limitedBy: limit) {
                    let expectedResult = sut.index(idx, offsetBy: distance)
                    XCTAssertEqual(result, expectedResult)
                } else {
                    XCTFail("has not ignored limit")
                }
            }
        }
    }
    
    func testIndexOffsetByLimitedBy_whenLimitIsGreaterThanOrEqualToIndexAndOffsettingGoesBeyondLimit_thenReturnsNil() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for _ in 0..<sut.count {
            var limit = idx
            for distance in stride(from: 1, through: sut.count, by: 1) {
                XCTAssertNil(sut.index(idx, offsetBy: distance, limitedBy: limit))
                sut.formIndex(after: &limit)
            }
            sut.formIndex(after: &idx)
        }
    }
    
    func testIndexOffsetByLimitedBy_whenLimitIsGreaterThanOrEqualToIndexAndOffsettingDoesntGoBeyondLimit_thenReturnsOffsettedIndexLessThanOrEqualToLimit() {
        whenContainsAllElements()
        var idx = sut.startIndex
        for i in 0..<sut.count {
            var limit = idx
            for maxDistance in stride(from: 0, to: sut.count - i, by: 1) {
                for distance in stride(from: maxDistance, through: 0, by: -1) {
                    if let result = sut.index(idx, offsetBy: distance, limitedBy: limit) {
                        XCTAssertLessThanOrEqual(result, limit)
                    } else {
                        XCTFail("has returned nil")
                    }
                }
                
                sut.formIndex(after: &limit)
            }
            
            sut.formIndex(after: &idx)
        }
    }
    
    // MARK: - subscript tests
    func testSubscript() {
        whenContainsHalfElements()
        var bufferIterator = sut.buffer?.makeIterator()
        var idx = sut.startIndex
        while let expectedElement = bufferIterator?.next() {
            let element = sut[idx]
            XCTAssertEqual(element.key, expectedElement.key)
            XCTAssertEqual(element.value, expectedElement.value)
            sut.formIndex(after: &idx)
        }
        XCTAssertEqual(idx, sut.endIndex)
    }
    
    // MARK: - remove(at:) tests
    func testRemoveAt_removesAndReturnsElementAtIndex() {
        whenContainsAllElements()
        for _ in 0..<sut.count {
            let distance = Int.random(in: 0..<sut.count)
            let idx = sut.index(sut.startIndex, offsetBy: distance)
            let expectedResult = sut[idx]
            let prevCount = sut.count
            let removed = sut.remove(at: idx)
            XCTAssertEqual(removed.key, expectedResult.key)
            XCTAssertEqual(removed.value, expectedResult.value)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertNil(sut.getValue(forKey: removed.key))
        }
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testIndexForKey_returnsResultOfIndexInitAsIndexForKeyOf() {
        whenContainsHalfElements()
        for k in givenKeysAndValuesWithoutDuplicateKeys().map({ $0.key }) {
            XCTAssertEqual(sut.index(forKey: k), LinearProbingHashTable<String, Int>.Index(asIndexForKey: k, of: sut))
        }
    }
    
}

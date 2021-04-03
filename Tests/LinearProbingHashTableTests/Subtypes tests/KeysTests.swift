//
//  KeysTests.swift
//  LinearProbingHashTableTests
//
//  Created by Valeriano Della Longa on 2021/04/03.
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

final class KeysTests: BaseLPHTTests {
    func testKeysSubType_count_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.keys.count, sut.count)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.keys.count, sut.count)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.keys.count, sut.count)
    }
    
    func testKeysSubType_underestimatedCount_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.keys.underestimatedCount, sut.underestimatedCount)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.keys.underestimatedCount, sut.underestimatedCount)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.keys.underestimatedCount, sut.underestimatedCount)
    }
    
    func testKeysSubType_isEmpty_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.keys.isEmpty, sut.isEmpty)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.keys.isEmpty, sut.isEmpty)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.keys.isEmpty, sut.isEmpty)
    }
    
    func testKeysSubType_startIndex_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.keys.startIndex, sut.startIndex)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.keys.startIndex, sut.startIndex)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.keys.startIndex, sut.startIndex)
    }
    
    func testKeysSubType_endIndex_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.keys.endIndex, sut.endIndex)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.keys.endIndex, sut.endIndex)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.keys.endIndex, sut.endIndex)
    }
    
    func testKeysSubType_indexAfter_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.keys.startIndex
        XCTAssertEqual(sut.keys.index(after: idx), sut.index(after: idx))
        
        whenContainsAllElements()
        idx = sut.keys.startIndex
        while idx < sut.keys.endIndex {
            let result = sut.keys.index(after: idx)
            let expectedResult = sut.index(after: idx)
            XCTAssertEqual(result, expectedResult)
            idx = result
        }
    }
    
    func testKeysSubType_formIndexAfter_formsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.keys.startIndex
        var htIdx = idx
        sut.keys.formIndex(after: &idx)
        sut.formIndex(after: &htIdx)
        XCTAssertEqual(idx, htIdx)
        
        whenContainsAllElements()
        idx = sut.keys.startIndex
        htIdx = idx
        while idx < sut.keys.endIndex {
            sut.keys.formIndex(after: &idx)
            sut.formIndex(after: &htIdx)
            XCTAssertEqual(idx, htIdx)
        }
    }
    
    func testKeysSubType_indexOffsetBy_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.keys.startIndex
        for distance in 0...1 {
            let result = sut.keys.index(idx, offsetBy: distance)
            XCTAssertEqual(result, sut.index(idx, offsetBy: distance))
        }
        
        whenContainsAllElements()
        idx = sut.keys.startIndex
        while idx < sut.keys.endIndex {
            for distance in 0...(sut.keys.count + 1) {
                let result = sut.keys.index(idx, offsetBy: distance)
                XCTAssertEqual(result, sut.index(idx, offsetBy: distance))
            }
            sut.keys.formIndex(after: &idx)
        }
    }
    
    func testKeysSubType_formIndexOffsetBy_formsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.keys.startIndex
        for distance in 0...1 {
            var result = idx
            var expectedResult = idx
            sut.keys.formIndex(&result, offsetBy: distance)
            sut.formIndex(&expectedResult, offsetBy: distance)
            XCTAssertEqual(result, expectedResult)
        }
        
        whenContainsAllElements()
        idx = sut.keys.startIndex
        while idx < sut.keys.endIndex {
            for distance in 0...(sut.keys.count + 1) {
                var result = idx
                var expectedResult = idx
                sut.keys.formIndex(&result, offsetBy: distance)
                sut.formIndex(&expectedResult, offsetBy: distance)
                XCTAssertEqual(result, expectedResult)
            }
            sut.keys.formIndex(after: &idx)
        }
    }
    
    func testKeysSubType_indexOffsetByLimitedBy_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.keys.startIndex
        var limit = idx
        for distance in 0...1 {
            XCTAssertEqual(sut.keys.index(idx, offsetBy: distance, limitedBy: limit), sut.index(idx, offsetBy: distance, limitedBy: limit))
        }
        
        whenContainsAllElements()
        idx = sut.keys.startIndex
        limit = idx
        while idx < sut.keys.endIndex {
            while limit < sut.keys.endIndex {
                for distance in 0...(sut.keys.count + 1) {
                    XCTAssertEqual(sut.keys.index(idx, offsetBy: distance, limitedBy: limit), sut.index(idx, offsetBy: distance, limitedBy: limit))
                }
                sut.keys.formIndex(after: &limit)
            }
            sut.keys.formIndex(after: &idx)
        }
    }
    
    func testKeysSubType_subscript_returnsKeyOfSameHTElementAtPosition() {
        whenContainsAllElements()
        var idx = sut.keys.startIndex
        while idx < sut.keys.endIndex {
            XCTAssertEqual(sut.keys[idx], sut[idx].key)
            sut.keys.formIndex(after: &idx)
        }
    }
    
    func testKeysSubType_EquatableConformance() throws {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var other = LinearProbingHashTable<String, Int>()
        XCTAssertEqual(sut.keys, other.keys)
        
        whenContainsHalfElements()
        other = sut
        for k in other.keys { other[k, default: 0] += 1 }
        XCTAssertEqual(sut.keys, other.keys)
        
        // when count of keys are different, then returns false
        other = sut
        let keyToRemove = containedKeys.randomElement()!
        other.removeValue(forKey: keyToRemove)
        XCTAssertNotEqual(sut.keys.count, other.keys.count)
        XCTAssertNotEqual(sut.keys, other.keys)
        
        // when count of keys are equal but keys are different, then returns false
        other = sut
        let v = other.removeValue(forKey: keyToRemove)!
        other.updateValue(v, forKey: randomKey(ofLenght: 2))
        XCTAssertEqual(sut.keys.count, other.keys.count)
        XCTAssertNotEqual(sut.keys, other.keys)
        
        // when count of keys are equal, keys are the same but in different order,
        // then returns false
        other.removeAll()
        sut.keys.forEach { other.updateValue(randomValue(), forKey: $0) }
        let countOfKeysInSameOrder = zip(sut.keys, other.keys).reduce(0, {
            $1.0 == $1.1 ? $0 + 1 : $0
        })
        try XCTSkipIf(sut.keys.count == countOfKeysInSameOrder, "keys were in the same order")
        XCTAssertNotEqual(sut.keys, other.keys)
    }
    
    func testKeysComputedProperty_whenIsEmpty_thenReturnsEmptyKeys() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        XCTAssertTrue(sut.keys.isEmpty)
    }
    
    func testKeysComputedProperty_whenIsNotEmpty_thenReturnsKeysWithAllKeysInSameOrder() {
        whenContainsHalfElements()
        let keys = sut.keys
        XCTAssertEqual(sut.count, keys.count)
        var sutIter = sut.makeIterator()
        var keysIter = keys.makeIterator()
        while let expectedK = sutIter.next()?.key {
            XCTAssertEqual(keysIter.next(), expectedK)
        }
        XCTAssertNil(keysIter.next())
    }
    
    func testKeysComputedProperty_copyOnWrite() {
        whenContainsHalfElements()
        var prevKeys = sut.keys
        for k in notContainedKeys {
            sut.updateValue(randomValue(), forKey: k)
            XCTAssertNotEqual(sut.keys, prevKeys)
            prevKeys = sut.keys
        }
    }
    
}

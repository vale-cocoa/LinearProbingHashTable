//
//  ValuesTests.swift
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

final class ValuesTests: BaseLPHTTests {
    func testValuesSubType__count_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.values.count, sut.count)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.values.count, sut.count)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.values.count, sut.count)
    }
    
    func testValuesSubType_underestimatedCount_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.values.underestimatedCount, sut.underestimatedCount)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.values.underestimatedCount, sut.underestimatedCount)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.values.underestimatedCount, sut.underestimatedCount)
    }
    
    func testValuesSubType_isEmpty_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.values.isEmpty, sut.isEmpty)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.values.isEmpty, sut.isEmpty)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.values.isEmpty, sut.isEmpty)
    }
    
    func testValuesSubType_startIndex_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.values.startIndex, sut.startIndex)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.values.startIndex, sut.startIndex)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.values.startIndex, sut.startIndex)
    }
    
    func testValuesSubType_endIndex_returnsSameValueOfHashTable() {
        whenIsEmpty()
        XCTAssertEqual(sut.values.endIndex, sut.endIndex)
        
        whenContainsHalfElements()
        XCTAssertEqual(sut.values.endIndex, sut.endIndex)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.values.endIndex, sut.endIndex)
    }
    
    func testValuesSubType_indexAfter_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.values.startIndex
        XCTAssertEqual(sut.values.index(after: idx), sut.index(after: idx))
        
        whenContainsAllElements()
        idx = sut.values.startIndex
        while idx < sut.values.endIndex {
            let result = sut.values.index(after: idx)
            let expectedResult = sut.index(after: idx)
            XCTAssertEqual(result, expectedResult)
            idx = result
        }
    }
    
    func testValuesSubType_formIndexAfter_formsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.values.startIndex
        var htIdx = idx
        sut.values.formIndex(after: &idx)
        sut.formIndex(after: &htIdx)
        XCTAssertEqual(idx, htIdx)
        
        whenContainsAllElements()
        idx = sut.values.startIndex
        htIdx = idx
        while idx < sut.values.endIndex {
            sut.values.formIndex(after: &idx)
            sut.formIndex(after: &htIdx)
            XCTAssertEqual(idx, htIdx)
        }
    }
    
    func testValuesSubType_indexOffsetBy_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.values.startIndex
        for distance in 0...1 {
            let result = sut.values.index(idx, offsetBy: distance)
            XCTAssertEqual(result, sut.index(idx, offsetBy: distance))
        }
        
        whenContainsAllElements()
        idx = sut.values.startIndex
        while idx < sut.values.endIndex {
            for distance in 0...(sut.values.count + 1) {
                let result = sut.values.index(idx, offsetBy: distance)
                XCTAssertEqual(result, sut.index(idx, offsetBy: distance))
            }
            sut.values.formIndex(after: &idx)
        }
    }
    
    func testValuesSubType_formIndexOffsetBy_formsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.values.startIndex
        for distance in 0...1 {
            var result = idx
            var expectedResult = idx
            sut.values.formIndex(&result, offsetBy: distance)
            sut.formIndex(&expectedResult, offsetBy: distance)
            XCTAssertEqual(result, expectedResult)
        }
        
        whenContainsAllElements()
        idx = sut.values.startIndex
        while idx < sut.values.endIndex {
            for distance in 0...(sut.values.count + 1) {
                var result = idx
                var expectedResult = idx
                sut.values.formIndex(&result, offsetBy: distance)
                sut.formIndex(&expectedResult, offsetBy: distance)
                XCTAssertEqual(result, expectedResult)
            }
            sut.values.formIndex(after: &idx)
        }
    }
    
    func testValuesSubType_indexOffsetByLimitedBy_returnsSameValueOfHashTableMethod() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var idx = sut.values.startIndex
        var limit = idx
        for distance in 0...1 {
            XCTAssertEqual(sut.values.index(idx, offsetBy: distance, limitedBy: limit), sut.index(idx, offsetBy: distance, limitedBy: limit))
        }
        
        whenContainsAllElements()
        idx = sut.values.startIndex
        limit = idx
        while idx < sut.values.endIndex {
            while limit < sut.values.endIndex {
                for distance in 0...(sut.values.count + 1) {
                    XCTAssertEqual(sut.values.index(idx, offsetBy: distance, limitedBy: limit), sut.index(idx, offsetBy: distance, limitedBy: limit))
                }
                sut.values.formIndex(after: &limit)
            }
            sut.values.formIndex(after: &idx)
        }
    }
    
    func testValuesSubType_subscriptGetter() {
        whenContainsAllElements()
        var idx = sut.values.startIndex
        while idx < sut.values.endIndex {
            XCTAssertEqual(sut.values[idx], sut[idx].value)
            sut.values.formIndex(after: &idx)
        }
    }
    
    func testValuesSubType_subscriptModify() {
        whenContainsAllElements()
        var idx = sut.startIndex
        while idx < sut.endIndex {
            let newValue = sut[idx].value + 100
            sut.values[idx] += 100
            XCTAssertEqual(sut[idx].value, newValue)
            sut.formIndex(after: &idx)
        }
    }
    
    func testValueSubType_CopyOnWrite() {
        whenContainsAllElements()
        var values = sut.values
        var idx = values.startIndex
        var htIdx = sut.startIndex
        while idx < values.endIndex && htIdx < sut.endIndex {
            values[idx] = 1000
            XCTAssertNotEqual(sut[htIdx].value, values[idx])
            sut.formIndex(after: &htIdx)
            values.formIndex(after: &idx)
        }
        XCTAssertEqual(idx, values.endIndex)
        XCTAssertEqual(htIdx, sut.endIndex)
    }
    
    func testValuesSubType_EquatableConformance() throws {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        var other = LinearProbingHashTable<String, Int>()
        XCTAssertEqual(sut.values, other.values)
        
        // when count of values are equal and values are the same in the same order,
        // then returns true
        whenContainsHalfElements()
        other = LinearProbingHashTable(minimumCapacity: sut.capacity)
        for i in 0..<sut.count { other.updateValue(randomValue(), forKey: randomKey(ofLenght: i + 1))
        }
        try XCTSkipIf(sut.count != other.count, "not same count")
        var sutIdx = sut.startIndex
        var otherIdx = other.startIndex
        while sutIdx < sut.endIndex && otherIdx < other.endIndex {
            other.values[otherIdx] = sut.values[sutIdx]
            sut.formIndex(after: &sutIdx)
            other.formIndex(after: &otherIdx)
        }
        XCTAssertNotEqual(sut.keys, other.keys)
        XCTAssertEqual(sut.values, other.values)
        
        // when count of values are different, then returns false
        other = sut
        let keyToRemove = containedKeys.randomElement()!
        other.removeValue(forKey: keyToRemove)
        XCTAssertNotEqual(sut.values.count, other.values.count)
        XCTAssertNotEqual(sut.values, other.values)
        
        // when count of values are equal but values are different, then returns false
        other = sut.compactMapValues({ $0 + 1 })
        XCTAssertEqual(sut.values.count, other.values.count)
        XCTAssertNotEqual(sut.values, other.values)
        
        // when count of values are equal, values are the same but in different order,
        // then returns false
        other = sut
        let i = other.index(other.startIndex, offsetBy: Int.random(in: 0..<(other.count / 2)))
        let j = other.index(other.startIndex, offsetBy: Int.random(in: (other.count / 2)..<other.count))
        other.values.swapAt(i, j)
        XCTAssertNotEqual(sut.values, other.values)
    }
    
    func testValuesComputedProperty_getter_whenIsEmpty_thenReturnsEmptyValues() {
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        XCTAssertTrue(sut.values.isEmpty)
    }
    
    func testValuesComputedProperty_getter_whenIsNotEmpty_thenReturnsValuessWithAllValuessInSameOrder() {
        whenContainsHalfElements()
        let values = sut.values
        XCTAssertEqual(sut.count, values.count)
        var sutIter = sut.makeIterator()
        var valuesIter = values.makeIterator()
        while let expectedValue = sutIter.next()?.value {
            XCTAssertEqual(valuesIter.next(), expectedValue)
        }
        XCTAssertNil(valuesIter.next())
    }
    
    func testValuesComputedProperty_getter_CopyOnWrite() {
        whenContainsHalfElements()
        var prevValues = sut.values
        for k in notContainedKeys {
            sut.updateValue(randomValue(), forKey: k)
            XCTAssertNotEqual(sut.values, prevValues)
            prevValues = sut.values
        }
    }
    
    func testValuesComputedProperty_setter() {
        whenContainsAllElements()
        var idx = sut.startIndex
        while idx < sut.endIndex {
            let prevValue = sut.values[idx]
            sut.values[idx] += 100
            XCTAssertEqual(sut[idx].value, prevValue + 100)
            sut.formIndex(after: &idx)
        }
    }
    
    func testValuesComputedProperty_setter_CopyOnWrite() {
        whenContainsAllElements()
        var copy = sut!
        copy.values[copy.startIndex] = 1000
        XCTAssertFalse(sut.buffer === copy.buffer, "has not cloned buffer")
    }
    
}

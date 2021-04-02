//
//  MergeTests.swift
//  LinearProbingHashTableTests
//
//  Created by Valeriano Della Longa on 2021/04/02.
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

final class MergeTests: BaseLPHTTests {
    func testMergeSequence_whenBufferIsNilAndElementsIsEmpty_thenCombineNeverExecutesAndBufferStillNil() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _ ,_ in
            hasExecuted = true
            
            return 0
        }
        whenIsEmpty()
        let elements = [(String, Int)]()
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNil(sut.buffer)
    }
    
    func testMergeSequence_whenBufferIsNotNilAndEmpty_thenCombineNeverExecutesAndBufferIsNil() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _ ,_ in
            hasExecuted = true
            
            return 0
        }
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        let elements = [(String, Int)]()
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNil(sut.buffer)
    }
    
    func testMergeSequence_whenBufferIsNilOrEmptyAndSequenceIsNotEmptyAndWithoutDuplicateKeys_thenCombineNeverExecutesAndBufferContainsAllElementsFromSequence() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _ ,_ in
            hasExecuted = true
            
            return 0
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        whenIsEmpty()
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, elements.count)
        for (k, v) in elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        hasExecuted = false
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, elements.count)
        for (k, v) in elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeSequence_whenBufferIsNotEmptyAndSequenceIsEmpty_thenCombineNeverExecutesAndBufferContainsSameElements() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _ ,_ in
            hasExecuted = true
            
            return 0
        }
        whenContainsAllElements()
        let elements = [(String, Int)]()
        let prevBuffer = sut.buffer!
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertEqual(sut.count, prevBuffer.count)
        for (k, v) in prevBuffer {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMerge_whenBothAreNotEmptyAndNoDuplicateKeys_thenCombineNeverExecutesAndElementsFromSequenceGetInserted() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _ ,_ in
            hasExecuted = true
            
            return 0
        }
        whenContainsHalfElements()
        let elements = notContainedKeys.map { ($0, randomValue()) }
        var expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(elements, uniquingKeysWith: combine)
        hasExecuted = false
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeSequence_whenIsEmptyAndSequenceIsNotEmptyWithDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndElementsAreInserted() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenIsEmpty()
        let elements = givenKeysAndValuesWithDuplicateKeys()
        let expectedResult = Dictionary(elements, uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        countOfExeutions = 0
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeSequence_whenBothAreNotEmptyAndDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndElementsAreMerged() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsAllElements()
        let elements = givenKeysAndValuesWithDuplicateKeys()
        var expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(elements, uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        sut.merge(elements, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeSequence_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        whenContainsAllElements()
        let elements = givenKeysAndValuesWithDuplicateKeys()
        
        do {
            try sut.merge(elements, uniquingKeysWith: combine)
            XCTFail("has not rethrown error")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testMergeOther_whenOtherIsEmpty_thenCombineNeverExecutesAndNothingChanges() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        let other = LinearProbingHashTable<String, Int>()
        whenIsEmpty()
        weak var prevBuffer = sut.buffer
        var prevID = sut.id
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === prevBuffer, "buffer has changed")
        XCTAssertTrue(sut.id === prevID)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        prevBuffer = sut.buffer
        prevID = sut.id
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === prevBuffer, "buffer has changed")
        XCTAssertTrue(sut.id === prevID)
        
        whenContainsHalfElements()
        prevBuffer = sut.buffer
        prevID = sut.id
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === prevBuffer, "buffer has changed")
        XCTAssertTrue(sut.id === prevID)
        
        whenContainsAllElements()
        prevBuffer = sut.buffer
        prevID = sut.id
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === prevBuffer, "buffer has changed")
        XCTAssertTrue(sut.id === prevID)
    }
    
    func testMergeOther_whenIsEmptyAndOtherIsNotEmpty_thenCombineNeverExecutesAndSetsBufferAndIDtoOthers() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        
        let other = LinearProbingHashTable(uniqueKeysWithValues: givenKeysAndValuesWithoutDuplicateKeys())
        whenIsEmpty()
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === other.buffer, "has not set buffer to other's one")
        XCTAssertTrue(sut.id === other.id, "has not set id to other's one")
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(sut.buffer === other.buffer, "has not set buffer to other's one")
        XCTAssertTrue(sut.id === other.id, "has not set id to other's one")
    }
    
    func testMergeOther_whenBothArentEmptyAndNoDuplicateKeys_thenCombineNeverExecutesAndOtherElementsAreInserted() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: notContainedKeys.map({ ($0, randomValue()) }))
        var expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(Array(other), uniquingKeysWith: combine)
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeOther_whenBothArentEmptyAndDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndElmentsAreMergedAccordignly() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: containedKeys.map({ ($0, randomValue()) }))
        var expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(Array(other), uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testMergeOther_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: containedKeys.map({ ($0, randomValue()) }))
        
        do {
            try sut.merge(other, uniquingKeysWith: combine)
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testMergingOther_whenOtherIsEmpty_thenCombineNeverExecutesAndReturnsSelf() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        let other = LinearProbingHashTable<String, Int>()
        
        whenIsEmpty()
        
        var merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.buffer === sut.buffer, "has not same buffer of sut")
        XCTAssertTrue(merged.id === sut.id, "has not same id of sut")
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        countOfExeutions = 0
        
        merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.buffer === sut.buffer, "has not same buffer of sut")
        XCTAssertTrue(merged.id === sut.id, "has not same id of sut")
        
        whenContainsHalfElements()
        countOfExeutions = 0
        
        merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.buffer === sut.buffer, "has not same buffer of sut")
        XCTAssertTrue(merged.id === sut.id, "has not same id of sut")
        
        whenContainsAllElements()
        countOfExeutions = 0
        
        merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.buffer === sut.buffer, "has not same buffer of sut")
        XCTAssertTrue(merged.id === sut.id, "has not same id of sut")
    }
    
    func testMergingOther_whenIsEmptyAndOtherIsNotEmpty_thenCombineNeverExecutesAndReturnsOther() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        let other = LinearProbingHashTable<String, Int>(uniqueKeysWithValues: givenKeysAndValuesWithoutDuplicateKeys())
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.buffer === other.buffer, "has not same buffer of other")
        XCTAssertTrue(merged.id === other.id, "has not same id of other")
    }
    
    func testMergingOther_whenBothArentEmptyAndNoDuplicateKeys_thenCombineNeverExecutesAndReturnsMerged() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: notContainedKeys.map({ ($0, randomValue()) }))
        let expectedResult = Dictionary(uniqueKeysWithValues: Array(sut)).merging(Array(other), uniquingKeysWith: combine)
        countOfExeutions = 0
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertEqual(merged.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(merged.getValue(forKey: k), v)
        }
    }
    
    func testMergingOther_wheBothArentEmptyAndDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndReturnsMerged() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: containedKeys.map({ ($0, randomValue()) }))
        let expectedResult = Dictionary(uniqueKeysWithValues: Array(sut)).merging(Array(other), uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(merged.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(merged.getValue(forKey: k), v)
        }
    }
    
    func testMergingOther_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        whenContainsHalfElements()
        let other = LinearProbingHashTable(uniqueKeysWithValues: containedKeys.map({ ($0, randomValue()) }))
        do {
            let _ = try sut.merge(other, uniquingKeysWith: combine)
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testMergingSequence_whenBothAreEmpty_thenCombineNeverExecutesAndReturnsEmptyHashTable() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        let other = [(String, Int)]()
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertTrue(merged.isEmpty)
    }
    
    func testMergingSequence_whenIsEmptyAndOtherHasElementsWithoutDuplicateKeys_thenCombineNeverExecutesAndReturnsHashTableWithOtherElements() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        let other = givenKeysAndValuesWithoutDuplicateKeys()
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertEqual(merged.count, other.count)
        for (k, v) in other {
            XCTAssertEqual(merged.getValue(forKey: k), v)
        }
    }
    
    func testMergingSequence_whenIsEmptyAndOtherHasElementsWithDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndReturnsHashTableFromOther() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        let other = givenKeysAndValuesWithDuplicateKeys()
        let expectedResult = LinearProbingHashTable(other, uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(merged, expectedResult)
    }
    
    func testMergingSequence_whenBotAreNotEmptyAndNoElementsWithDuplicateKeys_thenCombineNeverExecutesAndReturnsHashTableWithMergedElements() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = notContainedKeys.map({ ($0, randomValue()) })
        let expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
            .merging(other, uniquingKeysWith: combine)
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, 0, "combine has executed")
        XCTAssertEqual(merged.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(merged.getValue(forKey: k), v)
        }
    }
    
    func testMergingSequence_whenBotAreNotEmptyAndElementsWithDuplicateKeys_thenCombineExecutesForElementsWithDuplicateKeysAndReturnsHashTableWithMergedElements() {
        var countOfExeutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExeutions += 1
            
            return $0 + $1
        }
        whenContainsHalfElements()
        let other = containedKeys.map({ ($0, randomValue()) })
        let expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
            .merging(other, uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExeutions
        countOfExeutions = 0
        
        let merged = sut.merging(other, uniquingKeysWith: combine)
        XCTAssertEqual(countOfExeutions, expectedCountOfExecutions)
        XCTAssertEqual(merged.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(merged.getValue(forKey: k), v)
        }
    }
    
    func testMergingSequence_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        whenContainsHalfElements()
        let other = containedKeys.map({ ($0, randomValue()) })
        
        do {
            let _ = try sut.merging(other, uniquingKeysWith: combine)
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
}

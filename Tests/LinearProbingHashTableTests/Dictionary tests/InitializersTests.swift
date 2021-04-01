//
//  InitializersTests.swift
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

final class InitialzersTests: BaseLPHTTests {
    func testInitDictionaryLiteral() {
        sut = [:]
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
        
        sut = ["a" : 1, "b" : 2, "c" : 3, "d" : 4,]
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, 4)
        XCTAssertEqual(sut.getValue(forKey: "a"), 1)
        XCTAssertEqual(sut.getValue(forKey: "b"), 2)
        XCTAssertEqual(sut.getValue(forKey: "c"), 3)
        XCTAssertEqual(sut.getValue(forKey: "d"), 4)
    }
    
    func testInitSequenceWithUniqueKeysAndValues_whenSequenceIsEmpty_thenReturnsHashTableWithNilBuffer() {
        let s = [(String, Int)]()
        sut = LinearProbingHashTable(uniqueKeysWithValues: s)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(s)
        sut = LinearProbingHashTable(uniqueKeysWithValues: seq)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
    }
    
    func testInitSequenceWithUniqueKeysAndValues_whenSequenceIsNotEmpty_thenInitializesNewHashTableContainingAllElementsFromSequence() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LinearProbingHashTable(uniqueKeysWithValues: elements)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, elements.count)
        for (k, v) in elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        sut = LinearProbingHashTable(uniqueKeysWithValues: seq)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, seq.elements.count)
        for (k, v) in seq.elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testInitSequenceUniquingKeysWith_whenSequenceIsEmpty_thenCombineNeverExecutesAndReturnsHashTableWithNilBuffer() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let elements = [(String, Int)]()
        sut = LinearProbingHashTable(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        sut = LinearProbingHashTable(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNil(sut.buffer)
    }
    
    func testInitSequenceUniquingKeysWith_whenSequenceIsNotEmptyAndDoesntContainAnyDuplicateKey_thenCombineNeverExecutesAndInitializesNewHashTableWithAllElementsFromSequence() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, _ in
            hasExecuted = true
            
            return 0
        }
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        sut = LinearProbingHashTable(elements, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, elements.count)
        for (k, v) in elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        sut = LinearProbingHashTable(seq, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(sut.count, seq.elements.count)
        for (k, v) in seq.elements {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testInitSequenceUniquingKeysWith_whenSequenceIsNotEmptyAndContainsDuplicateKeys_thenCombineExecutesAndInitializesNewHashTableWithAllElementsFromSequenceCombiningValuesForDuplicateKeys() {
        var countOfExecutions = 0
        let combine: (Int, Int) -> Int = {
            countOfExecutions += 1
            return $0 + $1
        }
        let elements = givenKeysAndValuesWithDuplicateKeys()
        let expectedResult = Dictionary(elements, uniquingKeysWith: combine)
        let expectedCountOfExecutions = countOfExecutions
        countOfExecutions = 0
        
        sut = LinearProbingHashTable(elements, uniquingKeysWith: combine)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(countOfExecutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        countOfExecutions = 0
        let seq = Seq<(String, Int)>(elements)
        sut = LinearProbingHashTable(seq, uniquingKeysWith: combine)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.id)
        XCTAssertNotNil(sut.buffer)
        XCTAssertEqual(countOfExecutions, expectedCountOfExecutions)
        XCTAssertEqual(sut.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(sut.getValue(forKey: k), v)
        }
    }
    
    func testInitSequenceUniquingKeysWith_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in throw err }
        let elements = givenKeysAndValuesWithDuplicateKeys()
        do {
            sut = try LinearProbingHashTable(elements, uniquingKeysWith: combine)
            XCTFail("Has not rethrown error")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<(String, Int)>(elements)
        do {
            sut = try LinearProbingHashTable(seq, uniquingKeysWith: combine)
            XCTFail("Has not rethrown error")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testInitGroupingBy_whenSequenceIsEmpty_thenKeyForValueNeverExecutesAndReturnsHashTableWithNilBuffer() {
        var hasExecuted = false
        let keyForValue: (Int) -> String = { _ in
            hasExecuted = true
            
            return ""
        }
        let elements = [Int]()
        
        var result = LinearProbingHashTable(grouping: elements, by: keyForValue)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.id)
        XCTAssertNil(result.buffer)
        XCTAssertFalse(hasExecuted)
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<Int>(elements)
        hasExecuted = false
        result = LinearProbingHashTable(grouping: seq, by: keyForValue)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.id)
        XCTAssertNil(result.buffer)
        XCTAssertFalse(hasExecuted)
    }
    func testInitGroupingBy_whenSequenceIsNotEmpty_thenKeyForValueExecutesForEachValueAndReturnsHashTableWithValuesGroupedByKey() {
        var countOfExecutes = 0
        let keyForValue: (Int) -> String = {
            countOfExecutes += 1
            
            return $0 % 2 == 0 ? "Even" : "Odd"
        }
        
        let elements = 1...100
        let expectedResult = Dictionary(grouping: elements, by: keyForValue)
        countOfExecutes = 0
        
        var result = LinearProbingHashTable(grouping: elements, by: keyForValue)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.id)
        XCTAssertNotNil(result.buffer)
        XCTAssertEqual(countOfExecutes, elements.count)
        XCTAssertEqual(result.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<Int>(Array(elements))
        countOfExecutes = 0
        result = LinearProbingHashTable(grouping: seq, by: keyForValue)
        XCTAssertNotNil(result)
        XCTAssertNotNil(result.id)
        XCTAssertNotNil(result.buffer)
        XCTAssertEqual(countOfExecutes, seq.elements.count)
        XCTAssertEqual(result.count, expectedResult.count)
        for (k, v) in expectedResult {
            XCTAssertEqual(result.getValue(forKey: k), v)
        }
    }
    
    func testInitGroupingBy_whenKeyForValueThrows_thenRethrows() {
        let keyForValue: (Int) throws -> String = {
            guard $0 < 30 else { throw err }
            
            return $0 % 2 == 0 ? "Even" : "Odd"
        }
        let elements = 1...100
        
        do {
            let _ = try LinearProbingHashTable(grouping: elements, by: keyForValue)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        // same test when sequence doesn't implement withContiguousStorageIfAvailable
        let seq = Seq<Int>(Array(elements))
        do {
            let _ = try LinearProbingHashTable(grouping: seq, by: keyForValue)
            XCTFail("Has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
}

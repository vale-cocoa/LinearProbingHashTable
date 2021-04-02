//
//  MapValuesFilterTests.swift
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

final class MapValuesFilterTests: BaseLPHTTests {
    func testMapValues_whenIsEmpty_thenTransformNeverExecutesAndReturnsEmptyHashTable() {
        var countOfExecutions = 0
        let transform: (Int) -> String = { _ in
            countOfExecutions += 1
            
            return ""
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        let result = sut.mapValues(transform)
        XCTAssertEqual(countOfExecutions, 0, "transform has executed")
        XCTAssertTrue(result.isEmpty)
    }
    
    func testMapValues_whenIsNotEmpty_thenTransformExecutesOnEveryElementValueAndReturnsHashTableWithMappedValues() {
        var countOfExecutions = 0
        let transform: (Int) -> String = {
            countOfExecutions += 1
            
            return "\($0)"
        }
        whenContainsAllElements()
        
        let result = sut.mapValues(transform)
        XCTAssertEqual(countOfExecutions, sut.count)
        XCTAssertEqual(result.count, sut.count)
        result
            .forEach({
                guard
                    let v = sut.getValue(forKey: $0.key)
                        .map(transform)
                else {
                    XCTFail("result has a key not included in original: \($0.key)")
                    
                    return
                }
                XCTAssertEqual($0.value, v)
            })
    }
    
    func testMapValues_whenTransformThrows_thenRethrows() {
        let transform: (Int) throws -> String = { _ in throw err }
        whenContainsAllElements()
        
        do {
            let _ = try sut.mapValues(transform)
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testCompactMapValues_whenIsEmpty_thenTransformNeverExecutesAndReturnsEmptyHashTable() {
        var countOfExecutions = 0
        let transform: (Int) -> String? = {
            countOfExecutions += 1
            
            return $0 % 2 == 0 ? "\($0)" : nil
        }
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        
        let result = sut.compactMapValues(transform)
        XCTAssertEqual(countOfExecutions, 0, "transform has executed")
        XCTAssertTrue(result.isEmpty)
    }
    
    func testCompactMapValues_whenIsNotEmpty_thenTransformExecutesOnEveryElementValueAndReturnsHashTableWithCompactMappedValues() {
        var countOfExecutions = 0
        let transform: (Int) -> String? = {
            countOfExecutions += 1
            
            return $0 % 2 == 0 ? "\($0)" : nil
        }
        whenContainsAllElements()
        
        let result = sut.compactMapValues(transform)
        XCTAssertEqual(countOfExecutions, sut.count)
        sut
            .forEach({
                if let expectedValue = transform($0.value) {
                    XCTAssertEqual(result.getValue(forKey: $0.key), expectedValue)
                } else {
                    XCTAssertNil(result.getValue(forKey: $0.key))
                }
            })
    }
    
    func testCompactMapValues_whenTransformthrows_thenRethrows() {
        let transform: (Int) throws -> String? = { _ in throw err }
        whenContainsAllElements()
        
        do {
            let _ = try sut.compactMapValues(transform)
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testFilter_whenIsEmpty_thenPredicateNEverExecutesAndReturnsEmptyHashTable() {
        var countOfExecutions = 0
        let predicate: ((key: String, value: Int)) -> Bool = {
            countOfExecutions += 1
            
            return $0.value % 2 == 0 ? true : false
        }
        whenIsEmpty(withCapacity: Int.random(in: 0...10))
        
        let result = sut.filter(predicate)
        XCTAssertEqual(countOfExecutions, 0, "predicate has executed")
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFilter_whenIsNotEmpty_thenPredicateExecutesOnEveryElementAndReturnsHashTableWithFilteredElements() {
        var countOfExecutions = 0
        let predicate: ((key: String, value: Int)) -> Bool = {
            countOfExecutions += 1
            
            return $0.value % 2 == 0 ? true : false
        }
        whenContainsAllElements()
        
        let result = sut.filter(predicate)
        XCTAssertEqual(countOfExecutions, sut.count)
        sut
            .forEach({
                if predicate($0) {
                    XCTAssertEqual(result.getValue(forKey: $0.key), $0.value)
                } else {
                    XCTAssertNil(result.getValue(forKey: $0.key))
                }
            })
    }
    
    func testFilter_whenPredicateThrows_thenRethrows() {
        whenContainsAllElements()
        
        do {
            let _ = try sut.filter({ _ in throw err })
            XCTFail("has not rethrown")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
}

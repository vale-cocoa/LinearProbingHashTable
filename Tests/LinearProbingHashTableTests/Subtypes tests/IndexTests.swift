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
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
    }
    
    func testInitAsStartIndexOf_whenIsNotEmpty() {
        whenContainsHalfElements()
        let m = sut.capacity + 1
        let idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
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
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        idx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
        XCTAssertEqual(idx.bIdx, sut.capacity + 1)
    }
    
    func testInitAsEndIndexOf_whenIsNotEmpty() {
        whenContainsHalfElements()
        let idx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertTrue(idx.id === sut.id, "has not set the right id")
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
                XCTAssertTrue(idx.id === sut.id, "has not set the right id")
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
    
    func testIsValidFor_whenIdIsSameReference_thenReturnsTrue() {
        whenContainsAllElements()
        for (k, _) in sut {
            if
                let idx = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut),
                idx.id === sut.id
            {
                XCTAssertTrue(idx.isValidFor(sut))
            } else {
                XCTFail("init(AsIndexForKey:of:) returned an invalid index or nil")
            }
        }
        let endIdx = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        XCTAssertTrue(endIdx.isValidFor(sut))
    }
    
    func testIsValidFor_whenIdIsDifferentReference_thenReturnsFalse() {
        whenContainsAllElements()
        let other = sut!
        whenContainsHalfElements()
        XCTAssertFalse(sut.id === other.id)
        
        for (k, _) in other {
            if
                let idx = LinearProbingHashTable.Index.init(asIndexForKey: k, of: other),
                idx.id === other.id
            {
                XCTAssertFalse(idx.isValidFor(sut))
            }else {
                XCTFail("init(AsIndexForKey:of:) returned an invalid index or nil")
            }
        }
        let endIndex = LinearProbingHashTable.Index.init(asEndIndexOf: other)
        XCTAssertFalse(endIndex.isValidFor(sut))
    }
    
    func testMoveToNextFor_advancesIndexToNextElementAndFinallyToEndIndexPosition() {
        whenContainsHalfElements()
        let m = sut.capacity + 1
        var idx = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for (k, v) in sut {
            guard
                (0..<m).contains(idx.bIdx)
            else {
               XCTFail("has returned an index out of bounds")
                
                continue
            }
            
            XCTAssertEqual(sut.buffer?.keys[idx.bIdx], k)
            XCTAssertEqual(sut.buffer?.values[idx.bIdx], v)
            idx.moveToNext(for: sut)
            guard
                idx.isValidFor(sut)
            else {
                XCTFail("has returned an invalid index")
                
                continue
            }
        }
        if idx.bIdx == m {
            idx.moveToNext(for: sut)
            XCTAssertTrue(idx.isValidFor(sut))
            XCTAssertEqual(idx.bIdx, m, "gone past endIndex position")
        } else {
            XCTFail("has not advanced to endIndex position")
        }
    }
    
    func testEqual_returnsTrueWhenHaveSameBIdxValue() {
        whenContainsHalfElements()
        var lhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for (k, _) in sut {
            let rhs = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut)!
            guard
                lhs.bIdx == rhs.bIdx
            else  {
                preconditionFailure("indices have not the same bIdx")
            }
            
            XCTAssertEqual(lhs, rhs)
            lhs.moveToNext(for: sut)
        }
        
        let rhs = LinearProbingHashTable.Index.init(asEndIndexOf: sut)
        guard
            lhs.bIdx == rhs.bIdx
        else  {
            preconditionFailure("indices have not the same bIdx")
        }
        
        XCTAssertEqual(lhs, rhs)
    }
    
    func testEqual_returnsFalseWhenHaveDifferentBIdxValue() {
        whenContainsAllElements()
        var lhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for (k, _) in sut {
            lhs.moveToNext(for: sut)
            let rhs = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut)!
            guard
                lhs.bIdx != rhs.bIdx
            else  {
                preconditionFailure("indices have the same bIdx")
            }
            
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    func testIsLessThan_returnsTrueWhenLHSHasBIdxValueLessThanRHS() {
        whenContainsAllElements()
        var rhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for (k, _) in sut {
            rhs.moveToNext(for: sut)
            let lhs = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut)!
            guard
                lhs.bIdx < rhs.bIdx
            else  {
                preconditionFailure("lhs.bIdx is not less than rhs.bIdx")
            }
            
            XCTAssertLessThan(lhs, rhs)
        }
    }
    
    func testIsLessThan_returnsFalseWhenLHSHasBIdxValueGreaterThanOrEqualToRHSBIdx() {
        whenContainsAllElements()
        var rhs = LinearProbingHashTable.Index.init(asStartIndexOf: sut)
        for (k, _) in sut {
            var lhs = LinearProbingHashTable.Index.init(asIndexForKey: k, of: sut)!
            guard
                lhs.bIdx == rhs.bIdx
            else {
                preconditionFailure("lhs.bIdx is not equal to rhs.bIdx")
            }
            
            XCTAssertFalse(lhs < rhs)
            
            lhs.moveToNext(for: sut)
            guard
                lhs.bIdx > rhs.bIdx
            else {
                preconditionFailure("lhs.bIdx is not greater than rhs.bIdx")
            }
            XCTAssertFalse(lhs < rhs)
            
            rhs.moveToNext(for: sut)
        }
    }
    
}

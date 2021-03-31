//
//  HashableConformanceTests.swift
//  LinearProbingHashTableTests
//
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

final class HashableConformanceTests: BaseLPHTTests {
    func testEquatableAndHashable_whenBothAreEmpty_thenAreEqualAndHaveSameHashValues() {
        whenIsEmpty()
        let rhs = LinearProbingHashTable<String, Int>(minimumCapacity: Int.random(in: 1...10))
        assertAreEqualAndHaveSameHashValue(lhs: sut, rhs: rhs, "lhs has nil buffer, rhs has not nil but empty buffer")
    }
    
    func testEquatable_whenCountAreDifferent_thenAreNotEqualAndHaveDifferentHashValues() {
        whenContainsHalfElements()
        var rhs = LinearProbingHashTable<String, Int>(minimumCapacity: Int.random(in: 1...10))
        assertAreNotEqualAndHaveNotSameHashValue(lhs: sut, rhs: rhs, "lhs contains half elements and rhs is empty")
        
        rhs = sut
        whenContainsAllElements()
        assertAreNotEqualAndHaveNotSameHashValue(lhs: sut, rhs: rhs, "lhs contains all elements and rhs contains half elements")
        
        rhs = sut
        whenIsEmpty()
        assertAreNotEqualAndHaveNotSameHashValue(lhs: sut, rhs: rhs, "lhs is empty and rhs contains all elements")
    }
    
    func testEquatable_whenCountIsSameAndElementsAreSameAndInSameOrder_thenAreEqualAndHaveSameHashValue() {
        whenContainsHalfElements()
        let rhsBuffer = sut.buffer?.clone()
        let rhs = LinearProbingHashTable<String, Int>(buffer: rhsBuffer)
        
        assertAreEqualAndHaveSameHashValue(lhs: sut, rhs: rhs)
    }
    
    func testEquatable_whenCountIsSameAndElementsAreSameButInDifferentOrder_orWhenCountIsSameAndElementsAreDifferent_thenAreNotEqualAndHaveDifferentHashValue() {
        whenContainsHalfElements()
        var rhsBuffer = sut.buffer!.clone(newCapacity: sut.capacity * 2)
        var rhs = LinearProbingHashTable<String, Int>(buffer: rhsBuffer)
        
        XCTAssertFalse(sut.buffer!.elementsEqual(rhsBuffer, by: { $0.key == $1.key && $0.value == $1.value }), "failed to create buffer with same elements but in different order")
        assertAreNotEqualAndHaveNotSameHashValue(lhs: sut, rhs: rhs, "lhs and rhs have same count and same elements but in different order ")
        
        rhsBuffer = sut.buffer!.clone()
        for (k, v) in sut { rhsBuffer.updateValue(v + 10, forKey: k) }
        rhs = LinearProbingHashTable(buffer: rhsBuffer)
        XCTAssertFalse(sut.buffer!.elementsEqual(rhsBuffer, by: { $0.key == $1.key && $0.value == $1.value }), "failed to create buffer with same elements count but different elements")
        assertAreNotEqualAndHaveNotSameHashValue(lhs: sut, rhs: rhs, "lhs and rhs have same count but different elements")
    }
    
}



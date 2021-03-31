//
//  IteratorTests.swift
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

final class IteratorTests: XCTestCase {
    var ht: LinearProbingHashTable<String, Int>!
    
    var sut: LinearProbingHashTable<String, Int>.Iterator!
    
    override func setUp() {
        super.setUp()
        
        whenIsIteratorOfEmptyHashTableWithNilBuffer()
    }
    
    override func tearDown() {
        sut = nil
        ht = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenIsIteratorOfEmptyHashTableWithNilBuffer() {
        ht = LinearProbingHashTable<String, Int>()
        sut = ht.makeIterator()
    }
    
    func whenIsIteratorOfEmptyHashTableWithNonNilBuffer() {
        ht = LinearProbingHashTable(minimumCapacity: Int.random(in: 1...10))
        sut = ht.makeIterator()
    }
    
    func whenIsIteratorOfNotEmptyHashTable() {
        let elements = givenKeysAndValuesWithoutDuplicateKeys()
        let buffer = LPHTBuffer<String, Int>(capacity: elements.capacity)
        for (k, v) in elements { buffer.updateValue(v, forKey: k) }
        ht = LinearProbingHashTable(buffer: buffer)
        sut = ht.makeIterator()
    }
    
    func testNext_whenIsIteratorOfEmptyHashTable_thenAlwaysReturnsNil() {
        whenIsIteratorOfEmptyHashTableWithNilBuffer()
        XCTAssertNil(sut.next())
        
        whenIsIteratorOfEmptyHashTableWithNonNilBuffer()
        XCTAssertNil(sut.next())
    }
    
    func testNext_whenIsIteratorOfNonEmptyHashTable_thenReturnsSameElementsOfHashTablesBufferIterator() {
        whenIsIteratorOfNotEmptyHashTable()
        var htBufferIterator = ht.buffer!.makeIterator()
        
        while let sutElement = sut.next() {
            let bufferElement = htBufferIterator.next()
            XCTAssertEqual(sutElement.key, bufferElement?.key)
            XCTAssertEqual(sutElement.value, bufferElement?.value)
        }
        XCTAssertNil(htBufferIterator.next())
    }
    
}

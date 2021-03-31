//
//  SequenceConformanceTests.swift
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

final class SequenceConformanceTests: BaseLPHTTests {
    func testUnderEstimatedCount() {
        whenIsEmpty()
        XCTAssertEqual(sut.underestimatedCount, sut.count)
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertEqual(sut.underestimatedCount, sut.count)
        sut.buffer!.updateValue(randomValue(), forKey: randomKey())
        XCTAssertEqual(sut.underestimatedCount, sut.count)
        
        whenContainsAllElements()
        XCTAssertEqual(sut.underestimatedCount, sut.count)
        
        while let k = containedKeys.randomElement() {
            sut.buffer?.removeElement(withKey: k)
            XCTAssertEqual(sut.underestimatedCount, sut.count)
        }
    }
    
    func testMakeIterator() {
        whenIsEmpty()
        XCTAssertNotNil(sut.makeIterator())
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        XCTAssertNotNil(sut.makeIterator())
        
        whenContainsHalfElements()
        XCTAssertNotNil(sut.makeIterator())
        
        whenContainsAllElements()
        XCTAssertNotNil(sut.makeIterator())
    }
    
    func testFastIteration() {
        whenIsEmpty()
        for _ in  sut {
            XCTFail("should have not returned any element")
        }
        
        whenIsEmpty(withCapacity: Int.random(in: 1...10))
        for _ in sut {
            XCTFail("should have not returned any element")
        }
        
        whenContainsHalfElements()
        var elements = containedElements
        for element in sut {
            if let idx = elements
                .firstIndex(where: { element.key == $0.0 && element.value == $0.1 })
            {
                elements.remove(at: idx)
            }
        }
        XCTAssertTrue(elements.isEmpty)
        
        whenContainsAllElements()
        elements = containedElements
        for element in sut {
            if let idx = elements
                .firstIndex(where: { element.key == $0.0 && element.value == $0.1 })
            {
                elements.remove(at: idx)
            }
        }
        XCTAssertTrue(elements.isEmpty)
    }
    
}

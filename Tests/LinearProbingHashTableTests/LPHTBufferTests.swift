//
//  LPHTBufferTests.swift
//  LinearProbingHashTableTests
//
//  Created by Valeriano Della Longa on 2021/03/27.
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

final class LPHTBufferTests: XCTestCase {
    var sut: LPHTBuffer<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = LPHTBuffer(capacity: 1)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitCapacity() {
        let capacity = Int.random(in: 1...10)
        let m = capacity + 1
        sut = LPHTBuffer(capacity: capacity)
        
        XCTAssertEqual(sut.capacity, capacity)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.startIndex, m)
        for i in 0..<m {
            XCTAssertNil(sut.keys[i])
            XCTAssertNil(sut.values[i])
        }
    }
    
}

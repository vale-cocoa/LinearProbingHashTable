//
//  CodableConformanceTests.swift
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

final class CodableConformanceTests: BaseLPHTTests {
    typealias HashTable = LinearProbingHashTable<String, Int>
    
    func testEncode() {
        let encoder = JSONEncoder()
        
        XCTAssertNoThrow(try encoder.encode(sut))
        
        whenContainsAllElements()
        XCTAssertNoThrow(try encoder.encode(sut))
    }
    
    func testEncodeThenDecode() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        var data = try! encoder.encode(sut)
        var decoded: HashTable!
        do {
            try decoded = decoder.decode(HashTable.self, from: data)
        } catch {
            XCTFail("has thrown error")
            
            return
        }
        XCTAssertTrue(decoded.isEmpty)
        
        whenContainsAllElements()
        data = try! encoder.encode(sut)
        do {
            try decoded = decoder.decode(HashTable.self, from: data)
        } catch {
            XCTFail("has thrown error")
            
            return
        }
        XCTAssertEqual(decoded.count, sut.count)
        for (k, v) in sut {
            XCTAssertEqual(decoded.getValue(forKey: k), v)
        }
    }
    
    func testDecode_whenDataHasDifferentCountForKeysAndValue_thenThrowsError() {
        let data = malformedJSONDataWithKeysAndValuesCountsNotMtching
        
        do {
            try sut = JSONDecoder().decode(HashTable.self, from: data)
        } catch HashTable.Error.differentCountForDecodedKeysAndValues {
            return
        } catch {
            XCTFail("thrown different error")
        }
        XCTFail("not thrown error")
    }
    
    func testDecode_whenDataHasDuplicateKeys_thenThrowsError() {
        let data = malformedJSONDataWithDuplicateKeys
        
        do {
            try sut = JSONDecoder().decode(HashTable.self, from: data)
        } catch HashTable.Error.notUniqueKeys {
            return
        } catch {
            XCTFail("thrown different error")
        }
        XCTFail("not thrown error")
    }
    
}

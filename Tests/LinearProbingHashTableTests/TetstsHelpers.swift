//
//  TestsHelpers.swift
//  LinearProbingHashTableTests
//
//  Created by Valeriano Della Longa on 2021/03/30.
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

// MARK: - Global constants and functions
let uppercaseLetters = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    .components(separatedBy: " ")

let lowerCaseLetters = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
    .components(separatedBy: " ")

let allCasesLetters = uppercaseLetters + lowerCaseLetters

func randomKey(ofLenght l: Int = 1) -> String {
    assert(l > 0)
    var result = ""
    for _ in 1...l {
        result += allCasesLetters.randomElement()!
    }
    
    return result
}

func randomValue() -> Int {
    Int.random(in: 1...300)
}

let err = NSError(domain: "com.vdl.error", code: 1, userInfo: nil)

// MARK: - GIVEN
func givenKeysAndValuesWithoutDuplicateKeys() -> [(key: String, value: Int)] {
    var keysAndValues = Array<(String, Int)>()
    var insertedKeys = Set<String>()
    for _ in 0..<Int.random(in: 10..<20) {
        var newKey = randomKey()
        while insertedKeys.insert(newKey).inserted == false {
            newKey = randomKey()
        }
        keysAndValues.append((newKey, randomValue()))
    }
    
    return keysAndValues
}

func givenKeysAndValuesWithDuplicateKeys() -> [(key: String, value: Int)] {
    var result = givenKeysAndValuesWithoutDuplicateKeys()
    let keys = result.map { $0.0 }
    keys.forEach { result.append(($0, randomValue())) }
    
    return result
}

var malformedJSONDataWithKeysAndValuesCountsNotMtching: Data {
    let kv = [
        "keys" : [ "A", "B", "C", "D", "E",],
        "values": [1, 2, 3, 4, 5, 6, 7],
    ] as [String : Any]
    
    return try! JSONSerialization.data(withJSONObject: kv, options: .prettyPrinted)
}

var malformedJSONDataWithDuplicateKeys: Data {
    let keys = givenKeysAndValuesWithDuplicateKeys().map { $0.key }
    let values = keys.map { _ in randomValue() }
    
    var kv = Dictionary<String, Any>()
    kv["keys"] = keys
    kv["values"] = values
    
    return try! JSONSerialization.data(withJSONObject: kv, options: .prettyPrinted)
}

// MARK: - Types for testing NSCopying
final class CKey: NSCopying, Equatable, Hashable {
    var k: String
    init(_ k: String) { self.k = k }
    
    static func ==(lhs: CKey, rhs: CKey) -> Bool {
        lhs.k == rhs.k
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(k)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let kClone = (k as NSString).copy(with: zone) as! NSString
        
        return CKey(kClone as String)
    }
    
}

final class CValue: NSCopying, Equatable {
    var v: Int
    
    init(_ v: Int) { self.v = v }
    
    static func ==(lhs: CValue, rhs: CValue) -> Bool {
        return lhs.v == rhs.v
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let vClone = (v as NSNumber).copy(with: zone) as! NSNumber
        
        return CValue(vClone.intValue)
    }
    
}

struct SKey: Equatable, Hashable {
    var k: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(k)
    }
    
}

struct SValue: Equatable {
    var v: Int
    
}

// MARK: - Key types with bad hashing
struct VeryBadHashingKey: Equatable, Hashable {
    var k: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("a")
    }
    
}

struct BadHashingKey: Equatable, Hashable {
    var k: String
    
    func hash(into hasher: inout Hasher) {
        let r = Int.random(in: 0...11)
        if r % 2 == 0 {
            hasher.combine(k)
        } else {
            hasher.combine("a")
        }
    }
    
}

struct SomeWhatBadHashingKey: Equatable, Hashable {
    var k: String
    
    func hash(into hasher: inout Hasher) {
        let r = Int.random(in: 0...29)
        if r < 7 {
            hasher.combine("a")
        } else {
            hasher.combine(k)
        }
    }
    
}

// MARK: - Sequence of Key-Value pairs for tests
struct Seq<Element>: Sequence {
    var elements: [Element]
    
    var ucIsZero = true
    
    
    init(_ elements: [Element]) {
        self.elements = elements
    }
    
    var underestimatedCount: Int {
        ucIsZero ? 0 : elements.count / 2
    }
    
    func makeIterator() -> AnyIterator<Element> {
        AnyIterator(elements.makeIterator())
    }
    
}

// MARK: - Asserts
func assertStartIndexIsCorrect<Key: Hashable, Value>(on buffer: LPHTBuffer<Key, Value>, file: StaticString = #file, line: UInt = #line) {
    let m = buffer.capacity + 1
    guard (0...m).contains(buffer.startIndex) else {
        XCTFail("startIndex is out of bounds: \(buffer.startIndex) - bounds: \(0)..<\(m)", file: file, line: line)
        
        return
    }
    
    guard
        !buffer.isEmpty
    else {
        XCTAssertEqual(buffer.startIndex, m, "startIndex is: \(buffer.startIndex), but should be: \(buffer.capacity + 1)", file: file, line: line)
        
        return
    }
    for idx in 0..<buffer.startIndex {
        guard
            buffer.keys[idx] == nil
        else {
            XCTFail("startIndex is: \(buffer.startIndex), but should be: \(idx)", file: file, line: line)
            
            return
        }
    }
    guard
        buffer.keys[buffer.startIndex] != nil
    else {
        for idx in (buffer.startIndex + 1)..<m where buffer.keys[idx] != nil {
            XCTFail("startIndex is: \(buffer.startIndex), but should be: \(idx)", file: file, line: line)
            
            return
        }
        fatalError("Should never reach here cause buffer is not empty, hence there should be an index containing a non-nil key!")
    }
    
}

func assertAreEqualAndHaveSameHashValue<T: Hashable>(lhs: T, rhs: T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(lhs, rhs, "are not equal - \(message)", file: file, line: line)
    
    var hasher = Hasher()
    hasher.combine(lhs)
    let lhsHashValue = hasher.finalize()
    hasher = Hasher()
    hasher.combine(rhs)
    let rhsHashValue = hasher.finalize()
    XCTAssertEqual(lhsHashValue, rhsHashValue, "have not equal hash values - \(message)", file: file, line: line)
}

func assertAreNotEqualAndHaveNotSameHashValue<T: Hashable>(lhs: T, rhs: T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertNotEqual(lhs, rhs, "are equal - \(message)", file: file, line: line)
    var hasher = Hasher()
    hasher.combine(lhs)
    let lhsHashValue = hasher.finalize()
    hasher = Hasher()
    hasher.combine(rhs)
    let rhsHashValue = hasher.finalize()
    XCTAssertNotEqual(lhsHashValue, rhsHashValue, "have equal hash values - \(message)", file: file, line: line)
}

// MARK: - other utitlies for tests
extension LPHTBuffer {
    // Get the initial index for given key without resolve of key collision
    private func _initialIndex(forKey k: Key) -> Int {
        let m = capacity + 1
        var hasher = Hasher()
        hasher.combine(k)
        let hv = hasher.finalize()
        
        return (hv & 0x7fffffff) % m
    }
    
    func keyCollisionsRatio<C: Collection>(onKeys: C, countOfIterations: Int = 1000) -> Double where C.Iterator.Element == Key {
        precondition(countOfIterations > 0)
        var keyCollisions = 0
        for _ in 0..<countOfIterations {
            for k in onKeys.shuffled() {
                let initialIndex = _initialIndex(forKey: k)
                let idx = index(forKey: k)
                if keys[initialIndex] != keys[idx] { keyCollisions += 1 }
            }
        }
        
        return Double(keyCollisions) / Double(onKeys.count * countOfIterations)
    }
}


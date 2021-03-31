//
//  LinearProbingHashTable+Codable.swift
//  LineraProbingHashTable
//
//  Created by Valeriano Della Longa on 2021/03/29.
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

extension LinearProbingHashTable: Codable where Key: Codable, Value: Codable {
    /// Errors thrown when decoding malformed data.
    public enum Error: Swift.Error {
        /// Thrown when decoded keys and decoded values have a different count.
        case differentCountForDecodedKeysAndValues
        
        /// Thrown when decoded data contains duplicate keys.
        case notUniqueKeys
        
    }
    
    enum CodingKeys: CodingKey {
        case keys
        case values
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(keys.map({ $0 }), forKey: .keys)
        try container.encode(values.map({ $0 }), forKey: .values)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let arrayKeys = try container.decode(Array<Key>.self, forKey: .keys)
        let arrayValues = try container.decode(Array<Value>.self, forKey: .values)
        
        guard
            arrayKeys.count == arrayValues.count
        else { throw Error.differentCountForDecodedKeysAndValues }
        
        try self.init(zip(arrayKeys, arrayValues), uniquingKeysWith: { _, _ in throw Error.notUniqueKeys })
    }
    
}


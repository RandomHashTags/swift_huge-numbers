//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

public struct HugeDecimal : Hashable {
    private var value:HugeInt
    /// The infinitely repeating numbers, in reverse order.
    public private(set) var repeating_numbers:[UInt8]?
    
    public init(value: HugeInt, repeating_numbers: [UInt8]? = nil) {
        self.value = value
        self.repeating_numbers = repeating_numbers
    }
    public init(_ string: String, repeating_numbers: [UInt8]? = nil) {
        self.init(value: HugeInt(string), repeating_numbers: repeating_numbers)
    }
    
    /// The number the digits represent.
    public var description : String {
        if let repeating_numbers:[UInt8] = repeating_numbers {
            return value.description + String(repeating_numbers.reversed().map({ $0.repeating_symbol }))
        } else {
            return value.description
        }
    }
}

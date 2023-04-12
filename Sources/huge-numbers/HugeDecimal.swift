//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

public struct HugeDecimal : Hashable {
    private var value:HugeInt
    public private(set) var is_repeating:Bool
    /// The infinitely repeating numbers, in reverse order.
    public private(set) var repeating_numbers:[UInt8]
    
    public init(value: HugeInt, is_repeating: Bool, repeating_numbers: [UInt8]) {
        self.value = value
        self.is_repeating = is_repeating
        self.repeating_numbers = repeating_numbers
    }
    
    /// The number the digits represent.
    public var description : String {
        return value.description + (is_repeating ? String(repeating_numbers.reversed().map({ $0.repeating_symbol })) : "")
    }
}

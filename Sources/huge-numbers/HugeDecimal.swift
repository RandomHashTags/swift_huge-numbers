//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

public struct HugeDecimal : Hashable, Comparable {
    
    public static var zero:HugeDecimal = HugeDecimal("0")
    
    public private(set) var value:HugeInt
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
    
    /// The number the digits represent, in reverse order.
    public var literal_description : String {
        if let repeating_numbers:[UInt8] = repeating_numbers {
            return value.description + String(repeating_numbers.map({ $0.repeating_symbol }))
        } else {
            return value.literal_description
        }
    }
    
    public var to_remainder : HugeRemainder {
        let divisor:String = "1" + (0..<value.length).map({ _ in "0" }).joined()
        return HugeRemainder(dividend: value, divisor: divisor)
    }
}

/*
 Comparable
 */
public extension HugeDecimal {
    static func < (left: HugeDecimal, right: HugeDecimal) -> Bool {
        return left.value < right.value
    }
    static func < (left: HugeDecimal, right: any BinaryInteger) -> Bool {
        return left.value < HugeInt(right)
    }
    
    static func <= (left: HugeDecimal, right: HugeDecimal) -> Bool {
        return left.value <= right.value
    }
    static func <= (left: HugeDecimal, right: any BinaryInteger) -> Bool {
        return left.value < HugeInt(right)
    }
    
    
    static func > (left: HugeDecimal, right: HugeDecimal) -> Bool {
        return left.value > right.value
    }
    static func > (left: HugeDecimal, right: any BinaryInteger) -> Bool {
        return left.value > HugeInt(right)
    }
    
    static func >= (left: HugeDecimal, right: HugeDecimal) -> Bool {
        return left.value >= right.value
    }
    static func >= (left: HugeDecimal, right: any BinaryInteger) -> Bool {
        return left.value >= HugeInt(right)
    }
    
    func is_less_than(_ value: HugeDecimal?) -> Bool {
        if let value:HugeDecimal = value {
            return self < value
        } else {
            return true
        }
    }
    func is_less_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        if let value:HugeDecimal = value {
            return self <= value
        } else {
            return true
        }
    }
    
    func is_greater_than(_ value: HugeDecimal?) -> Bool {
        if let value:HugeDecimal = value {
            return self > value
        } else {
            return true
        }
    }
    func is_greater_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        if let value:HugeDecimal = value {
            return self >= value
        } else {
            return true
        }
    }
}

/*
 Addition
 */
public extension HugeDecimal {
    static func + (left: HugeDecimal, right: HugeDecimal) -> HugeDecimal { // TODO: finish
        return left
    }
}

//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

public struct HugeDecimal : Hashable, Comparable {
    
    public static var zero:HugeDecimal = HugeDecimal(value: HugeInt.zero)
    
    public private(set) var value:HugeInt
    /// The infinitely repeating numbers, in reverse order.
    public private(set) var repeating_numbers:[UInt8]?
    
    public init(value: HugeInt, repeating_numbers: [UInt8]? = nil) {
        self.value = value
        self.repeating_numbers = repeating_numbers
    }
    public init(_ string: String, remove_leading_zeros: Bool = true, repeating_numbers: [UInt8]? = nil) {
        self.init(value: HugeInt(string, remove_leading_zeros: remove_leading_zeros), repeating_numbers: repeating_numbers)
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
    public var description_literal : String {
        if let repeating_numbers:[UInt8] = repeating_numbers {
            return value.description + String(repeating_numbers.map({ $0.repeating_symbol }))
        } else {
            return value.description_literal
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
 Misc
 */
public extension HugeDecimal {
    static prefix func - (value: HugeDecimal) -> HugeDecimal {
        return HugeDecimal(value: -value.value, repeating_numbers: value.repeating_numbers)
    }
}
/*
 Addition
 */
public extension HugeDecimal {
    static func + (left: HugeDecimal, right: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) { // TODO: support addition of repeating numbers
        let left_value:HugeInt = left.value, right_value:HugeInt = right.value
        let decimal_length:Int = max(left_value.length, right_value.length)
        var result:HugeInt = left_value + right_value, result_length:Int = result.length
        var quotient:HugeInt? = nil
        if result_length > decimal_length {
            let difference:Int = result_length - decimal_length
            quotient = HugeInt(is_negative: false, result.numbers[decimal_length..<result_length])
            for _ in 0..<difference {
                result.numbers.removeLast()
            }
        }
        return (HugeDecimal(value: result), quotient)
    }
    
    static func += (left: inout HugeDecimal, right: HugeDecimal) { // TODO: support addition of repeating numbers
        left.value += right.value
    }
}
/*
 Subtraction
 */
public extension HugeDecimal {
    static func - (left: HugeDecimal, right: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) {
        return left + -right
    }
    
    static func -= (left: inout HugeDecimal, right: HugeDecimal) { // TODO: support subtraction of repeating numbers
        left.value -= right.value
    }
}
/*
 Multiplication
 */
public extension HugeDecimal {
    static func * (left: HugeDecimal, right: HugeInt) -> (quotient: HugeInt?, result: HugeDecimal) {
        let result_string:String = HugeDecimal.multiply(left: left.value, right: right, decimal_places: left.value.length)
        let result:HugeFloat = HugeFloat(result_string)
        return (result.integer == HugeInt.zero ? nil : result.integer, result.decimal ?? HugeDecimal.zero)
    }
    static func * (left: HugeDecimal, right: HugeDecimal) -> (quotient: HugeInt?, result: HugeDecimal) {
        let result_string:String = HugeDecimal.multiply(left: left.value, right: right.value, decimal_places: left.value.length + right.value.length)
        let result:HugeFloat = HugeFloat(result_string)
        return (result.integer == HugeInt.zero ? nil : result.integer, result.decimal ?? HugeDecimal.zero)
    }
}
internal extension HugeDecimal {
    static func multiply(left: HugeInt, right: HugeInt, decimal_places: Int) -> String {
        var result_string:String = (left * right).description
        result_string.insert(".", at: result_string.index(result_string.endIndex, offsetBy: -decimal_places))
        if result_string[result_string.startIndex] == "." {
            result_string.insert("0", at: result_string.startIndex)
        }
        return result_string
    }
}

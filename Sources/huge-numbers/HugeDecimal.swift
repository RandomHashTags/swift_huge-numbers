//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

public struct HugeDecimal : Hashable, Comparable, CustomStringConvertible {
    
    public static var zero:HugeDecimal = HugeDecimal(value: HugeInt.zero)
    
    /// The ``HugeInt`` that represents this decimal.
    public private(set) var value:HugeInt
    /// The infinitely repeating numbers, in reverse order.
    public private(set) var repeating_numbers:[Int8]?
    
    public init(value: HugeInt, repeating_numbers: [Int8]? = nil) {
        self.value = value
        self.repeating_numbers = repeating_numbers
    }
    public init<T: StringProtocol & RangeReplaceableCollection>(_ string: T, remove_leading_zeros: Bool = true, repeating_numbers: [Int8]? = nil) {
        self.init(value: HugeInt(string, remove_leading_zeros: remove_leading_zeros), repeating_numbers: repeating_numbers)
    }
    
    /// The number the digits represent.
    public var description : String {
        if let repeating_numbers:[Int8] = repeating_numbers {
            return value.description + String(repeating_numbers.reversed().map({ $0.repeating_symbol }))
        } else {
            return value.description
        }
    }
    
    /// The number the digits represent, in reverse order.
    public var description_literal : String {
        if let repeating_numbers:[Int8] = repeating_numbers {
            return value.description + String(repeating_numbers.map({ $0.repeating_symbol }))
        } else {
            return value.description_literal
        }
    }
    
    /// Whether or not this huge decimal equals zero.
    public var is_zero : Bool {
        return value.is_zero && (repeating_numbers == nil || repeating_numbers!.allSatisfy({ $0 == 0 }))
    }
    
    /// Returns a ``HugeRemainder`` in which the decimal is the _dividend_, and the divisor is _10 to the power of decimal length plus one_.
    public var to_remainder : HugeRemainder {
        var divisor_numbers:[Int8] = [Int8].init(repeating: 0, count: value.length+1)
        divisor_numbers[divisor_numbers.count-1] = 1
        let divisor:HugeInt = HugeInt(is_negative: value.is_negative, divisor_numbers)
        return HugeRemainder(dividend: value, divisor: divisor)
    }
    
    /// Returns the distance to the next whole number.
    public var distance_to_next_quotient : HugeDecimal {
        let value_numbers:[Int8] = value.numbers.reversed()
        var numbers:[Int8] = [Int8].init(repeating: 0, count: value_numbers.count)
        let indices:Range<Int> = value_numbers.indices
        for index in indices {
            numbers[index] = 9 - value_numbers[index]
        }
        numbers[indices.last!] += 1
        return HugeDecimal(value: HugeInt(is_negative: false, numbers.reversed()))
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
    
    func is_less_than(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self < value
    }
    func is_less_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self <= value
    }
}
public extension HugeDecimal {
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
    
    func is_greater_than(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self > value
    }
    func is_greater_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self >= value
    }
}
public extension HugeDecimal {
    static func == (left: HugeDecimal, right: HugeDecimal) -> Bool {
        return left.value == right.value && left.repeating_numbers == right.repeating_numbers
    }
}
/*
 prefixes / postfixes
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
    static func + (left: HugeDecimal, right: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) {
        return HugeDecimal.add(left: left, right: right)
    }
    
    /// - Warning: This doesn't add the resulting quotient to the `left` variable.
    static func += (left: inout HugeDecimal, right: HugeDecimal) { // TODO: support addition of repeating numbers
        left = HugeDecimal.add(left: left, right: right).result
    }
}
internal extension HugeDecimal {
    static func add(left: HugeDecimal, right: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) { // TODO: support addition of repeating numbers
        var left_value:HugeInt = left.value, right_value:HugeInt = right.value
        let decimal_length:Int = max(left_value.length, right_value.length)
        while left_value.length < decimal_length {
            left_value.numbers.insert(0, at: 0)
        }
        while right_value.length < decimal_length {
            right_value.numbers.insert(0, at: 0)
        }
        var result:HugeInt = left_value + right_value, result_length:Int = result.length
        var quotient:HugeInt? = nil
        if result_length > decimal_length {
            let difference:Int = result_length - decimal_length
            quotient = HugeInt(is_negative: false, result.numbers[decimal_length..<result_length])
            for _ in 0..<difference {
                result.numbers.removeLast()
            }
        } else if result_length < decimal_length {
            let array:[Int8] = [Int8].init(repeating: 0, count: decimal_length - result_length)
            result.numbers.append(contentsOf: array)
        }
        return (HugeDecimal(value: result), quotient)
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
        left += -right
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
/*
 Misc
 */
public func abs(_ integer: HugeInt) -> HugeDecimal {
    return HugeDecimal(value: HugeInt(is_negative: false, integer.numbers))
}

//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: expand functionality
/// Default unit is in degrees, or no unit at all (just a raw number).
public struct HugeFloat : Hashable, Comparable {
    
    public static var zero:HugeFloat = HugeFloat(integer: HugeInt.zero)
    public static var one:HugeFloat = HugeFloat(integer: HugeInt.one)
    
    public static var pi:HugeFloat = pi(precision: HugeInt.default_precision)
    public static var pi_100:HugeFloat = HugeFloat("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679")
    
    public static func pi(precision: HugeInt) -> HugeFloat { // TODO: finish
        //let total_precision:HugeInt = precision * 1_000_000
        //let degrees:HugeDecimal = (180 / total_precision).to_decimal()
        //print("HugeFloat;pi;degrees=" + degrees.description)
        /*let four:HugeFloat = HugeFloat("4")
        var pi:HugeFloat = HugeFloat("3")
        var starting_denominator:Int = 4
        for _ in 0..<100 {
            var value:HugeFloat = four / (HugeFloat((starting_denominator-2) * (starting_denominator-1) * starting_denominator))
            pi = pi + value
            starting_denominator += 2
            value = four / (HugeFloat((starting_denominator-2) * (starting_denominator-1) * starting_denominator))
            pi = pi - value
            starting_denominator += 2
        }
        print("HugeFloat;pi=" + pi.description)*/
        
        return HugeFloat.zero
    }
    
    public internal(set) var integer:HugeInt
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    public internal(set) var decimal:HugeDecimal? = nil
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    public internal(set) var remainder:HugeRemainder? = nil
    // TODO: support a square root remainder
    
    public var is_negative : Bool {
        return integer.is_negative
    }
    
    public init(integer: HugeInt, decimal: HugeDecimal? = nil, remainder: HugeRemainder? = nil) {
        self.integer = integer
        self.decimal = decimal
        self.remainder = remainder
    }
    
    public init(_ string: String) {
        self.init(string: string)
    }
    /// This init is only here because Xcode cannot link the ambiguous version.
    public init(string: String) {
        let values:[Substring] = string.split(separator: ".")
        let target_pre_decimal_number:Substring = values[0]
        var target_post_decimal_number:Substring = values.get(1) ?? "0"
        if let exponent_range:Range<Substring.Index> = target_post_decimal_number.rangeOfCharacter(from: ["e", "E"]) {
            let is_negative:Bool = target_pre_decimal_number[target_pre_decimal_number.startIndex] == "-"
            let exponent_string:Substring = target_post_decimal_number[exponent_range.upperBound..<target_post_decimal_number.endIndex]
            target_post_decimal_number = target_post_decimal_number[target_post_decimal_number.startIndex..<exponent_range.lowerBound]
            target_post_decimal_number.remove_trailing_zeros()
            let exponent:Int = Int(exponent_string)!
            if exponent < 0 {
                integer = HugeInt(is_negative: is_negative, [])
                var post_numbers:[UInt8] = [UInt8].init(repeating: 0, count: abs(exponent) + target_post_decimal_number.count)
                var index:Int = target_post_decimal_number.count-1
                for pre_number_char in target_pre_decimal_number {
                    post_numbers[index] = UInt8(exactly: pre_number_char.wholeNumberValue!)!
                    index -= 1
                }
                index = target_post_decimal_number.count
                for post_number_char in target_post_decimal_number {
                    post_numbers[index] = UInt8(exactly: post_number_char.wholeNumberValue!)!
                    index += 1
                }
                decimal = HugeDecimal(value: HugeInt(is_negative: false, post_numbers))
            } else {
                integer = HugeInt(target_pre_decimal_number)
                let decimal_value:HugeInt = HugeInt(target_post_decimal_number, remove_leading_zeros: false)
                decimal = decimal_value.is_zero ? nil : HugeDecimal(value: decimal_value)
            }
        } else if let _:Range<Substring.Index> = string.rangeOfCharacter(from: ["r"]) {
            let values:[Substring] = string.split(separator: "r"), remainder_string:[Substring] = values[1].split(separator: "/")
            integer = HugeInt(values[0])
            decimal = nil
            remainder = HugeRemainder(dividend: HugeInt(remainder_string[0]), divisor: HugeInt(remainder_string[1]))
        } else {
            integer = HugeInt(target_pre_decimal_number)
            target_post_decimal_number.remove_trailing_zeros()
            let decimal_value:HugeInt = HugeInt(target_post_decimal_number, remove_leading_zeros: false)
            decimal = decimal_value.is_zero ? nil : HugeDecimal(value: decimal_value)
        }
    }
    
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    public init(_ float: any FloatingPoint) {
        self.init(String(describing: float))
    }
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    public var represented_float : Float {
        return Float(description) ?? 0
    }
    public var description : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r" + remainder.description
        } else if let decimal:HugeDecimal = decimal {
            suffix = "." + decimal.description
        } else {
            suffix = ""
        }
        return (is_negative ? "-" : "") + integer.description + suffix
    }
    public var description_literal : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r" + remainder.description
        } else {
            suffix = "." + (decimal?.description_literal ?? "0")
        }
        return integer.description_literal + suffix
    }
    
    public var description_simplified : String {
        var description:String = description_literal
        if integer == HugeInt.zero {
            description.removeFirst()
            description.removeFirst()
            var exponent:UInt64 = 1
            while description.first == "0" {
                description.removeFirst()
                exponent += 1
            }
            description.insert(".", at: description.index(description.startIndex, offsetBy: 1))
            description.append("e-" + String(describing: exponent))
        } else {
            description.remove_trailing_zeros()
        }
        return (is_negative ? "-" : "") + description
    }
    
    public func to_radians() -> HugeFloat {
        return self * 0.01745329252
    }
    public func to_degrees(precision: HugeInt = HugeInt.default_precision) -> HugeFloat { // TODO: support trig arithemtic
        return self * (180 / HugeFloat.pi_100)
    }
}
/*
 Comparable
 */
public extension HugeFloat {
    static func == (left: HugeFloat, right: HugeFloat) -> Bool {
        return left.is_negative == right.is_negative && left.decimal == right.decimal && left.integer == right.integer && left.decimal == right.decimal && left.remainder == right.remainder
    }
    static func == (left: HugeFloat, right: HugeInt) -> Bool {
        return left == right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func == (left: HugeFloat, right: any FloatingPoint) -> Bool {
        return left == HugeFloat(right)
    }
    static func == (left: HugeFloat, right: any BinaryInteger) -> Bool {
        return left == HugeFloat(right)
    }
}
public extension HugeFloat {
    static func < (left: HugeFloat, right: HugeFloat) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        let left_pre_decimal_number:HugeInt = left.integer, right_pre_decimal_number:HugeInt = right.integer
        return left_pre_decimal_number < right_pre_decimal_number || left_pre_decimal_number == right_pre_decimal_number && (left.decimal?.is_less_than(right.decimal) ?? left.remainder?.is_less_than(right.remainder) ?? true)
    }
}
/*
 prefixes
 */
public extension HugeFloat {
    static prefix func - (value: HugeFloat) -> HugeFloat {
        return HugeFloat(integer: -value.integer, decimal: value.decimal, remainder: value.remainder)
    }
}
/*
 Addition
 */
public extension HugeFloat {
    static func + (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let bigger_pre_int:HugeInt = left.integer, smaller_pre_int:HugeInt = right.integer
        var (bigger_post_int, smaller_post_int, _):(HugeInt, HugeInt, Bool) = HugeInt.get_bigger_int(left: left.decimal?.value ?? left.remainder?.to_decimal().value ?? HugeInt.zero, right: right.decimal?.value ?? right.remainder?.to_decimal().value ?? HugeInt.zero)
        let result_decimal_count:Int = bigger_post_int.length
        
        while bigger_post_int.length != result_decimal_count {
            bigger_post_int.numbers.insert(0, at: 0)
        }
        while smaller_post_int.length != result_decimal_count {
            smaller_post_int.numbers.insert(0, at: 0)
        }
        
        var pre_decimal_result:HugeInt = bigger_pre_int + smaller_pre_int
        var post_decimal_result:HugeInt = bigger_post_int + smaller_post_int
        
        let moved_decimal_count:Int = post_decimal_result.length - result_decimal_count
        if moved_decimal_count > 0 {
            let moved_decimals:[UInt8] = Array(post_decimal_result.numbers.reversed()[0..<moved_decimal_count])
            pre_decimal_result = HugeInt(is_negative: false, HugeInt.add(left: pre_decimal_result.numbers, right: moved_decimals).result)
            post_decimal_result.numbers.removeLast(moved_decimal_count)
            post_decimal_result.remove_trailing_zeros()
        }
        var decimal_value:HugeDecimal! = HugeDecimal(value: post_decimal_result)
        decimal_value = decimal_value == HugeDecimal.zero ? nil : decimal_value
        return HugeFloat(integer: pre_decimal_result, decimal: decimal_value)
    }
    static func + (left: HugeFloat, right: HugeInt) -> HugeFloat {
        return left + right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func + (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left + HugeFloat(right)
    }
    static func + (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left + HugeFloat(right)
    }
}
/*
 Subtraction
 */
public extension HugeFloat {
    static func - (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        return left + -right
    }
}
/*
 Multiplication
 */
public extension HugeFloat {
    static func * (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        return HugeFloat.multiply(left: left, right: right)
    }
    static func * (left: HugeFloat, right: HugeInt) -> HugeFloat {
        return left * right.to_float
    }
    static func * (left: HugeInt, right: HugeFloat) -> HugeFloat {
        return left.to_float * right
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func * (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left * HugeFloat(right)
    }
    static func * (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left * HugeFloat(right)
    }
    
    static func *= (left: inout HugeFloat, right: HugeFloat) { // TODO: optimize
        left = left * right
    }
    static func *= (left: inout HugeFloat, right: HugeInt) { // TODO: optimize
        left = left * right.to_float
    }
}
internal extension HugeFloat {
    static func multiply(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        if left == HugeFloat.zero || right == HugeFloat.zero {
            return HugeFloat.zero
        } else if left == HugeFloat.one {
            return right
        } else if right == HugeFloat.one {
            return left
        } else if left.decimal != nil || right.decimal != nil {
            return multiply_decimals(left: left, right: right)
        } else if left.remainder != nil || right.remainder != nil {
            return multiply_remainders(left: left, right: right)
        } else {
            return HugeFloat(integer: left.integer * right.integer)
        }
    }
    static func multiply_decimals(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let left_post_number:HugeInt = left.decimal?.value ?? HugeInt.zero
        let right_post_number:HugeInt = right.decimal?.value ?? HugeInt.zero
        
        let result_decimal_places:Int = left_post_number.length + right_post_number.length
        
        var left_numbers:[UInt8] = left_post_number.numbers
        left_numbers.append(contentsOf: left.integer.numbers)
        
        var right_numbers:[UInt8] = right_post_number.numbers
        right_numbers.append(contentsOf: right.integer.numbers)
        
        var result:[UInt8] = HugeInt.multiply(left: left_numbers, right: right_numbers, remove_leading_zeros: false)
        
        let pre_decimal_numbers:ArraySlice<UInt8> = result[result_decimal_places...]
        var integer:HugeInt = HugeInt(is_negative: left.is_negative == !right.is_negative, pre_decimal_numbers)
        integer.remove_leading_zeros()
        
        var removed_zeroes:Int = 0
        while result.first == 0 {
            result.removeFirst()
            removed_zeroes += 1
        }
        let ending_index:Int = max(0, result_decimal_places-removed_zeroes)
        let decimal_numbers:ArraySlice<UInt8> = result[0..<ending_index]
        let decimal:HugeInt = HugeInt(is_negative: false, decimal_numbers)
        return HugeFloat(integer: integer, decimal: HugeDecimal(value: decimal))
    }
    static func multiply_remainders(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let remainder:HugeRemainder = left.remainder ?? HugeRemainder.zero
        let left_integer:HugeInt = left.integer, right_integer:HugeInt = right.integer
        let (left_quotient, left_remainder):(HugeInt, HugeRemainder?) = (remainder * right_integer).to_int
        let right_quotient:HugeInt, right_remainder:HugeRemainder?, multiplied_remainder:HugeRemainder?
        if let target_right_remainder:HugeRemainder = right.remainder {
            (right_quotient, right_remainder) = (target_right_remainder * left_integer).to_int
            multiplied_remainder = remainder * target_right_remainder
        } else {
            (right_quotient, right_remainder) = (HugeInt.zero, nil)
            multiplied_remainder = nil
        }
        let integer:HugeInt = (left_integer * right_integer) + left_quotient + right_quotient
        let total_remainder:HugeRemainder = (left_remainder ?? HugeRemainder.zero) + (right_remainder ?? HugeRemainder.zero) + (multiplied_remainder ?? HugeRemainder.zero)
        return HugeFloat(integer: integer, remainder: total_remainder == HugeRemainder.zero ? nil : total_remainder)
    }
}
/*
 Division
 */
public extension HugeFloat {
    static func / (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let (result, remainder):(HugeInt, HugeRemainder?) = (left.integer / right.integer)
        return HugeFloat(integer: result, remainder: remainder)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left / HugeFloat(right)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: any FloatingPoint, right: HugeFloat) -> HugeFloat {
        return HugeFloat(left) / right
    }
}
/*
 Percent
 */
public extension HugeFloat {
    static func % (left: HugeFloat, right: HugeFloat) -> HugeFloat { // TODO: fix
        let value:HugeInt = left.integer % right.integer
        return HugeFloat(integer: value)
    }
    static func % (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left % HugeFloat(right)
    }
}
/*
 Square root
 */
public extension HugeFloat {
    /// - Parameters:
    ///     - amount: how many times to multiply by itself.
    func squared(amount: UInt64 = 2) -> HugeFloat {
        var result:HugeFloat = self
        for _ in 0..<amount {
            result *= result
        }
        return result
    }
}
/*
 Trigonometry // TODO: support
 SOH - CAH - TOA
 */
/*
/// - Parameters:
///     - x: number in degrees. Must be between 0 and 360.
public func sin(_ x: HugeFloat, precision: HugeInt) -> (value: HugeInt?, decimal: HugeDecimal?) { // TODO: finish
    let result:HugeFloat = x
    var decimal:HugeDecimal? = nil
    print("HugeFloat;sin;x=" + x.description + ";precision=" + precision.description + ";result=" + result.description + ";decimal=\(decimal)")
    return (nil, decimal)
}
/// - Parameters:
///     - x: number in degrees
public func cos(_ x: HugeFloat) -> HugeFloat { // TODO: finish
    return x
}
/// - Parameters:
///     - x: number in degrees
public func tan(_ x: HugeFloat) -> HugeFloat { // TODO: finish
    return x
}
*/

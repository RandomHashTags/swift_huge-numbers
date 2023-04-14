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
    public static var pi:HugeFloat = pi(precision: HugeInt.default_precision)
    public static var pi_100:HugeFloat = HugeFloat("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679")
    
    public static func pi(precision: HugeInt) -> HugeFloat { // TODO: finish
        let degrees:HugeDecimal = (180 / (precision * 1_000_000)).to_decimal()
        print("HugeFloat;pi;degrees=" + degrees.description)
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
        
        return HugeFloat("0")
    }
    
    public internal(set) var integer:HugeInt
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    public internal(set) var decimal:HugeDecimal? = nil
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    public internal(set) var remainder:HugeRemainder? = nil
    
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
                decimal = HugeDecimal(value: HugeInt(target_post_decimal_number, remove_leading_zeros: false))
            }
        } else if let _:Range<Substring.Index> = string.rangeOfCharacter(from: ["r"]) {
            let values:[Substring] = string.split(separator: "r"), remainder_string:[Substring] = values[1].split(separator: "/")
            integer = HugeInt(values[0])
            decimal = nil
            remainder = HugeRemainder(dividend: HugeInt(remainder_string[0]), divisor: HugeInt(remainder_string[1]))
        } else {
            integer = HugeInt(target_pre_decimal_number)
            target_post_decimal_number.remove_trailing_zeros()
            decimal = HugeDecimal(value: HugeInt(target_post_decimal_number, remove_leading_zeros: false))
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
        return (is_negative ? "-" : "") + description_literal
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
        if integer == 0 {
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
        return HugeFloat(integer: pre_decimal_result, decimal: HugeDecimal(value: post_decimal_result))
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
        let left_post_number:HugeInt = left.decimal?.value ?? left.remainder?.to_decimal().value ?? HugeInt.zero
        let right_post_number:HugeInt = right.decimal?.value ?? right.remainder?.to_decimal().value ?? HugeInt.zero
        
        let result_decimal_places:Int = left_post_number.length + right_post_number.length
        
        var left_numbers:[UInt8] = left_post_number.numbers
        left_numbers.append(contentsOf: left.integer.numbers)
        
        var right_numbers:[UInt8] = right_post_number.numbers
        right_numbers.append(contentsOf: right.integer.numbers)
        
        var result:[UInt8] = HugeInt.multiply(left: left_numbers, right: right_numbers)
        
        let is_negative:Bool = left.is_negative == !right.is_negative
        let pre_decimal_numbers:ArraySlice<UInt8> = result[result_decimal_places...]
        let pre_decimal_number:HugeInt = HugeInt(is_negative: is_negative, pre_decimal_numbers)
        
        var removed_zeroes:Int = 0
        while result.first == 0 {
            result.removeFirst()
            removed_zeroes += 1
        }
        let ending_index:Int = max(0, result_decimal_places-removed_zeroes)
        let decimal_numbers:ArraySlice<UInt8> = result[0..<ending_index]
        let decimal:HugeInt = HugeInt(is_negative: false, decimal_numbers)
        
        return HugeFloat(integer: pre_decimal_number, decimal: HugeDecimal(value: decimal))
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
/*
 Division
 */
public extension HugeFloat {
    static func / (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let (result, remainder):(HugeInt, HugeRemainder?) = (left.integer / right.integer).to_int
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
 Trigonometry // TODO: support
 */
/// - Parameters:
///     - x: number in degrees
public func sin(_ x: HugeFloat, precision: HugeInt) -> HugeDecimal { // TODO: finish
    let result:HugeFloat = x / 90
    let decimal:HugeDecimal = result.remainder!.to_decimal(precision: precision)
    
    print("HugeFloat;sin;x=" + x.description + ";precision=" + precision.description + ";result=" + result.description + ";decimal=" + decimal.description)
    return decimal
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

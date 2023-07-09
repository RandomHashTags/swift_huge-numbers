//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: expand functionality
/// Default unit is in degrees, or no unit at all (just a raw number).
public struct HugeFloat : Hashable, Comparable, Codable, CustomStringConvertible {
    
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
    public init(integer: String, decimal: HugeDecimal? = nil, remainder: HugeRemainder? = nil) {
        self.init(integer: HugeInt(integer), decimal: decimal, remainder: remainder)
    }
    
    public init(_ string: String, remove_trailing_zeros: Bool = true) {
        self.init(string: string, remove_trailing_zeros: remove_trailing_zeros)
    }
    /// This init is only here because Xcode cannot link the ambiguous version.
    public init(string: String, remove_trailing_zeros: Bool = true) {
        let values:[Substring] = string.split(separator: ".")
        let target_pre_decimal_number:Substring = values[0]
        var target_post_decimal_number:Substring = values.get(1) ?? "0"
        if let exponent_range:Range<Substring.Index> = target_post_decimal_number.rangeOfCharacter(from: ["e", "E"]) {
            let is_negative:Bool = target_pre_decimal_number[target_pre_decimal_number.startIndex] == "-"
            let exponent_string:Substring = target_post_decimal_number[exponent_range.upperBound..<target_post_decimal_number.endIndex]
            target_post_decimal_number = target_post_decimal_number[target_post_decimal_number.startIndex..<exponent_range.lowerBound]
            if remove_trailing_zeros {
                target_post_decimal_number.remove_trailing_zeros()
            }
            let exponent:Int = Int(exponent_string)!
            if exponent < 0 {
                integer = HugeInt(is_negative: is_negative, [])
                var post_numbers:[Int8] = [Int8].init(repeating: 0, count: abs(exponent) + target_post_decimal_number.count)
                var index:Int = target_post_decimal_number.count-1
                for pre_number_char in target_pre_decimal_number {
                    post_numbers[index] = Int8(exactly: pre_number_char.wholeNumberValue!)!
                    index -= 1
                }
                index = target_post_decimal_number.count
                for post_number_char in target_post_decimal_number {
                    post_numbers[index] = Int8(exactly: post_number_char.wholeNumberValue!)!
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
            if remove_trailing_zeros {
                target_post_decimal_number.remove_trailing_zeros()
            }
            let decimal_value:HugeDecimal = HugeDecimal(target_post_decimal_number, remove_leading_zeros: false)
            decimal = decimal_value.is_zero ? nil : decimal_value
        }
    }
    
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    public init(_ float: any FloatingPoint) {
        self.init(String(describing: float))
    }
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    public init(from decoder: Decoder) throws {
        let container:SingleValueDecodingContainer = try decoder.singleValueContainer()
        let string:String = try container.decode(String.self)
        self.init(string)
    }
    public func encode(to encoder: Encoder) throws {
        var container:SingleValueEncodingContainer = encoder.singleValueContainer()
        try container.encode(description)
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
        return integer.description + suffix
    }
    public var description_literal : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r" + remainder.description
        } else {
            suffix = (decimal != nil ? "." + decimal!.description_literal : "0")
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
        return description
    }
    
    /// Whether or not this huge float equals zero.
    public var is_zero : Bool {
        return integer.is_zero && (remainder == nil || remainder!.is_zero) && (decimal == nil || decimal!.value.is_zero)
    }
    
    /// Optimized version of multiplication when multiplying by 10. Using this function also respects the decimal and remainder.
    public func multiply_by_ten(_ amount: Int) -> HugeFloat {
        if self == HugeFloat.zero {
            return HugeFloat.zero
        } else if decimal != nil {
            return multiply_decimal_by_ten(amount)
        } else if remainder != nil {
            return multiply_remainder_by_ten(amount)
        } else {
            let is_negative:Bool = amount < 0
            let target_amount:Int = is_negative ? abs(amount)-1 : amount
            var numbers:[Int8] = integer.numbers
            for _ in 0..<target_amount {
                numbers.insert(0, at: 0)
            }
            return HugeFloat(integer: HugeInt(is_negative: is_negative == !integer.is_negative, numbers), remainder: remainder)
        }
    }
    /// Multiplies the ``decimal`` by ten to the power of _amount_, potentially removing it if applicable.
    public func multiply_decimal_by_ten(_ amount: Int) -> HugeFloat {
        let is_negative:Bool = amount < 0
        var numbers:[Int8] = integer.numbers
        var decimals:[Int8]! = decimal?.value.numbers.reversed() ?? []
        var remaining_decimals:HugeDecimal? = nil
        if is_negative {
            let absolute_amount:Int = abs(amount)
            if integer.is_zero {
                for _ in 0..<absolute_amount {
                    decimals.append(0)
                }
            } else {
                let numbers_count:Int = numbers.count
                if absolute_amount >= numbers_count {
                    decimals = decimals.reversed()
                    decimals.append(contentsOf: numbers)
                    numbers = []
                    for _ in 0..<absolute_amount-numbers_count {
                        decimals.append(0)
                    }
                } else {
                    for _ in 0..<absolute_amount {
                        let target_number:Int8 = numbers[0]
                        decimals.append(target_number)
                        numbers.removeFirst()
                    }
                    while decimals.first == 0 {
                        decimals.removeLast()
                    }
                }
            }
        } else {
            for i in 0..<amount {
                numbers.insert(decimals.get(i) ?? 0, at: 0)
            }
            decimals = nil
        }
        if decimals != nil && !decimals.isEmpty {
            remaining_decimals = HugeDecimal(value: HugeInt(is_negative: false, decimals))
        }
        return HugeFloat(integer: HugeInt(is_negative: integer.is_negative, numbers), decimal: remaining_decimals)
    }
    /// Returns a new ``HugeFloat`` by multiplying the ``remainder`` by ten to the power of _amount_, potentially removing it if applicable. Also carries over the quotient to the new huge float, if applicable.
    public func multiply_remainder_by_ten(_ amount: Int) -> HugeFloat {
        var remainder:HugeRemainder! = remainder
        guard remainder != nil else { return multiply_by_ten(amount) }
        var integer:HugeInt = integer.multiply_by_ten(amount)
        remainder = remainder.multiply_by_ten(amount)
        if remainder.dividend >= remainder.divisor {
            let (quotient, new_remainder):(HugeInt, HugeRemainder?) = remainder.dividend / remainder.divisor
            integer += quotient
            remainder = new_remainder
        }
        return HugeFloat(integer: integer, remainder: remainder)
    }
    
    public func divide_by(_ value: HugeFloat, precision: HugeInt) -> HugeFloat {
        return HugeFloat.divide(left: self, right: value, precision: precision)
    }
    
    /// Creates a new ``HugeFloat``, and rounds it to the nearest given place.
    /// Converts ``remainder`` to a ``HugeDecimal``, if present.
    public func rounded(_ precision: UInt, remainder_precision: HugeInt = HugeInt.default_precision) -> HugeFloat {
        var decimals:[Int8] = decimal?.value.numbers.reversed() ?? remainder?.to_decimal(precision: remainder_precision).value.numbers.reversed() ?? []
        let decimal_count:Int = decimals.count
        let index:Int = min(Int(precision), decimal_count)
        guard index != decimal_count, index > 0 else { return self }
        var previous_decimals:ArraySlice<Int8> = decimals[0..<index]
        
        for i in index..<decimal_count {
            let target_value:Int8 = decimals[i]
            if target_value != 5 {
                previous_decimals[previous_decimals.count-1] += target_value > 5 ? 1 : 0
                break
            }
        }
        var integer:HugeInt = integer
        while previous_decimals.last ?? 0 > 9 {
            previous_decimals.removeLast()
            if previous_decimals.count > 0 {
                previous_decimals[previous_decimals.count-1] += 1
            } else {
                integer += HugeInt(is_negative: integer.is_negative, [1])
            }
        }
        decimals = Array(previous_decimals).reversed()
        let decimal:HugeDecimal = HugeDecimal(value: HugeInt(is_negative: false, decimals))
        return HugeFloat.init(integer: integer, decimal: decimal.is_zero ? nil : decimal)
    }
    
    
    public func to_radians() -> HugeFloat {
        return self * HugeFloat("0.01745329252")
    }
    public func to_degrees(precision: HugeInt = HugeInt.default_precision) -> HugeFloat { // TODO: support trig arithmetic
        return self * (180 / HugeFloat.pi_100)
    }
}

// MARK: Comparable
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
            return left.is_negative
        }
        let left_integer:HugeInt = left.integer, right_integer:HugeInt = right.integer
        guard left_integer == right_integer else {
            return left_integer < right_integer
        }
        if left.decimal != nil || right.decimal != nil {
            return (left.decimal ?? HugeDecimal.zero).is_less_than(right.decimal)
        } else if left.remainder != nil || right.remainder != nil {
            return (left.remainder ?? HugeRemainder.zero).is_less_than(right.remainder)
        }
        return false
    }
    static func <= (left: HugeFloat, right: HugeFloat) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative
        }
        let left_integer:HugeInt = left.integer, right_integer:HugeInt = right.integer
        guard left_integer == right_integer else {
            return left_integer <= right_integer
        }
        if left.decimal != nil || right.decimal != nil {
            return (left.decimal ?? HugeDecimal.zero).is_less_than_or_equal_to(right.decimal)
        } else if left.remainder != nil || right.remainder != nil {
            return (left.remainder ?? HugeRemainder.zero).is_less_than_or_equal_to(right.remainder)
        }
        return true
    }
}
public extension HugeFloat {
    static func > (left: HugeFloat, right: HugeFloat) -> Bool {
        guard left.is_negative == right.is_negative else {
            return !left.is_negative
        }
        let left_integer:HugeInt = left.integer, right_integer:HugeInt = right.integer
        guard left_integer == right_integer else {
            return left_integer > right_integer
        }
        if left.decimal != nil || right.decimal != nil {
            return (left.decimal ?? HugeDecimal.zero).is_greater_than(right.decimal)
        } else if left.remainder != nil || right.remainder != nil {
            return (left.remainder ?? HugeRemainder.zero).is_greater_than(right.remainder)
        }
        return false
    }
    
    static func >= (left: HugeFloat, right: HugeFloat) -> Bool {
        guard left.is_negative == right.is_negative else {
            return !left.is_negative
        }
        let left_integer:HugeInt = left.integer, right_integer:HugeInt = right.integer
        guard left_integer == right_integer else {
            return left_integer >= right_integer
        }
        if left.decimal != nil || right.decimal != nil {
            return (left.decimal ?? HugeDecimal.zero).is_greater_than_or_equal_to(right.decimal)
        } else if left.remainder != nil || right.remainder != nil {
            return (left.remainder ?? HugeRemainder.zero).is_greater_than_or_equal_to(right.remainder)
        }
        return true
    }
}
/*
 prefixes / postfixes
 */
public extension HugeFloat {
    static prefix func - (value: HugeFloat) -> HugeFloat {
        return HugeFloat(integer: -value.integer, decimal: value.decimal, remainder: value.remainder)
    }
}
/*
 Misc
 */
public func abs(_ float: HugeFloat) -> HugeFloat {
    return HugeFloat(integer: abs(float.integer), decimal: float.decimal, remainder: float.remainder)
}
/*
 Addition
 */
public extension HugeFloat {
    static func + (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        return HugeFloat.add(left: left, right: right)
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
    
    static func += (left: inout HugeFloat, right: HugeFloat) {
        left.integer += right.integer
        if left.decimal == nil && left.remainder == nil {
            if right.decimal != nil {
                left.decimal = right.decimal!
            } else if right.remainder != nil {
                left.remainder = right.remainder!
            }
        } else if let decimal:HugeDecimal = left.decimal {
            let right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
            let (result, quotient):(HugeDecimal, HugeInt?) = decimal + right_decimal
            if let quotient:HugeInt = quotient {
                left.integer += quotient
            }
            left.decimal = result
        } else if left.remainder != nil {
            left.remainder! += right.remainder ?? HugeRemainder.zero
        }
    }
}
internal extension HugeFloat {
    static func add(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        var target_quotient:HugeInt = left.integer + right.integer
        var target_decimal:HugeDecimal? = nil, target_remainder:HugeRemainder? = nil
        if left.decimal == nil && left.remainder == nil {
            if right.decimal != nil {
                target_decimal = right.decimal
            } else if right.remainder != nil {
                target_remainder = right.remainder
            }
        } else if let decimal:HugeDecimal = left.decimal {
            let right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
            let (result, quotient):(HugeDecimal, HugeInt?) = decimal + right_decimal
            if let quotient:HugeInt = quotient {
                target_quotient += quotient
            }
            target_decimal = result
        } else if left.remainder != nil {
            target_remainder = left.remainder! + (right.remainder ?? HugeRemainder.zero)
        }
        if target_decimal?.is_zero ?? false {
            target_decimal = nil
        }
        return HugeFloat(integer: target_quotient, decimal: target_decimal, remainder: target_remainder)
    }
}
/*
 Subtraction
 */
public extension HugeFloat {
    static func - (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        return HugeFloat.subtract(left: left, right: right)
    }
    
    static func -= (left: inout HugeFloat, right: HugeFloat) {
        left = HugeFloat.subtract(left: left, right: right)
    }
}
internal extension HugeFloat {
    static func subtract(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        guard left.is_negative == right.is_negative else {
            let value:HugeFloat
            if left.is_negative || left.integer.is_zero {
                value = add(left: -left, right: right)
            } else {
                value = add(left: left, right: -right)
            }
            return -value
        }
        if left.decimal != nil || right.decimal != nil {
            return subtract_decimals(left: left, right: right)
        } else if left.remainder != nil || right.remainder != nil {
            return subtract_remainders(left: left, right: right)
        } else {
            return HugeFloat(integer: left.integer - right.integer)
        }
    }
    static func subtract_decimals(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        var quotient:HugeInt = left.integer - right.integer
        let target_decimal:HugeDecimal
        let left_decimal:HugeDecimal = left.decimal ?? HugeDecimal.zero, right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
        if left_decimal >= right_decimal {
            target_decimal = (left_decimal - right_decimal).result
        } else if left.is_zero || quotient.is_zero {
            quotient.is_negative = true
            target_decimal = right_decimal
        } else if quotient == left.integer {
            quotient -= HugeInt.one
            target_decimal = (left_decimal + right_decimal.distance_to_next_quotient).result
        } else {
            quotient -= HugeInt.one
            target_decimal = right_decimal.distance_to_next_quotient
        }
        return HugeFloat(integer: quotient, decimal: target_decimal)
    }
    static func subtract_remainders(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        var quotient:HugeInt = left.integer - right.integer
        let left_remainder:HugeRemainder = left.remainder ?? HugeRemainder.zero, right_remainder:HugeRemainder = right.remainder ?? HugeRemainder.zero
        let target_remainder:HugeRemainder?
        if !left_remainder.is_zero && left_remainder >= right_remainder {
            target_remainder = left_remainder - right_remainder
        } else {
            quotient -= HugeInt.one
            target_remainder = left_remainder + right_remainder.distance_to_next_quotient
        }
        return HugeFloat(integer: quotient, remainder: target_remainder)
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
        
        var left_numbers:[Int8] = left_post_number.numbers
        left_numbers.append(contentsOf: left.integer.numbers)
        
        var right_numbers:[Int8] = right_post_number.numbers
        right_numbers.append(contentsOf: right.integer.numbers)
        
        var result:[Int8] = HugeInt.multiply(left: left_numbers, right: right_numbers, remove_leading_zeros: false)
        
        let pre_decimal_numbers:ArraySlice<Int8> = result[result_decimal_places...]
        var integer:HugeInt = HugeInt(is_negative: left.is_negative == !right.is_negative, pre_decimal_numbers)
        integer.remove_leading_zeros()
        
        var removed_zeroes:Int = 0
        while result.first == 0 {
            result.removeFirst()
            removed_zeroes += 1
        }
        let ending_index:Int = max(0, result_decimal_places-removed_zeroes)
        let decimal_numbers:ArraySlice<Int8> = result[0..<ending_index]
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
        return HugeFloat.divide(left: left, right: right, precision: HugeInt.default_precision)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left / HugeFloat(right)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: any FloatingPoint, right: HugeFloat) -> HugeFloat {
        return HugeFloat(left) / right
    }
    
    static func /= (left: inout HugeFloat, right: HugeFloat) {
        left = left / right
    }
}
internal extension HugeFloat {
    static func divide(left: HugeFloat, right: HugeFloat, precision: HugeInt) -> HugeFloat { // TODO: fix (can divide a smaller number [left] by a bigger number [right])
        if left.decimal != nil || right.decimal != nil {
            return HugeFloat.divide_decimals(left: left, right: right, precision: precision)
        } else if left.remainder != nil || right.remainder != nil {
            return HugeFloat.divide_remainders(left: left, right: right)
        } else {
            let (result, remainder):(HugeInt, HugeRemainder?) = (left.integer / right.integer)
            return HugeFloat(integer: result, remainder: remainder)
        }
    }
    static func divide_decimals(left: HugeFloat, right: HugeFloat, precision: HugeInt) -> HugeFloat {
        let left_decimal:HugeDecimal = left.decimal ?? HugeDecimal.zero, right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
        let minimum_decimal_places:Int = max(left_decimal.value.length, right_decimal.value.length)
        let left_value:HugeInt = left.multiply_decimal_by_ten(minimum_decimal_places).integer, right_value:HugeInt = right.multiply_decimal_by_ten(minimum_decimal_places).integer
        let (quotient, remainder):(HugeInt, HugeRemainder?) = left_value / right_value
        return HugeFloat(integer: quotient, decimal: remainder?.to_decimal(precision: precision))
    }
    static func divide_remainders(left: HugeFloat, right: HugeFloat) -> HugeFloat {
        var left_remainder:HugeRemainder = left.remainder ?? HugeRemainder.zero, right_remainder:HugeRemainder = right.remainder ?? HugeRemainder.zero
        let remainder:HugeRemainder = left_remainder.add(left.integer) / right_remainder.add(right.integer)
        let (quotient, new_remainder):(HugeInt, HugeRemainder?) = remainder.to_int
        return HugeFloat(integer: quotient, remainder: new_remainder)
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
/*
 To the power of x
 */
public func pow(_ left: HugeFloat, right: UInt64) -> HugeFloat {
    return left.to_the_power_of(right)
}
public extension HugeFloat {
    func squared() -> HugeFloat {
        return to_the_power_of(2)
    }
    func cubed() -> HugeFloat {
        return to_the_power_of(3)
    }
    
    /// Returns a ``HugeFloat`` taken to a given power.
    /// - Complexity: O(n) where _n_ equals _x_.
    /// - Parameters:
    ///     - x: the amount of times to multiply self by self.
    func to_the_power_of(_ x: UInt64) -> HugeFloat {
        var result:HugeFloat = self
        for _ in 1..<x {
            result *= self
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

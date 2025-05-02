//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

/// Default unit is in degrees, or no unit at all (just a raw number).
public struct HugeFloat : Hashable, Comparable, Codable, CustomStringConvertible {
    
    public static let zero:HugeFloat = HugeFloat(integer: HugeInt.zero)
    public static let one:HugeFloat = HugeFloat(integer: HugeInt.one)
    
    public static let pi:HugeFloat = pi(precision: HugeInt.defaultPrecision)
    public static let pi_100:HugeFloat = HugeFloat("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679")
    
    public static func pi(precision: HugeInt) -> HugeFloat { // TODO: finish
        //let total_precision:HugeInt = precision * 1_000_000
        //let degrees:HugeDecimal = (180 / total_precision).toDecimal()
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
    /// This float can have a populated `decimal` or `remainder`; never both, however, both can be nil.
    public internal(set) var decimal:HugeDecimal? = nil
    /// This float can have a populated `decimal` or `remainder`; never both, however, both can be nil.
    public internal(set) var remainder:HugeRemainder? = nil
    // TODO: support a square root remainder
    
    @inlinable
    public var isNegative : Bool {
        return integer.isNegative
    }
    
    public init(integer: HugeInt, decimal: HugeDecimal? = nil, remainder: HugeRemainder? = nil) {
        self.integer = integer
        self.decimal = decimal?.isZero ?? false ? nil : decimal
        self.remainder = remainder?.isZero ?? false ? nil : remainder
    }
    public init(integer: String, decimal: HugeDecimal? = nil, remainder: HugeRemainder? = nil) {
        self.init(integer: HugeInt(integer), decimal: decimal, remainder: remainder)
    }
    
    public init(_ string: String, removeTrailingZeros: Bool = true) {
        self.init(string: string, removeTrailingZeros: removeTrailingZeros)
    }
    /// This init is only here because Xcode cannot link the ambiguous version.
    public init(string: String, removeTrailingZeros: Bool = true) {
        let values:[Substring] = string.split(separator: ".")
        let target_pre_decimal_number:Substring = values[0]
        var target_post_decimal_number:Substring = values.get(1) ?? "0"
        if let exponent_range:Range<Substring.Index> = target_post_decimal_number.rangeOfCharacter(from: ["e", "E"]) {
            let isNegative:Bool = target_pre_decimal_number[target_pre_decimal_number.startIndex] == "-"
            let exponent_string:Substring = target_post_decimal_number[exponent_range.upperBound..<target_post_decimal_number.endIndex]
            target_post_decimal_number = target_post_decimal_number[target_post_decimal_number.startIndex..<exponent_range.lowerBound]
            if removeTrailingZeros {
                target_post_decimal_number.removeTrailingZeros()
            }
            let exponent:Int = Int(exponent_string)!
            if exponent < 0 {
                integer = HugeInt(isNegative: isNegative, [])
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
                decimal = HugeDecimal(value: HugeInt(isNegative: false, post_numbers))
            } else {
                integer = HugeInt(target_pre_decimal_number)
                let decimal_value:HugeInt = HugeInt(target_post_decimal_number, removeLeadingZeros: false)
                decimal = decimal_value.isZero ? nil : HugeDecimal(value: decimal_value)
            }
        } else if let _:Range<Substring.Index> = string.rangeOfCharacter(from: ["r"]) {
            let values:[Substring] = string.split(separator: "r"), remainder_string:[Substring] = values[1].split(separator: "/")
            integer = HugeInt(values[0])
            decimal = nil
            remainder = HugeRemainder(dividend: HugeInt(remainder_string[0]), divisor: HugeInt(remainder_string[1]))
        } else {
            integer = HugeInt(target_pre_decimal_number)
            if removeTrailingZeros {
                target_post_decimal_number.removeTrailingZeros()
            }
            let decimal_value:HugeDecimal = HugeDecimal(target_post_decimal_number, removeLeadingZeros: false)
            decimal = decimal_value.isZero ? nil : decimal_value
        }
    }
    
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
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
    public var descriptionLiteral : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r" + remainder.description
        } else {
            suffix = (decimal != nil ? "." + decimal!.descriptionLiteral : "0")
        }
        return integer.descriptionLiteral + suffix
    }

    @inlinable
    public var descriptionSimplified : String {
        var description = descriptionLiteral
        if integer == HugeInt.zero {
            var exponent:UInt64 = 1
            var index = description.index(description.startIndex, offsetBy: 2)
            var removed = 2
            while index < description.endIndex, description[index] == "0" {
                removed += 1
                exponent += 1
                description.formIndex(after: &index)
            }
            description.removeFirst(removed)
            description.insert(".", at: description.index(description.startIndex, offsetBy: 1))
            description.append("e-" + String(describing: exponent))
        } else {
            description.removeTrailingZeros()
        }
        return description
    }
    
    /// Whether or not this huge float equals zero.
    @inlinable
    public var isZero: Bool {
        return integer.isZero && (remainder == nil || remainder!.isZero) && (decimal == nil || decimal!.value.isZero)
    }
    
    /// Optimized version of multiplication when multiplying by 10. Using this function also respects the decimal and remainder.
    @inlinable
    public func multiplyByTen(_ amount: Int) -> HugeFloat {
        if self == HugeFloat.zero {
            return HugeFloat.zero
        } else if decimal != nil {
            return multiplyDecimalByTen(amount)
        } else if remainder != nil {
            return multiplyRemainderByTen(amount)
        } else {
            let isNegative = amount < 0
            let targetAmount = abs(amount)
            var numbers = integer.numbers
            for _ in 0..<targetAmount {
                numbers.insert(0, at: 0)
            }
            return HugeFloat(integer: HugeInt(isNegative: isNegative == !integer.isNegative, numbers), remainder: remainder)
        }
    }
    /// Multiplies the `decimal` by ten to the power of _amount_, potentially removing it if applicable.
    public func multiplyDecimalByTen(_ amount: Int) -> HugeFloat {
        let absoluteAmount = abs(amount)
        let isNegative = amount < 0
        var numbers = integer.numbers
        var decimals:[Int8]! = decimal?.value.numbers.reversed() ?? []
        var remainingDecimals:HugeDecimal? = nil
        let decimalsCount = decimals.count
        for i in 0..<decimalsCount {
            numbers.insert(decimals[i], at: 0)
        }
        if decimalsCount <= absoluteAmount {
            decimals = nil
        }
        
        for _ in decimalsCount..<absoluteAmount {
            numbers.insert(0, at: 0)
        }
        if decimals != nil {
            remainingDecimals = HugeDecimal(value: HugeInt(isNegative: false, decimals))
        }
        return HugeFloat(integer: HugeInt(isNegative: isNegative == !integer.isNegative, numbers), decimal: remainingDecimals)
    }
    /// Returns a new `HugeFloat` by moving the `decimal`/`remainder` _amount_ times, potentially removing it if applicable.
    ///
    /// If _amount_ is negative, move lhs, else rhs.
    ///
    /// If `remainder` != nil, it is converted to a `HugeDecimal`.
    public func move_decimal(_ amount: Int, precision: HugeInt = HugeInt.defaultPrecision) -> HugeFloat {
        let isNegative = amount < 0
        var numbers = integer.numbers
        if let decimal = decimal ?? remainder?.toDecimal(precision: precision) {
            var decimalNumbers = decimal.value.numbers
            if isNegative {
                for _ in 0..<abs(amount) {
                    decimalNumbers.append(numbers.isEmpty ? 0 : numbers.removeFirst())
                }
            } else {
                for _ in 0..<amount {
                    numbers.insert(decimalNumbers.isEmpty ? 0 : decimalNumbers.removeLast(), at: 0)
                }
            }
            let remainingDecimal = HugeDecimal(value: HugeInt(isNegative: false, decimalNumbers))
            return HugeFloat(integer: HugeInt(isNegative: integer.isNegative, numbers), decimal: remainingDecimal)
        } else {
            var decimal:HugeDecimal? = nil
            if isNegative {
                let numbersCount = numbers.count
                let absoluteAmount = abs(amount)
                if numbersCount == absoluteAmount {
                    decimal = abs(integer)
                } else if numbersCount >= absoluteAmount {
                    let decimalNumbers = Array(numbers[0..<absoluteAmount])
                    numbers = Array(numbers[absoluteAmount...])
                    decimal = HugeDecimal(value: HugeInt(isNegative: false, decimalNumbers))
                } else {
                    var decimalNumbers = numbers
                    for _ in 0..<absoluteAmount-numbersCount {
                        decimalNumbers.append(0)
                    }
                    numbers = []
                    decimal = HugeDecimal(value: HugeInt(isNegative: false, decimalNumbers))
                }
            } else {
                for _ in 0..<amount {
                    numbers.insert(0, at: 0)
                }
            }
            return HugeFloat(integer: HugeInt(isNegative: integer.isNegative, numbers), decimal: decimal)
        }
    }
    /// Returns a new `HugeFloat` by multiplying the `remainder` by ten to the power of _amount_, potentially removing it if applicable. Also carries over the quotient to the new huge float, if applicable.
    @inlinable
    public func multiplyRemainderByTen(_ amount: Int) -> HugeFloat {
        var remainder:HugeRemainder! = remainder
        guard remainder != nil else { return multiplyByTen(amount) }
        var integer = integer.multiplyByTen(amount)
        remainder = remainder.multiplyByTen(amount)
        if remainder.dividend >= remainder.divisor {
            let (quotient, new_remainder) = remainder.dividend / remainder.divisor
            integer += quotient
            remainder = new_remainder
        }
        return HugeFloat(integer: integer, remainder: remainder)
    }
    
    public func divide_by(_ value: HugeFloat, precision: HugeInt) -> HugeFloat {
        return HugeFloat.divide(lhs: self, rhs: value, precision: precision)
    }
    
    /// Returns a new `HugeFloat`, and rounds it to the nearest given place.
    /// Converts `remainder` to a `HugeDecimal`, if present.
    @inlinable
    public func rounded(_ precision: UInt, remainder_precision: HugeInt = HugeInt.defaultPrecision) -> HugeFloat {
        var decimals = decimal?.value.numbers.reversed() ?? remainder?.toDecimal(precision: remainder_precision).value.numbers.reversed() ?? []
        let decimalCount = decimals.count
        let index = min(Int(precision), decimalCount)
        guard index != decimalCount, index > 0 else { return self }
        var previousDecimals = decimals[0..<index]
        
        for i in index..<decimalCount {
            let targetValue = decimals[i]
            if targetValue != 5 {
                previousDecimals[previousDecimals.count-1] += targetValue > 5 ? 1 : 0
                break
            }
        }
        var integer = integer
        while previousDecimals.last ?? 0 > 9 {
            previousDecimals.removeLast()
            if previousDecimals.count > 0 {
                previousDecimals[previousDecimals.count-1] += 1
            } else {
                integer += HugeInt(isNegative: integer.isNegative, [1])
            }
        }
        decimals = Array(previousDecimals).reversed()
        let decimal = HugeDecimal(value: HugeInt(isNegative: false, decimals))
        return HugeFloat.init(integer: integer, decimal: decimal)
    }

    @inlinable
    public func decimalToRemainder() -> HugeFloat {
        return HugeFloat(integer: integer, remainder: decimal?.toRemainder)
    }

    @inlinable
    public func remainderToDecimal(precision: HugeInt = HugeInt.defaultPrecision) -> HugeFloat {
        return HugeFloat(integer: integer, decimal: remainder?.toDecimal(precision: precision))
    }

    @inlinable
    public func toRadians() -> HugeFloat {
        return self * HugeFloat("0.01745329252")
    }
    @inlinable
    public func toDegrees(precision: HugeInt = HugeInt.defaultPrecision) -> HugeFloat { // TODO: support trig arithmetic
        return self * (180 / HugeFloat.pi_100)
    }
}

// MARK: Comparable
public extension HugeFloat {
    static func == (lhs: HugeFloat, rhs: HugeFloat) -> Bool {
        return lhs.isNegative == rhs.isNegative && lhs.integer == rhs.integer && lhs.decimal == rhs.decimal && lhs.remainder == rhs.remainder
    }
    static func == (lhs: HugeFloat, rhs: HugeInt) -> Bool {
        return lhs == rhs.toFloat
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
    static func == (lhs: HugeFloat, rhs: any FloatingPoint) -> Bool {
        return lhs == HugeFloat(rhs)
    }
    static func == (lhs: HugeFloat, rhs: any BinaryInteger) -> Bool {
        return lhs == HugeFloat(rhs)
    }
}
public extension HugeFloat {
    static func < (lhs: HugeFloat, rhs: HugeFloat) -> Bool {
        guard lhs.isNegative == rhs.isNegative else {
            return lhs.isNegative
        }
        let left_integer:HugeInt = lhs.integer, right_integer:HugeInt = rhs.integer
        guard left_integer == right_integer else {
            return left_integer < right_integer
        }
        if lhs.decimal != nil || rhs.decimal != nil {
            return (lhs.decimal ?? HugeDecimal.zero).is_less_than(rhs.decimal)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return (lhs.remainder ?? HugeRemainder.zero).is_less_than(rhs.remainder)
        }
        return false
    }
    static func <= (lhs: HugeFloat, rhs: HugeFloat) -> Bool {
        guard lhs.isNegative == rhs.isNegative else {
            return lhs.isNegative
        }
        let left_integer:HugeInt = lhs.integer, right_integer:HugeInt = rhs.integer
        guard left_integer == right_integer else {
            return left_integer <= right_integer
        }
        if lhs.decimal != nil || rhs.decimal != nil {
            return (lhs.decimal ?? HugeDecimal.zero).is_less_than_or_equal_to(rhs.decimal)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return (lhs.remainder ?? HugeRemainder.zero).is_less_than_or_equal_to(rhs.remainder)
        }
        return true
    }
}
public extension HugeFloat {
    static func > (lhs: HugeFloat, rhs: HugeFloat) -> Bool {
        guard lhs.isNegative == rhs.isNegative else {
            return !lhs.isNegative
        }
        let left_integer:HugeInt = lhs.integer, right_integer:HugeInt = rhs.integer
        guard left_integer == right_integer else {
            return left_integer > right_integer
        }
        if lhs.decimal != nil || rhs.decimal != nil {
            return (lhs.decimal ?? HugeDecimal.zero).is_greater_than(rhs.decimal)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return (lhs.remainder ?? HugeRemainder.zero).is_greater_than(rhs.remainder)
        }
        return false
    }
    
    static func >= (lhs: HugeFloat, rhs: HugeFloat) -> Bool {
        guard lhs.isNegative == rhs.isNegative else {
            return !lhs.isNegative
        }
        let left_integer:HugeInt = lhs.integer, right_integer:HugeInt = rhs.integer
        guard left_integer == right_integer else {
            return left_integer >= right_integer
        }
        if lhs.decimal != nil || rhs.decimal != nil {
            return (lhs.decimal ?? HugeDecimal.zero).is_greater_than_or_equal_to(rhs.decimal)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return (lhs.remainder ?? HugeRemainder.zero).is_greater_than_or_equal_to(rhs.remainder)
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
    static func + (lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        return HugeFloat.add(lhs: lhs, rhs: rhs)
    }
    static func + (lhs: HugeFloat, rhs: HugeInt) -> HugeFloat {
        return lhs + rhs.toFloat
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
    static func + (lhs: HugeFloat, rhs: any FloatingPoint) -> HugeFloat {
        return lhs + HugeFloat(rhs)
    }
    static func + (lhs: HugeFloat, rhs: any BinaryInteger) -> HugeFloat {
        return lhs + HugeFloat(rhs)
    }
    
    static func += (lhs: inout HugeFloat, rhs: HugeFloat) {
        lhs.integer += rhs.integer
        if lhs.decimal == nil && lhs.remainder == nil {
            if rhs.decimal != nil {
                lhs.decimal = rhs.decimal!
            } else if rhs.remainder != nil {
                lhs.remainder = rhs.remainder!
            }
        } else if let decimal:HugeDecimal = lhs.decimal {
            let right_decimal = rhs.decimal ?? HugeDecimal.zero
            let (result, quotient) = decimal + right_decimal
            if let quotient {
                lhs.integer += quotient
            }
            lhs.decimal = result
        } else if lhs.remainder != nil {
            lhs.remainder! += rhs.remainder ?? HugeRemainder.zero
        }
    }
}
internal extension HugeFloat {
    static func add(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        var target_quotient:HugeInt = lhs.integer + rhs.integer
        var target_decimal:HugeDecimal? = nil, target_remainder:HugeRemainder? = nil
        if lhs.decimal == nil && lhs.remainder == nil {
            if rhs.decimal != nil {
                target_decimal = rhs.decimal
            } else if rhs.remainder != nil {
                target_remainder = rhs.remainder
            }
        } else if let decimal = lhs.decimal {
            let right_decimal = rhs.decimal ?? HugeDecimal.zero
            let (result, quotient) = decimal + right_decimal
            if let quotient = quotient {
                target_quotient += quotient
            }
            target_decimal = result
        } else if lhs.remainder != nil {
            target_remainder = lhs.remainder! + (rhs.remainder ?? HugeRemainder.zero)
        }
        if target_decimal?.isZero ?? false {
            target_decimal = nil
        }
        return HugeFloat(integer: target_quotient, decimal: target_decimal, remainder: target_remainder)
    }
}
/*
 Subtraction
 */
public extension HugeFloat {
    static func - (lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        return HugeFloat.subtract(lhs: lhs, rhs: rhs)
    }
    
    static func -= (lhs: inout HugeFloat, rhs: HugeFloat) {
        lhs = HugeFloat.subtract(lhs: lhs, rhs: rhs)
    }
}
extension HugeFloat {
    static func subtract(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        guard lhs.isNegative == rhs.isNegative else {
            let value:HugeFloat
            if lhs.isNegative || lhs.integer.isZero {
                value = add(lhs: -lhs, rhs: rhs)
            } else {
                value = add(lhs: lhs, rhs: -rhs)
            }
            return -value
        }
        if lhs.decimal != nil || rhs.decimal != nil {
            return subtract_decimals(lhs: lhs, rhs: rhs)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return subtract_remainders(lhs: lhs, rhs: rhs)
        } else {
            return HugeFloat(integer: lhs.integer - rhs.integer)
        }
    }
    static func subtract_decimals(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        var quotient = lhs.integer - rhs.integer
        let target_decimal:HugeDecimal
        let left_decimal = lhs.decimal ?? HugeDecimal.zero
        let right_decimal = rhs.decimal ?? HugeDecimal.zero
        if left_decimal >= right_decimal {
            target_decimal = (left_decimal - right_decimal).result
        } else if lhs.isZero || quotient.isZero {
            quotient.sign = .minus
            target_decimal = right_decimal
        } else if quotient == lhs.integer {
            quotient -= HugeInt.one
            target_decimal = (left_decimal + right_decimal.distance_to_next_quotient).result
        } else {
            quotient -= HugeInt.one
            target_decimal = right_decimal.distance_to_next_quotient
        }
        return HugeFloat(integer: quotient, decimal: target_decimal)
    }
    static func subtract_remainders(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        var quotient:HugeInt = lhs.integer - rhs.integer
        let left_remainder = lhs.remainder ?? HugeRemainder.zero
        let right_remainder = rhs.remainder ?? HugeRemainder.zero
        let target_remainder:HugeRemainder?
        if !left_remainder.isZero && left_remainder >= right_remainder {
            target_remainder = left_remainder - right_remainder
        } else {
            quotient -= HugeInt.one
            target_remainder = left_remainder + right_remainder.distance_to_next_quotient
        }
        return HugeFloat(integer: quotient, remainder: target_remainder)
    }
}

// MARK: Multiplication
extension HugeFloat {
    public static func * (lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        return HugeFloat.multiply(lhs: lhs, rhs: rhs)
    }
    @inlinable
    public static func * (lhs: HugeFloat, rhs: HugeInt) -> HugeFloat {
        return lhs * rhs.toFloat
    }
    @inlinable
    public static func * (lhs: HugeInt, rhs: HugeFloat) -> HugeFloat {
        return lhs.toFloat * rhs
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
    @inlinable
    public static func * (lhs: HugeFloat, rhs: any FloatingPoint) -> HugeFloat {
        return lhs * HugeFloat(rhs)
    }
    @inlinable
    public static func * (lhs: HugeFloat, rhs: any BinaryInteger) -> HugeFloat {
        return lhs * HugeFloat(rhs)
    }
    
    @inlinable
    public static func *= (lhs: inout HugeFloat, rhs: HugeFloat) { // TODO: optimize
        lhs = lhs * rhs
    }
    @inlinable
    public static func *= (lhs: inout HugeFloat, rhs: HugeInt) { // TODO: optimize
        lhs = lhs * rhs.toFloat
    }
}
extension HugeFloat {
    static func multiply(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        if lhs == HugeFloat.zero || rhs == HugeFloat.zero {
            return HugeFloat.zero
        } else if lhs == HugeFloat.one {
            return rhs
        } else if rhs == HugeFloat.one {
            return lhs
        } else if lhs.decimal != nil || rhs.decimal != nil || lhs.remainder != nil || rhs.remainder != nil {
            return multiply_remainders(lhs: lhs, rhs: rhs)
        } else {
            return HugeFloat(integer: lhs.integer * rhs.integer)
        }
    }
    static func multiply_decimals(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        let left_post_number = lhs.decimal?.value ?? HugeInt.zero
        let right_post_number = rhs.decimal?.value ?? HugeInt.zero
        
        let result_decimal_places = left_post_number.length + right_post_number.length
        
        var leftNumbers = left_post_number.numbers
        leftNumbers.append(contentsOf: lhs.integer.numbers)
        
        var rightNumbers = right_post_number.numbers
        rightNumbers.append(contentsOf: rhs.integer.numbers)
        
        var result = HugeInt.multiply(lhs: leftNumbers, rhs: rightNumbers, removeLeadingZeros: false)
        
        let pre_decimal_numbers = result[result_decimal_places...]
        var integer = HugeInt(isNegative: lhs.isNegative == !rhs.isNegative, pre_decimal_numbers)
        integer.removeLeadingZeros()
        
        var removedZeroes:Int = 0
        while result.first == 0 {
            result.removeFirst()
            removedZeroes += 1
        }
        let endingIndex = max(0, result_decimal_places-removedZeroes)
        let decimalNumbers = result[0..<endingIndex]
        let decimal = HugeInt(isNegative: false, decimalNumbers)
        return HugeFloat(integer: integer, decimal: HugeDecimal(value: decimal))
    }
    static func multiply_remainders(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        let remainder = lhs.decimal?.toRemainder ?? lhs.remainder ?? HugeRemainder.zero
        let left_integer = lhs.integer
        let right_integer = rhs.integer
        let (left_quotient, left_remainder) = (remainder * right_integer).toInt
        let right_quotient:HugeInt
        let right_remainder:HugeRemainder?
        let multiplied_remainder:HugeRemainder?
        if let target_right_remainder = rhs.decimal?.toRemainder ?? rhs.remainder {
            (right_quotient, right_remainder) = (target_right_remainder * left_integer).toInt
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

// MARK: Division
extension HugeFloat {
    public static func / (lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        return HugeFloat.divide(lhs: lhs, rhs: rhs, precision: HugeInt.defaultPrecision)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
    @inlinable
    public static func / (lhs: HugeFloat, rhs: any FloatingPoint) -> HugeFloat {
        return lhs / HugeFloat(rhs)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use `HugeFloat/init(string:)` for literal representation.
    @inlinable
    public static func / (lhs: any FloatingPoint, rhs: HugeFloat) -> HugeFloat {
        return HugeFloat(lhs) / rhs
    }
    
    @inlinable
    public static func /= (lhs: inout HugeFloat, rhs: HugeFloat) {
        lhs = lhs / rhs
    }
}
internal extension HugeFloat {
    static func divide(lhs: HugeFloat, rhs: HugeFloat, precision: HugeInt) -> HugeFloat { // TODO: fix (can divide a smaller number [lhs] by a bigger number [rhs])
        if lhs.decimal != nil || rhs.decimal != nil {
            return HugeFloat.divideDecimals(lhs: lhs, rhs: rhs, precision: precision)
        } else if lhs.remainder != nil || rhs.remainder != nil {
            return HugeFloat.divideRemainders(lhs: lhs, rhs: rhs)
        } else {
            let (result, remainder) = (lhs.integer / rhs.integer)
            return HugeFloat(integer: result, remainder: remainder)
        }
    }
    static func divideDecimals(lhs: HugeFloat, rhs: HugeFloat, precision: HugeInt) -> HugeFloat {
        let left_decimal = lhs.decimal ?? HugeDecimal.zero
        let right_decimal = rhs.decimal ?? HugeDecimal.zero
        let minDecimalPlaces = max(left_decimal.value.length, right_decimal.value.length)
        let leftValue = lhs.multiplyDecimalByTen(minDecimalPlaces).integer
        let rightValue = rhs.multiplyDecimalByTen(minDecimalPlaces).integer
        let (quotient, remainder) = leftValue / rightValue
        return HugeFloat(integer: quotient, decimal: remainder?.toDecimal(precision: precision))
    }
    static func divideRemainders(lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat {
        var left_remainder = lhs.remainder ?? HugeRemainder.zero
        var right_remainder = rhs.remainder ?? HugeRemainder.zero
        let remainder = left_remainder.add(lhs.integer) / right_remainder.add(rhs.integer)
        let (quotient, new_remainder) = remainder.toInt
        return HugeFloat(integer: quotient, remainder: new_remainder)
    }
}

// MARK: Percent
extension HugeFloat {
    @inlinable
    public static func % (lhs: HugeFloat, rhs: HugeFloat) -> HugeFloat { // TODO: fix
        let value:HugeInt = lhs.integer % rhs.integer
        return HugeFloat(integer: value)
    }
    @inlinable
    public static func % (lhs: HugeFloat, rhs: any BinaryInteger) -> HugeFloat {
        return lhs % HugeFloat(rhs)
    }
}
// MARK: Square root





// MARK: To the power of
public func pow(_ lhs: HugeFloat, rhs: UInt64) -> HugeFloat {
    return lhs.toThePowerOf(rhs)
}
extension HugeFloat {
    @inlinable
    public func squared() -> HugeFloat {
        return toThePowerOf(2)
    }
    @inlinable
    public func cubed() -> HugeFloat {
        return toThePowerOf(3)
    }
    
    /// Returns a `HugeFloat` taken to a given power.
    /// - Complexity: O(n) where _n_ equals _x_.
    /// - Parameters:
    ///     - x: the amount of times to multiply self by self.
    @inlinable
    public func toThePowerOf(_ x: UInt64) -> HugeFloat {
        var result = self
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

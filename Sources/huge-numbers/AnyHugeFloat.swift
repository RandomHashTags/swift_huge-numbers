//
//  AnyHugeFloat.swift
//
//
//  Created by Evan Anderson on 7/8/23.
//

import Foundation

// MARK: AnyHugeFloat
public protocol AnyHugeFloat : AnyHugeNumber {
    var integer_generic : any SomeHugeInt { get set }
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    var decimal : HugeDecimal? { get set }
    /// This float can have a populated ``decimal`` or ``remainder``; never both, however, both can be nil.
    var remainder : HugeRemainder? { get set }
    
    init(integer: AnyHugeInt)
    init(integer: AnyHugeInt, decimal: HugeDecimal?, remainder: HugeRemainder?)
    init(_ float: any FloatingPoint)
    
    var represented_float : Float? { get }
    var represented_double : Double? { get }
    
    /// Creates a new ``Self``, and rounds it to the nearest given place.
    /// Converts ``remainder`` to a ``HugeDecimal``, if present.
    func rounded(_ precision: UInt, remainder_precision: AnyHugeInt)
    
    func elementsEqual(_ value: AnyHugeFloat) -> Bool
    func is_less_than(_ value: AnyHugeFloat) -> Bool
    func is_less_than_or_equal_to(_ value: AnyHugeFloat) -> Bool
    func is_greater_than(_ value: AnyHugeFloat) -> Bool
    func is_greater_than_or_equal_to(_ value: AnyHugeFloat) -> Bool
}
public extension AnyHugeFloat {
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``AnyHugeNumber/init(string:)`` for literal representation.
    init(_ float: any FloatingPoint) {
        self.init(String(describing: float))
    }
    
    var description : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r\(remainder)"
        } else if let decimal:HugeDecimal = decimal {
            suffix = ".\(decimal)"
        } else {
            suffix = ""
        }
        return "\(integer_generic)" + suffix
    }
    
    var is_zero : Bool {
        return integer_generic.is_zero && (remainder == nil || remainder!.is_zero) && (decimal == nil || decimal!.value.is_zero)
    }
    
    func flipped_sign() -> Self {
        return Self(integer: integer_generic.flipped_sign(), decimal: decimal, remainder: remainder)
    }
    
    var represented_float : Float? {
        return Float(description)
    }
    var represented_double : Double? {
        return Double(description)
    }
    
    func rounded(_ precision: UInt, remainder_precision: AnyHugeInt) -> Self {
        var decimals:[Int8] = decimal?.value.numbers.reversed() ?? remainder?.to_decimal(precision: remainder_precision).value.numbers.reversed() ?? []
        let decimal_count:Int = decimals.count
        let index:Int = min(Int(precision), decimal_count)
        guard index != decimal_count, index > 0 else { return Self(integer: integer_generic, decimal: decimal, remainder: remainder) }
        var previous_decimals:ArraySlice<Int8> = decimals[0..<index]
        
        for i in index..<decimal_count {
            let target_value:Int8 = decimals[i]
            if target_value != 5 {
                previous_decimals[previous_decimals.count-1] += target_value > 5 ? 1 : 0
                break
            }
        }
        var integer:any SomeHugeInt = integer_generic
        while previous_decimals.last ?? 0 > 9 {
            previous_decimals.removeLast()
            if previous_decimals.count > 0 {
                previous_decimals[previous_decimals.count-1] += 1
            } else {
                integer.add(HugeInt(is_negative: integer.is_negative, [1]))
            }
        }
        decimals = Array(previous_decimals).reversed()
        let decimal:HugeDecimal = HugeDecimal(value: HugeInt(is_negative: false, decimals))
        return Self(integer: integer, decimal: decimal.is_zero ? nil : decimal, remainder: nil)
    }
    
    func elementsEqual(_ value: AnyHugeFloat) -> Bool {
        return is_negative == value.is_negative && decimal == value.decimal && integer_generic.elementsEqual(value.integer_generic) && remainder == value.remainder
    }
    func is_less_than(_ value: AnyHugeFloat) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative
        }
        let left_integer:any SomeHugeInt = integer_generic, right_integer:any SomeHugeInt = value.integer_generic
        guard left_integer.elementsEqual(right_integer) else {
            return left_integer.is_less_than(right_integer)
        }
        if decimal != nil || value.decimal != nil {
            return (decimal ?? HugeDecimal.zero).is_less_than(value.decimal)
        } else if remainder != nil || value.remainder != nil {
            return (remainder ?? HugeRemainder.zero).is_less_than(value.remainder)
        }
        return false
    }
    func is_less_than_or_equal_to(_ value: AnyHugeFloat) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative
        }
        let left_integer:any SomeHugeInt = integer_generic, right_integer:any SomeHugeInt = value.integer_generic
        guard left_integer.elementsEqual(right_integer) else {
            return left_integer.is_less_than_or_equal_to(right_integer)
        }
        if decimal != nil || value.decimal != nil {
            return (decimal ?? HugeDecimal.zero).is_less_than_or_equal_to(value.decimal)
        } else if remainder != nil || value.remainder != nil {
            return (remainder ?? HugeRemainder.zero).is_less_than_or_equal_to(value.remainder)
        }
        return true
    }
    func is_greater_than(_ value: AnyHugeFloat) -> Bool {
        guard is_negative == value.is_negative else {
            return !is_negative
        }
        let left_integer:any SomeHugeInt = integer_generic, right_integer:any SomeHugeInt = value.integer_generic
        guard left_integer.elementsEqual(right_integer) else {
            return left_integer.is_greater_than(right_integer)
        }
        if decimal != nil || value.decimal != nil {
            return (decimal ?? HugeDecimal.zero).is_greater_than(value.decimal)
        } else if remainder != nil || value.remainder != nil {
            return (remainder ?? HugeRemainder.zero).is_greater_than(value.remainder)
        }
        return false
    }
    func is_greater_than_or_equal_to(_ value: AnyHugeFloat) -> Bool {
        guard is_negative == value.is_negative else {
            return !is_negative
        }
        let left_integer:any SomeHugeInt = integer_generic, right_integer:any SomeHugeInt = value.integer_generic
        guard left_integer.elementsEqual(right_integer) else {
            return left_integer.is_greater_than_or_equal_to(right_integer)
        }
        if decimal != nil || value.decimal != nil {
            return (decimal ?? HugeDecimal.zero).is_greater_than_or_equal_to(value.decimal)
        } else if remainder != nil || value.remainder != nil {
            return (remainder ?? HugeRemainder.zero).is_greater_than_or_equal_to(value.remainder)
        }
        return true
    }
}

public func abs<T: SomeHugeFloat>(_ float: T) -> T {
    return T(integer: abs(float.integer_generic), decimal: float.decimal, remainder: float.remainder)
}

// MARK: SomeHugeFloat
public protocol SomeHugeFloat : AnyHugeFloat, HugeNumber {
    associatedtype IntegerType : SomeHugeInt
    
    var integer : IntegerType { get set }
}

public extension SomeHugeFloat {
    /// Optimized version of multiplication when multiplying by 10. Using this function also respects the decimal and remainder.
    func multiply_by_ten(_ amount: Int) -> Self {
        if self.is_zero {
            return Self.zero
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
            return Self(integer: IntegerType(is_negative: is_negative == !integer.is_negative, numbers), decimal: nil, remainder: remainder)
        }
    }
    /// Multiplies the ``decimal`` by ten to the power of _amount_, potentially removing it if applicable.
    func multiply_decimal_by_ten(_ amount: Int) -> Self {
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
        return Self(integer: HugeInt(is_negative: integer.is_negative, numbers), decimal: remaining_decimals, remainder: nil)
    }
    
    /// Returns a new ``Self`` by multiplying the ``remainder`` by ten to the power of _amount_, potentially removing it if applicable. Also carries over the quotient to the new huge float, if applicable.
    func multiply_remainder_by_ten(_ amount: Int) -> Self {
        var remainder:HugeRemainder! = remainder
        guard remainder != nil else { return multiply_by_ten(amount) }
        var integer:IntegerType = integer.multiplied_by_ten(amount)
        remainder = remainder.multiply_by_ten(amount)
        if remainder.dividend.is_greater_than_or_equal_to(remainder.divisor) {
            let (quotient, new_remainder):(AnyHugeInt, HugeRemainder?) = remainder.dividend / remainder.divisor
            integer.add(quotient)
            remainder = new_remainder
        }
        return Self(integer: integer, decimal: nil, remainder: remainder)
    }
}

// MARK: SomeHugeFloat prefixes/postfixes
public extension SomeHugeFloat {
    static prefix func - (value: Self) -> Self {
        return Self(integer: value.integer.flipped_sign(), decimal: value.decimal, remainder: value.remainder)
    }
}

// MARK: SomeHugeFloat Comparable
public extension SomeHugeFloat {
    static func == (left: Self, right: AnyHugeFloat) -> Bool {
        return left.elementsEqual(right)
    }
    static func == (left: Self, right: HugeInt) -> Bool {
        return left == right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func == (left: Self, right: any FloatingPoint) -> Bool {
        return left == Self(right)
    }
    static func == (left: Self, right: any BinaryInteger) -> Bool {
        return left == HugeFloat(right)
    }
}
public extension SomeHugeFloat {
    static func < (left: Self, right: AnyHugeFloat) -> Bool {
        return left.is_less_than(right)
    }
    static func <= (left: Self, right: AnyHugeFloat) -> Bool {
        return left.is_less_than_or_equal_to(right)
    }
    
    static func > (left: Self, right: AnyHugeFloat) -> Bool {
        return left.is_greater_than(right)
    }
    static func >= (left: Self, right: AnyHugeFloat) -> Bool {
        return left.is_greater_than_or_equal_to(right)
    }
}

// MARK: SomeHugeFloat addition
public extension SomeHugeFloat {
    static func + (left: Self, right: AnyHugeFloat) -> Self {
        return add(left: left, right: right)
    }
    static func + (left: Self, right: AnyHugeInt) -> Self {
        return left + right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func + (left: Self, right: any FloatingPoint) -> Self {
        return left + Self(right)
    }
    static func + (left: Self, right: any BinaryInteger) -> Self {
        return left + Self(right)
    }
    
    static func += (left: inout Self, right: AnyHugeFloat) {
        left.integer.add(right.integer_generic)
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
                left.integer.add(quotient)
            }
            left.decimal = result
        } else if left.remainder != nil {
            left.remainder! += right.remainder ?? HugeRemainder.zero
        }
    }
}
public extension SomeHugeFloat {
    static func add(left: Self, right: AnyHugeFloat) -> Self {
        var target_quotient:IntegerType = left.integer + right.integer_generic
        var target_decimal:HugeDecimal? = nil, target_remainder:HugeRemainder? = nil
        if left.decimal == nil && left.remainder == nil {
            if right.decimal != nil {
                target_decimal = right.decimal
            } else if right.remainder != nil {
                target_remainder = right.remainder
            }
        } else if let decimal:HugeDecimal = left.decimal {
            let right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
            let (result, quotient):(HugeDecimal, AnyHugeInt?) = decimal + right_decimal
            if let quotient:AnyHugeInt = quotient {
                target_quotient += quotient
            }
            target_decimal = result
        } else if left.remainder != nil {
            target_remainder = left.remainder! + (right.remainder ?? HugeRemainder.zero)
        }
        if target_decimal?.is_zero ?? false {
            target_decimal = nil
        }
        return Self(integer: target_quotient, decimal: target_decimal, remainder: target_remainder)
    }
}

// MARK: SomeHugeFloat subtraction
public extension SomeHugeFloat {
    static func - (left: Self, right: AnyHugeFloat) -> Self {
        return subtract(left: left, right: right)
    }
    
    static func -= (left: inout Self, right: AnyHugeFloat) {
        left = subtract(left: left, right: right)
    }
}
public extension SomeHugeFloat {
    static func subtract(left: Self, right: AnyHugeFloat) -> Self {
        guard left.is_negative == right.is_negative else {
            let value:Self
            if left.is_negative || left.integer.is_zero {
                value = add(left: -left, right: right)
            } else {
                value = add(left: left, right: right.flipped_sign())
            }
            return -value
        }
        if left.decimal != nil || right.decimal != nil {
            return subtract_decimals(left: left, right: right)
        } else if left.remainder != nil || right.remainder != nil {
            return subtract_remainders(left: left, right: right)
        } else {
            return Self(integer: left.integer - right.integer_generic)
        }
    }
    static func subtract_decimals(left: Self, right: AnyHugeFloat) -> Self {
        var quotient:IntegerType = left.integer - right.integer_generic
        let target_decimal:HugeDecimal
        let left_decimal:HugeDecimal = left.decimal ?? HugeDecimal.zero, right_decimal:HugeDecimal = right.decimal ?? HugeDecimal.zero
        if left_decimal >= right_decimal {
            target_decimal = (left_decimal - right_decimal).result
        } else if left.is_zero || quotient.is_zero {
            quotient.is_negative = true
            target_decimal = right_decimal
        } else if quotient == left.integer {
            quotient.subtract(IntegerType.one)
            target_decimal = (left_decimal + right_decimal.distance_to_next_quotient).result
        } else {
            quotient.subtract(IntegerType.one)
            target_decimal = right_decimal.distance_to_next_quotient
        }
        return Self(integer: quotient, decimal: target_decimal, remainder: nil)
    }
    static func subtract_remainders(left: Self, right: AnyHugeFloat) -> Self {
        var quotient:IntegerType = left.integer - right.integer_generic
        let left_remainder:HugeRemainder = left.remainder ?? HugeRemainder.zero, right_remainder:HugeRemainder = right.remainder ?? HugeRemainder.zero
        let target_remainder:HugeRemainder?
        if !left_remainder.is_zero && left_remainder >= right_remainder {
            target_remainder = left_remainder - right_remainder
        } else {
            quotient.subtract(IntegerType.one)
            target_remainder = left_remainder + right_remainder.distance_to_next_quotient
        }
        return Self(integer: quotient, decimal: nil, remainder: target_remainder)
    }
}

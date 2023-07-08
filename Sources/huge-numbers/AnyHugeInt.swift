//
//  AnyHugeInt.swift
//  
//
//  Created by Evan Anderson on 7/7/23.
//

import Foundation

// MARK: AnyHugeInt
public protocol AnyHugeInt : AnyHugeNumber {
    /// The 8-bit numbers representing this huge integer, in reverse order.
    var numbers : [Int8] { get set }
    
    init(_ integer: any BinaryInteger)
    init(_ integer: AnyHugeInt)
    init(is_negative: Bool, _ numbers: [Int8])
    
    /// The amount of digits that represent this huge integer.
    var length : Int { get }
    
    /// Whether or not all the digits that represent this huge integer satisfy a predicate.
    func all_digits_satisfy(_ transform: (Int8) -> Bool) -> Bool
    
    /// Converts this huge integer to a native integer, if possible.
    func to_int<T: BinaryInteger & LosslessStringConvertible>() -> T?
    
    /// Converts this huge integer to a ``AnyHugeFloat``.
    var to_float : AnyHugeFloat { get }
    
    /// Add a ``AnyHugeInt`` to this huge integer.
    mutating func add(_ value: AnyHugeInt)
    /// Return a new ``Self`` by adding ``AnyHugeInt`` to this huge integer.
    func adding(_ value: AnyHugeInt) -> Self
    
    /// Subtracts a ``AnyHugeInt`` to this huge integer.
    mutating func subtract(_ value: AnyHugeInt)
    /// Return a new ``Self`` by subtracting ``AnyHugeInt`` from this huge integer.
    func subtracting(_ value: AnyHugeInt) -> Self
    
    /// Multiply this huge integer by a ``AnyHugeInt``.
    mutating func multiply(by value: AnyHugeInt)
    /// Return a new ``Self`` by multiplying this huge integer by a ``AnyHugeInt``.
    func multiplied(by value: AnyHugeInt) -> Self
    
    /// Divides this huge integer by a ``AnyHugeInt``.
    mutating func divide(by value: AnyHugeInt) -> HugeRemainder?
    /// Return a new ``Self`` by dividing this huge integer by a ``AnyHugeInt``.
    func divided(by value: AnyHugeInt) -> (quotient: AnyHugeInt, remainder: HugeRemainder?)
    
    mutating func multiply_by_ten(_ amount: Int)
    
    mutating func remove_trailing_zeros()
    mutating func remove_leading_zeros()
    
    func squared() -> Self
    func cubed() -> Self
    /// Returns a new ``Self`` taken to a given power.
    /// - Complexity: O(n) where _n_ equals _x_.
    /// - Parameters:
    ///     - x: the amount of times to multiply self by self.
    func to_the_power_of(_ x: UInt64) -> Self
    
    func elementsEqual(_ value: AnyHugeInt) -> Bool
    func is_less_than(_ value: AnyHugeInt) -> Bool
    func is_less_than_or_equal_to(_ value: AnyHugeInt) -> Bool
    func is_greater_than(_ value: AnyHugeInt) -> Bool
    func is_greater_than_or_equal_to(_ value: AnyHugeInt) -> Bool
}
private struct Brother {
    var test:AnyHugeInt
}

public extension AnyHugeInt {
    init(_ integer: AnyHugeInt) {
        self = Self(is_negative: integer.is_negative, integer.numbers)
    }
    
    var description : String {
        return is_zero ? "0" : (is_negative ? "-" : "") + numbers.reversed().map({ String(describing: $0) }).joined()
    }
    
    var is_zero : Bool {
        return numbers.count == 0 || all_digits_satisfy({ $0 == 0 })
    }
    
    var length : Int {
        return numbers.count
    }
    
    func all_digits_satisfy(_ transform: (Int8) -> Bool) -> Bool {
        return numbers.allSatisfy(transform)
    }
    
    func to_int<T: BinaryInteger & LosslessStringConvertible>() -> T? {
        return T.init(description)
    }
    
    func flipped_sign() -> Self {
        return Self(is_negative: !is_negative, numbers)
    }
    
    mutating func add(_ value: AnyHugeInt) {
        self = Self.add(left: self, right: value)
    }
    func adding(_ value: AnyHugeInt) -> Self {
        return Self.add(left: self, right: value)
    }
    
    mutating func subtract(_ value: AnyHugeInt) {
        self = Self.add(left: self, right: value.flipped_sign())
    }
    func subtracting(_ value: AnyHugeInt) -> Self {
        return Self.add(left: self, right: value.flipped_sign())
    }
    
    mutating func multiply(by value: AnyHugeInt) {
        is_negative = !(is_negative == value.is_negative)
        numbers = Self.multiply(left: numbers, right: value.numbers)
    }
    func multiplied(by value: AnyHugeInt) -> Self {
        if is_zero || value.is_zero {
            return Self.zero
        } else if is_zero {
            return Self(value)
        } else if value.is_zero {
            return Self(self)
        } else {
            let numbers:[Int8] = Self.multiply(left: numbers, right: value.numbers)
            let is_negative:Bool = !(is_negative == value.is_negative)
            return Self(is_negative: is_negative, numbers)
        }
    }
    
    mutating func divide(by value: AnyHugeInt) -> HugeRemainder? {
        let (quotient, remainder):(AnyHugeInt, HugeRemainder?) = Self.divide(dividend: self, divisor: Self.one)
        is_negative = quotient.is_negative
        numbers = quotient.numbers
        return remainder
    }
    func divided(by value: AnyHugeInt) -> (quotient: AnyHugeInt, HugeRemainder?) {
        return Self.divide(dividend: self, divisor: Self.one)
    }
    
    mutating func multiply_by_ten(_ amount: Int) {
        let array:[Int8] = [Int8].init(repeating: 0, count: abs(amount))
        if amount > 0 {
            numbers.insert(contentsOf: array, at: 0)
        } else {
            numbers.insert(contentsOf: array, at: numbers.count-1)
        }
    }
    
    mutating func remove_trailing_zeros() {
        while numbers.first == 0 {
            numbers.removeFirst()
        }
    }
    mutating func remove_leading_zeros() {
        while numbers.last == 0 {
            numbers.removeLast()
        }
    }
    
    /*
     To the power of x
     */
    func squared() -> Self {
        return to_the_power_of(2)
    }
    func cubed() -> Self {
        return to_the_power_of(3)
    }
    
    func elementsEqual(_ value: AnyHugeInt) -> Bool {
        return is_negative == value.is_negative && numbers.count == value.numbers.count && numbers.elementsEqual(value.numbers) || is_zero && value.is_zero
    }
    func is_less_than(_ value: AnyHugeInt) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative == !value.is_negative
        }
        var left_numbers:[Int8] = numbers, right_numbers:[Int8] = value.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count < right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:Int8 = left_numbers[index], right_number:Int8 = right_numbers[index]
            if left_number != right_number {
                return left_number < right_number
            }
        }
        return false
    }
    func is_less_than_or_equal_to(_ value: AnyHugeInt) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative == !value.is_negative
        }
        var left_numbers:[Int8] = numbers, right_numbers:[Int8] = value.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count <= right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:Int8 = left_numbers[index], right_number:Int8 = right_numbers[index]
            if left_number != right_number {
                return left_number <= right_number
            }
        }
        return true
    }
    func is_greater_than(_ value: AnyHugeInt) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative == !value.is_negative
        }
        var left_numbers:[Int8] = numbers, right_numbers:[Int8] = value.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count > right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:Int8 = left_numbers[index], right_number:Int8 = right_numbers[index]
            if left_number != right_number {
                return left_number > right_number
            }
        }
        return false
    }
    func is_greater_than_or_equal_to(_ value: AnyHugeInt) -> Bool {
        guard is_negative == value.is_negative else {
            return is_negative == !value.is_negative
        }
        var left_numbers:[Int8] = numbers, right_numbers:[Int8] = value.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count >= right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:Int8 = left_numbers[index], right_number:Int8 = right_numbers[index]
            if left_number != right_number {
                return left_number >= right_number
            }
        }
        return true
    }
}

// MARK: SomeHugeInt
public protocol SomeHugeInt : AnyHugeInt, HugeNumber {
    func multiplied_by_ten(_ amount: Int) -> Self
    
    static func == (left: Self, right: AnyHugeInt) -> Bool
    
    static func < (left: Self, right: AnyHugeInt) -> Bool
    static func <= (left: Self, right: AnyHugeInt) -> Bool
    
    static func > (left: Self, right: AnyHugeInt) -> Bool
    static func >= (left: Self, right: AnyHugeInt) -> Bool
    
    static func + (left: Self, right: AnyHugeInt) -> Self
    static func - (left: Self, right: AnyHugeInt) -> Self
    static func * (left: Self, right: AnyHugeInt) -> Self
    static func / (left: Self, right: AnyHugeInt) -> (quotient: AnyHugeInt, remainder: HugeRemainder?)
}

public func abs<T: SomeHugeInt>(_ integer: T) -> T {
    return T(is_negative: false, integer.numbers)
}

public extension SomeHugeInt {
    func multiplied_by_ten(_ amount: Int) -> Self {
        let is_negative:Bool = is_negative != (amount < 0 ? true : false)
        var numbers:[Int8] = numbers
        numbers.insert(contentsOf: [Int8].init(repeating: 0, count: abs(amount)), at: 0)
        return Self(is_negative: is_negative, numbers)
    }
    
    func to_the_power_of(_ x: UInt64) -> Self {
        var result:Self = self
        for _ in 1..<x {
            result *= self
        }
        return result
    }
}

// MARK: SomeHugeInt Comparable
public extension SomeHugeInt {
    static func == (left: Self, right: AnyHugeInt) -> Bool {
        return left.elementsEqual(right)
    }
    
    static func < (left: Self, right: Self) -> Bool {
        return false
    }
    static func < (left: Self, right: AnyHugeInt) -> Bool {
        return left.is_less_than(right)
    }
    static func <= (left: Self, right: AnyHugeInt) -> Bool {
        return left.is_less_than_or_equal_to(right)
    }
    static func <= (left: Self, right: any BinaryInteger) -> Bool {
        return left <= Self.init(right)
    }
    static func <= (left: any BinaryInteger, right: Self) -> Bool {
        return Self.init(left) <= right
    }
    
    static func > (left: Self, right: AnyHugeInt) -> Bool {
        return left.is_greater_than(right)
    }
    static func >= (left: Self, right: AnyHugeInt) -> Bool {
        return left.is_greater_than_or_equal_to(right)
    }
}
// MARK: SomeHugeInt prefixes/postfixes
public extension AnyHugeInt {
    static prefix func - (value: Self) -> Self {
        return Self(is_negative: !value.is_negative, value.numbers)
    }
    /// - Complexity: O(_n_ - 1) where _n_ equals this huge integer.
    /// - Warning: Very resource intensive when using big numbers.
    func factorial() -> Self {
        let one:Self = Self.one
        var remaining_value:Self = Self(is_negative: false, numbers)
        var value:Self = remaining_value
        while !remaining_value.elementsEqual(one) {
            remaining_value.subtract(one)
            value *= remaining_value
        }
        return Self(is_negative: is_negative, value.numbers)
    }
}
// MARK: SomeHugeInt addition
public extension SomeHugeInt {
    static func + (left: Self, right: AnyHugeInt) -> Self {
        return add(left: left, right: right)
    }
    static func + (left: Self, right: any BinaryInteger) -> Self {
        return left + Self(right)
    }
    static func + (left: any BinaryInteger, right: Self) -> Self {
        return Self(left) + right
    }
    
    static func += (left: inout Self, right: AnyHugeInt) {
        left = add(left: left, right: right)
    }
    static func += (left: inout Self, right: any BinaryInteger) {
        left += Self(right)
    }
}
public extension AnyHugeInt {
    static func add(left: AnyHugeInt, right: AnyHugeInt) -> Self {
        if left.is_zero {
            return Self(right)
        } else if right.is_zero {
            return Self(left)
        } else {
            let is_bigger:Bool, result:[Int8], is_negative:Bool
            let left_numbers:[Int8] = left.numbers, right_numbers:[Int8] = right.numbers
            if right.is_negative {
                if left.is_negative {
                    (result, is_bigger) = add(left: left_numbers, right: right_numbers)
                    is_negative = true
                } else {
                    (result, is_bigger) = subtract(left: left_numbers, right: right_numbers)
                    is_negative = left_numbers == right_numbers ? false : !is_bigger
                }
            } else {
                if left.is_negative {
                    (result, is_bigger) = subtract(left: left_numbers, right: right_numbers)
                    is_negative = left_numbers == right_numbers ? false : !is_bigger
                } else {
                    (result, is_bigger) = add(left: left_numbers, right: right_numbers)
                    is_negative = false
                }
            }
            return Self(is_negative: is_negative, result)
        }
    }
    static func add(left: [Int8], right: [Int8]) -> (result: [Int8], left_is_bigger: Bool) {
        let (bigger_numbers, smaller_numbers, left_is_bigger):([Int8], [Int8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[Int8] = add(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, left_is_bigger)
    }
    /// Finds the sum of two 8-bit number arrays.
    /// - Complexity: O(_n_ + 1) where _n_ equals _bigger_numbers.count_.
    /// - Returns: the sum of the two arrays, in reverse order.
    static func add(bigger_numbers: [Int8], smaller_numbers: [Int8]) -> [Int8] {
        let smaller_numbers_length:Int = smaller_numbers.count
        let result_count:Int = bigger_numbers.count + 1
        var result:[Int8] = bigger_numbers
        result.append(0)
        
        for index in 0..<smaller_numbers_length {
            result[index] += smaller_numbers[index]
        }
        for i in 0..<result_count {
            if result[i] > 9 {
                result[i] -= 10
                result[i+1] += 1
            }
        }
        return result
    }
}
// MARK: SomeHugeInt subtraction
public extension AnyHugeInt {
    static func - (left: Self, right: AnyHugeInt) -> Self {
        return left.subtracting(right)
    }
    static func - (left: Self, right: any BinaryInteger) -> Self {
        return left - Self(right)
    }
    static func - (left: any BinaryInteger, right: Self) -> Self {
        return Self(left) - right
    }
    
    static func -= (left: inout AnyHugeInt, right: AnyHugeInt) {
        left.add(right.flipped_sign())
    }
    static func -= (left: inout AnyHugeInt, right: any BinaryInteger) {
        left.subtract(Self(right))
    }
}
public extension AnyHugeInt {
    static func subtract(left: [Int8], right: [Int8]) -> (result: [Int8], left_is_bigger: Bool) {
        let (bigger_numbers, smaller_numbers, left_is_bigger):([Int8], [Int8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[Int8] = subtract(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, left_is_bigger)
    }
    /// Finds the net of two 8-bit number arrays.
    /// - Returns: the net of the two arrays, in reverse order.
    static func subtract(bigger_numbers: [Int8], smaller_numbers: [Int8]) -> [Int8] {
        let smaller_numbers_length:Int = smaller_numbers.count
        let result_count:Int = bigger_numbers.count
        var result:[Int8] = bigger_numbers
        
        for index in 0..<smaller_numbers_length {
            result[index] -= smaller_numbers[index]
        }
        for i in 0..<result_count {
            if result[i] < 0 {
                result[i] += 10
                result[i+1] -= 1
            }
        }
        return result
    }
}
// MARK: SomeHugeInt multiplication
public extension AnyHugeInt {
    static func * (left: Self, right: AnyHugeInt) -> Self {
        return left.multiplied(by: right)
    }
    static func * (left: Self, right: any BinaryInteger) -> Self {
        return left * Self(right)
    }
    static func * (left: any BinaryInteger, right: Self) -> Self {
        return right * Self(left)
    }
    
    static func *= (left: inout Self, right: AnyHugeInt) {
        left.multiply(by: right)
    }
    static func *= (left: inout Self, right: any BinaryInteger) {
        left *= Self(right)
    }
}
public extension AnyHugeInt {
    static func multiply(left: [Int8], right: [Int8], remove_leading_zeros: Bool = true) -> [Int8] {
        let (bigger_numbers, smaller_numbers, _):([Int8], [Int8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[Int8] = multiply(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        if remove_leading_zeros {
            while result.last == 0 {
                result.removeLast()
            }
        }
        return result
    }
    // TODO: optimize | n * log(n)
    /// Multiplies two 8-bit number arrays together.
    /// - Parameters:
    ///     - bigger_numbers: An array of 8-bit numbers in reverse order. This array's size should be bigger than or equal to _smaller_numbers_ size.
    ///     - smaller_numbers: An array of 8-bit numbers in reverse order. This array's size should be less than or equal to _bigger_numbers_ size.
    /// - Complexity: O(_n_ \* _m_), where _n_ is the _bigger\_numbers_ size, and _m_ is the _smaller\_numbers_ size.
    /// - Returns: the product of the two 8-bit number arrays, in reverse order.
    static func multiply(bigger_numbers: [Int8], smaller_numbers: [Int8]) -> [Int8] {
        let array_count:Int = bigger_numbers.count
        let smaller_numbers_length:Int = smaller_numbers.count, smaller_numbers_length_minus_one:Int = smaller_numbers_length-1
        let result_count:Int = array_count + smaller_numbers_length, result_count_minus_one:Int = result_count-1
        var result:[Int8] = [Int8].init(repeating: 0, count: result_count)
        
        var small_number_index:Int = 0
        while small_number_index < smaller_numbers_length {
            let smaller_number:Int8 = smaller_numbers[small_number_index]
            if smaller_number != 0 {
                var big_number_index:Int = 0, remainder:Int8 = 0
                var small_number_result:[Int8] = [Int8].init(repeating: 0, count: result_count)
                while big_number_index < array_count {
                    let calculated_value:Int8 = smaller_number * bigger_numbers[big_number_index]
                    let total_value:Int8 = calculated_value + remainder
                    remainder = total_value / 10
                    let ending_result:Int8 = total_value - (remainder * 10)
                    small_number_result[small_number_index + big_number_index] = ending_result
                    big_number_index += 1
                }
                if remainder > 0 {
                    let ending_index:Int = small_number_index == smaller_numbers_length_minus_one ? result_count_minus_one : small_number_index + big_number_index
                    small_number_result[ending_index] = remainder
                    remainder = 0
                }
                result = HugeInt.add(bigger_numbers: result, smaller_numbers: small_number_result)
            }
            small_number_index += 1
        }
        return result
    }
}

// MARK: SomeHugeInt division (https://www.wikihow.com/Do-Short-Division , but optimized for a computer)
public extension AnyHugeInt {
    static func / (dividend: AnyHugeInt, divisor: AnyHugeInt) -> (quotient: AnyHugeInt, remainder: HugeRemainder?) {
        if dividend.is_zero {
            return (Self.zero, divisor.is_zero ? nil : HugeRemainder(dividend: dividend, divisor: divisor))
        } else if divisor.numbers == [1] {
            if divisor.is_negative {
                return (dividend.flipped_sign(), nil)
            } else {
                return (dividend, nil)
            }
        }
        return Self.divide(dividend: dividend, divisor: divisor)
    }
    
    static func / (left: AnyHugeInt, right: any BinaryInteger) -> (quotient: AnyHugeInt, remainder: HugeRemainder?) {
        return left.divided(by: Self(right))
    }
    static func / (left: any BinaryInteger, right: Self) -> (quotient: AnyHugeInt, remainder: HugeRemainder?) {
        return Self(left).divided(by: right)
    }
    
    static func /= (left: inout AnyHugeInt, right: AnyHugeInt) {
        let _:HugeRemainder? = left.divide(by: right)
    }
    static func /= (left: inout AnyHugeInt, right: any BinaryInteger) {
        let _:HugeRemainder? = left.divide(by: Self(right))
    }
}
public extension AnyHugeInt {
    static func divide(dividend: AnyHugeInt, divisor: AnyHugeInt) -> (quotient: AnyHugeInt, remainder: HugeRemainder?) {
        guard dividend.is_greater_than_or_equal_to(divisor) else {
            return (Self.zero, HugeRemainder(dividend: dividend, divisor: divisor))
        }
        let is_negative:Bool = !(dividend.is_negative == divisor.is_negative)
        
        var remaining_dividend:Self = Self(is_negative: false, dividend.numbers)
        let dividend_length:Int = dividend.length, divisor_length:Int = divisor.length
        let result_count:Int = dividend_length - divisor_length + 1
        var quotient_numbers:[Int8] = [Int8].init(repeating: Int8.max, count: result_count)
        
        var included_digits:Int = divisor_length
        var quotient_index:Int = 0
        var last_subtracted_amount:AnyHugeInt = Self.zero
        while remaining_dividend.is_greater_than_or_equal_to(divisor) {
            var divisible_dividend_numbers:[Int8] = [Int8].init(repeating: 0, count: included_digits)
            let remaining_dividend_numbers_reversed:[Int8] = remaining_dividend.numbers.reversed()
            for index in 0..<included_digits {
                divisible_dividend_numbers[index] = remaining_dividend_numbers_reversed[index]
            }
            var divisible_dividend:Self = Self(is_negative: false, divisible_dividend_numbers.reversed())
            if divisible_dividend.is_greater_than_or_equal_to(divisor) {
                divisible_dividend.subtract(divisor)
                last_subtracted_amount = divisor
                quotient_numbers[quotient_index] = 1
                while divisible_dividend.is_greater_than_or_equal_to(divisor) {
                    quotient_numbers[quotient_index] += 1
                    divisible_dividend.subtract(divisor)
                    last_subtracted_amount.add(divisor)
                }
                quotient_index += 1
                let remaining_dividend_numbers:[Int8] = remaining_dividend.numbers
                let remaining_dividend_numbers_count:Int = remaining_dividend_numbers.count
                if remaining_dividend_numbers[remaining_dividend_numbers_count-1] < 10 {
                    for _ in included_digits..<remaining_dividend_numbers_count {
                        last_subtracted_amount.numbers.insert(0, at: 0)
                    }
                }
                
                var bruh:[Int8] = subtract(bigger_numbers: remaining_dividend_numbers, smaller_numbers: last_subtracted_amount.numbers)
                for _ in 0..<included_digits {
                    if bruh.last == 0 {
                        bruh.removeLast()
                    }
                }
                while bruh.last == 0 {
                    if quotient_index < result_count {
                        quotient_numbers[quotient_index] = 0
                        quotient_index += 1
                    }
                    bruh.removeLast()
                }
                remaining_dividend = Self(is_negative: false, bruh)
                if included_digits > 1 {
                    included_digits -= 1
                }
            } else {
                included_digits += 1
            }
        }
        let remainder:HugeRemainder?
        if remaining_dividend.is_zero {
            remainder = nil
        } else {
            remainder = HugeRemainder(dividend: remaining_dividend, divisor: divisor)
            if last_subtracted_amount.numbers.last == divisor.numbers.last && last_subtracted_amount.numbers.count == dividend_length && quotient_index < result_count {
                quotient_numbers[quotient_index] = 0
            }
        }
        
        while quotient_numbers.last == Int8.max {
            quotient_numbers.removeLast()
        }
        return (Self(is_negative: is_negative, quotient_numbers.reversed()), remainder)
    }
}

// MARK: SomeHugeInt percent
public extension SomeHugeInt {
    static func % (left: Self, right: AnyHugeInt) -> Self {
        return (left / right).remainder?.dividend as? Self ?? Self.zero
    }
    static func % (left: Self, right: any BinaryInteger) -> Self {
        return left % Self(right)
    }
}

// MARK: Misc
internal extension AnyHugeInt {
    static func left_int_is_bigger(left: AnyHugeInt, right: AnyHugeInt) -> Bool {
        return get_bigger_int(left: left, right: right).left_is_bigger
    }
    static func get_bigger_int(left: AnyHugeInt, right: AnyHugeInt) -> (bigger_int: AnyHugeInt, smaller_int: AnyHugeInt, left_is_bigger: Bool) {
        let (_, _, left_is_bigger):([Int8], [Int8], Bool) = get_bigger_numbers(left: left, right: right)
        if left_is_bigger {
            return (left, right, true)
        } else {
            return (right, left, false)
        }
    }
    static func get_bigger_numbers(left: AnyHugeInt, right: AnyHugeInt) -> (bigger_numbers: [Int8], smaller_numbers: [Int8], left_is_bigger: Bool) {
        let left_is_negative:Bool = left.is_negative, left_numbers:[Int8] = left.numbers, right_numbers:[Int8] = right.numbers
        if left_is_negative == right.is_negative {
            return get_bigger_numbers(left: left_numbers, right: right_numbers)
        } else {
            return left_is_negative ? (right_numbers, left_numbers, false) : (left_numbers, right_numbers, true)
        }
    }
    static func get_bigger_numbers(left: [Int8], right: [Int8]) -> (bigger_numbers: [Int8], smaller_numbers: [Int8], left_is_bigger: Bool) {
        let left_count:Int = left.count, right_count:Int = right.count
        if left_count == right_count {
            let reversed_left:[Int8] = left.reversed(), reversed_right:[Int8] = right.reversed()
            for index in 0..<left_count {
                let left_number:Int8 = reversed_left[index], right_number:Int8 = reversed_right[index]
                if left_number != right_number {
                    if left_number > right_number {
                        return (left, right, true)
                    } else {
                        return (right, left, false)
                    }
                }
            }
            return (right, left, false)
        } else if left_count > right_count {
            return (left, right, true)
        } else {
            return (right, left, false)
        }
    }
}

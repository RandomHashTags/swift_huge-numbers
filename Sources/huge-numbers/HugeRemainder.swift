//
//  HugeRemainder.swift
//  
//
//  Created by Evan Anderson on 4/11/23.
//

import Foundation

public struct HugeRemainder : Hashable, Comparable, CustomStringConvertible {
    public static var zero:HugeRemainder = HugeRemainder(dividend: HugeInt.zero, divisor: HugeInt.zero)
    
    /// The number on the top.
    public private(set) var dividend:HugeInt
    /// The number on the bottom, which we divide the top number by.
    public private(set) var divisor:HugeInt
    
    public init(dividend: HugeInt, divisor: HugeInt) {
        self.dividend = dividend
        self.divisor = divisor
    }
    public init(dividend: String, divisor: String) {
        self.init(dividend: HugeInt(dividend), divisor: HugeInt(divisor))
    }
    public init(dividend: HugeInt, divisor: String) {
        self.init(dividend: dividend, divisor: HugeInt(divisor))
    }
    
    public var description : String {
        return "\(dividend)/\(divisor)"
    }
    
    @inlinable
    public var isZero : Bool {
        return divisor.isZero || dividend.isZero
    }
    @inlinable
    public var toInt : (quotient: HugeInt, remainder: HugeRemainder?) {
        return dividend / divisor
    }
    @inlinable
    public var toFloat : HugeFloat {
        let (test1, test2) = toInt
        return HugeFloat(integer: test1, decimal: nil, remainder: test2)
    }

    // TODO: fix
    /// - Warning: This assumes the divisor is greater than or equal to the dividend.
    @inlinable
    public var distance_to_next_quotient : HugeRemainder {
        return HugeRemainder(dividend: divisor - dividend, divisor: divisor)
    }

    public mutating func add(_ integer: HugeInt) -> HugeRemainder {
        dividend += (integer * divisor)
        return self
    }
    
    /// - Warning: Using this function assumes the dividend is smaller than the divisor.
    @inlinable
    public func toDecimal(precision: HugeInt = HugeInt.defaultPrecision) -> HugeDecimal {
        let precision_int:Int = precision.toInt() ?? Int.max
        let zero:HugeInt = HugeInt.zero, zero_remainder:HugeRemainder = HugeRemainder.zero
        var result:ArraySlice<Int8> = ArraySlice<Int8>.init(repeating: 127, count: precision_int)
        var result_remainders:[HugeRemainder] = [HugeRemainder].init(repeating: zero_remainder, count: precision_int)
        var repeated_value:[Int8]? = nil
        var remainingDividend:HugeInt = abs(dividend), remaining_remainder:HugeRemainder = zero_remainder
        var index:Int = 0
        var same_division_indexes:[Int8:[Int]] = [:]
        while index < precision_int && (remainingDividend != zero || remaining_remainder != zero_remainder) && remainingDividend <= divisor {
            remainingDividend.multipliedByTen(1)
            let (maximum_divisions, remainder) = remainingDividend / divisor
            let subtracted_value:HugeInt = maximum_divisions * divisor
            remainingDividend -= subtracted_value
            remaining_remainder = remainder ?? HugeRemainder(dividend: remainingDividend, divisor: divisor)
            let maximum_divisions_int:Int8 = maximum_divisions.toInt() ?? 0
            if let same_max_division_indexes:[Int] = same_division_indexes[maximum_divisions_int], let index_of_same_max_division:Int = same_max_division_indexes.firstIndex(where: { remaining_remainder == result_remainders[$0] }) {
                let same_max_division_index:Int = same_max_division_indexes[index_of_same_max_division]
                var included_previous_values:Int = 0
                for previous_index in 0..<index_of_same_max_division {
                    if maximum_divisions_int == result[same_max_division_indexes[previous_index]] {
                        included_previous_values += 1
                    }
                }
                let starting_index:Int = same_max_division_index - included_previous_values + 1
                if starting_index != index {
                    repeated_value = Array(result[starting_index..<index])
                }
                result = result[0..<starting_index]
                break
            }
            if same_division_indexes[maximum_divisions_int] == nil {
                same_division_indexes[maximum_divisions_int] = []
            }
            same_division_indexes[maximum_divisions_int]!.append(index)
            result[index] = maximum_divisions_int
            result_remainders[index] = remaining_remainder
            index += 1
        }
        if let repeated_value {
            index = 0
            while result.first == 0 && repeated_value[index] == 0 {
                result.removeFirst()
                index += 1
            }
        } else {
            result = result[0..<index]
        }
        return HugeDecimal(value: HugeInt(isNegative: dividend.isNegative, result.reversed()), repeating_numbers: repeated_value?.reversed())
    }
    
    /// Returns a new `HugeRemainder` by multiplying the `dividend` by ten to the power of _amount_.
    public func multiplyByTen(_ amount: Int) -> HugeRemainder {
        let dividend:HugeInt = dividend.multiplyByTen(amount)
        return HugeRemainder(dividend: dividend, divisor: divisor)
    }
    
    /// - Returns: quotient
    /// - Warning: Very resource intensive when using big numbers.
    public mutating func simplify() -> HugeInt {
        guard dividend < divisor else {
            let (quotient, remainder) = divisor / dividend
            divisor = remainder?.divisor ?? HugeInt.zero
            dividend = remainder?.dividend ?? HugeInt.zero
            return quotient
        }
        if let shared_factors:Set<HugeInt> = dividend.get_shared_factors(divisor), let maximum_shared_factor:HugeInt = shared_factors.max() {
            dividend /= maximum_shared_factor
            divisor /= maximum_shared_factor
        }
        return HugeInt.zero
    }
    /// - Returns: quotient
    /// - Warning: Very resource intensive when using big numbers.
    public mutating func simplify_parallel() async -> HugeInt {
        guard dividend < divisor else {
            let (quotient, remainder) = divisor / dividend
            divisor = remainder?.divisor ?? HugeInt.zero
            dividend = remainder?.dividend ?? HugeInt.zero
            return quotient
        }
        if let shared_factors:Set<HugeInt> = await dividend.getSharedFactorsParallel(divisor), let maximum_shared_factor:HugeInt = shared_factors.max() {
            dividend /= maximum_shared_factor
            divisor /= maximum_shared_factor
        }
        return HugeInt.zero
    }
}

/*
 Comparable
 */
public extension HugeRemainder {
    static func < (lhs: HugeRemainder, rhs: HugeRemainder) -> Bool {
        var left_dividend:HugeInt = lhs.dividend, right_dividend:HugeInt = rhs.dividend
        if lhs.divisor != rhs.divisor {
            let (_, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = HugeRemainder.get_common_denominator(lhs: lhs, rhs: rhs)
            if let left_multiplier:HugeInt = left_multiplier {
                left_dividend *= left_multiplier
            }
            if let right_multiplier:HugeInt = right_multiplier {
                right_dividend *= right_multiplier
            }
        }
        return left_dividend < right_dividend
    }
    
    func is_less_than(_ value: HugeRemainder?) -> Bool {
        guard let value:HugeRemainder = value else { return true }
        return self < value
    }
    func is_less_than_or_equal_to(_ value: HugeRemainder?) -> Bool {
        guard let value:HugeRemainder = value else { return true }
        return self <= value
    }
}
public extension HugeRemainder {
    func is_greater_than(_ value: HugeRemainder?) -> Bool {
        guard let value:HugeRemainder = value else { return true }
        return self > value
    }
    func is_greater_than_or_equal_to(_ value: HugeRemainder?) -> Bool {
        guard let value:HugeRemainder = value else { return true }
        return self >= value
    }
}
public extension HugeRemainder {
    static func == (lhs: HugeRemainder, rhs: HugeRemainder) -> Bool {
        return lhs.dividend == rhs.dividend && lhs.divisor == rhs.divisor || lhs.isZero && rhs.isZero
    }
}
/*
 Misc
 */
public extension HugeRemainder {
    static prefix func - (value: HugeRemainder) -> HugeRemainder {
        return HugeRemainder(dividend: -value.dividend, divisor: value.divisor)
    }
}
internal extension HugeRemainder {
    /// - Warning: This doesn't check if the divisors are equal.
    static func get_common_denominator(lhs: HugeRemainder, rhs: HugeRemainder) -> (denominator: HugeInt, left_multiplier: HugeInt?, right_multiplier: HugeInt?) {
        let left_divisor:HugeInt = lhs.divisor, right_divisor:HugeInt = rhs.divisor
        /*if let max_shared_factor:HugeInt = left_divisor.get_shared_factors(right_divisor)?.max() { // TODO: fix? | makes performance significantly worse, but remainder is simplified
            let left_divisor_is_max:Bool = left_divisor == max_shared_factor
            if left_divisor_is_max {
                let quotient:HugeInt = (right_divisor / left_divisor).quotient
                return (right_divisor, false, quotient, HugeInt.one)
            } else {
                let quotient:HugeInt = (left_divisor / right_divisor).quotient
                return (left_divisor, false, HugeInt.one, quotient)
            }
        } else {*/
            return (left_divisor * right_divisor, right_divisor, left_divisor)
        //}
    }
}
/*
 Addition
 */
public extension HugeRemainder {
    static func + (lhs: HugeRemainder, rhs: HugeRemainder) -> HugeRemainder {
        if lhs == HugeRemainder.zero {
            return rhs
        } else if rhs == HugeRemainder.zero {
            return lhs
        } else if lhs.divisor == rhs.divisor {
            return HugeRemainder(dividend: lhs.dividend + rhs.dividend, divisor: lhs.divisor)
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(lhs: lhs, rhs: rhs)
            let left_dividend:HugeInt = lhs.dividend, right_dividend:HugeInt = rhs.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            return HugeRemainder(dividend: left_result + right_result, divisor: common_denominator)
        }
    }
    static func + (lhs: HugeRemainder, rhs: HugeInt) -> HugeRemainder {
        return lhs + HugeRemainder(dividend: rhs, divisor: HugeInt.one)
    }
    
    static func += (lhs: inout HugeRemainder, rhs: HugeRemainder) {
        if lhs == HugeRemainder.zero {
            lhs.dividend = rhs.dividend
            lhs.divisor = rhs.divisor
        } else if rhs == HugeRemainder.zero {
            return
        } else if lhs.divisor == rhs.divisor {
            lhs.dividend += rhs.dividend
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(lhs: lhs, rhs: rhs)
            let left_dividend:HugeInt = lhs.dividend, right_dividend:HugeInt = rhs.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            lhs.dividend = left_result + right_result
            lhs.divisor = common_denominator
        }
    }
}
/*
 Subtraction
 */
public extension HugeRemainder {
    static func - (lhs: HugeRemainder, rhs: HugeRemainder) -> HugeRemainder {
        return lhs + -rhs
    }
    static func - (lhs: HugeRemainder, rhs: HugeInt) -> HugeRemainder {
        return lhs - HugeRemainder(dividend: rhs, divisor: HugeInt.one)
    }
    
    static func -= (lhs: inout HugeRemainder, rhs: HugeRemainder) {
        if lhs == HugeRemainder.zero {
            lhs.dividend = rhs.dividend
            lhs.divisor = rhs.divisor
        } else if rhs == HugeRemainder.zero {
            return
        } else if lhs.divisor == rhs.divisor {
            lhs.dividend -= rhs.dividend
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(lhs: lhs, rhs: rhs)
            let left_dividend:HugeInt = lhs.dividend, right_dividend:HugeInt = rhs.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            lhs.dividend = left_result - right_result
            lhs.divisor = common_denominator
        }
    }
}
/*
 Multiplication
 */
public extension HugeRemainder {
    static func * (lhs: HugeRemainder, rhs: HugeRemainder) -> HugeRemainder {
        return HugeRemainder(dividend: lhs.dividend * rhs.dividend, divisor: lhs.divisor * rhs.divisor)
    }
    static func * (lhs: HugeRemainder, rhs: HugeInt) -> HugeRemainder {
        return HugeRemainder(dividend: lhs.dividend * rhs, divisor: lhs.divisor)
    }
    
    static func * (lhs: HugeRemainder, rhs: any BinaryInteger) -> HugeRemainder {
        return lhs * HugeRemainder(dividend: HugeInt(rhs), divisor: HugeInt.one)
    }
        
    static func *= (lhs: inout HugeRemainder, rhs: HugeRemainder) {
        lhs.dividend *= rhs.dividend
        lhs.divisor *= rhs.divisor
    }
    static func *= (lhs: inout HugeRemainder, rhs: HugeInt) {
        lhs.dividend *= rhs
    }
}
/*
 Division
 */
public extension HugeRemainder {
    static func / (lhs: HugeRemainder, rhs: HugeRemainder) -> HugeRemainder {
        let reciprocal:HugeRemainder = HugeRemainder(dividend: rhs.divisor, divisor: rhs.dividend)
        return lhs * reciprocal
    }
}

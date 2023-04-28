//
//  HugeRemainder.swift
//  
//
//  Created by Evan Anderson on 4/11/23.
//

import Foundation

public struct HugeRemainder : Hashable, Comparable {
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
        return dividend.description + "/" + divisor.description
    }
    
    public var is_zero : Bool {
        return dividend == HugeInt.zero
    }
    public var to_int : (quotient: HugeInt, remainder: HugeRemainder?) {
        return dividend / divisor
    }
    public var to_float : HugeFloat {
        let (test1, test2):(HugeInt, HugeRemainder?) = to_int
        return HugeFloat(integer: test1, decimal: nil, remainder: test2)
    }
    
    // TODO: fix
    /// - Warning: This assumes the divisor is greater than or equal to the dividend.
    public var distance_to_next_quotient : HugeRemainder {
        return HugeRemainder(dividend: divisor - dividend, divisor: divisor)
    }
    
    /// - Warning: Using this function assumes the dividend is smaller than the divisor.
    public func to_decimal(precision: HugeInt = HugeInt.default_precision) -> HugeDecimal {
        let precision_int:Int = precision.to_int() ?? Int.max
        let zero:HugeInt = HugeInt.zero, zero_remainder:HugeRemainder = HugeRemainder.zero
        var result:ArraySlice<UInt8> = ArraySlice<UInt8>.init(repeating: 255, count: precision_int)
        var result_remainders:[HugeRemainder] = [HugeRemainder].init(repeating: zero_remainder, count: precision_int)
        var repeated_value:[UInt8]? = nil
        let is_negative:Bool = dividend.is_negative
        var remaining_dividend:HugeInt = is_negative ? -dividend : dividend, remaining_remainder:HugeRemainder = zero_remainder
        var index:Int = 0
    while_loop:
        while index < precision_int && (remaining_dividend != zero || remaining_remainder != zero_remainder) && remaining_dividend <= divisor {
            remaining_dividend *= 10
            let (maximum_divisions, remainder):(HugeInt, HugeRemainder?) = remaining_dividend / divisor
            let subtracted_value:HugeInt = maximum_divisions * divisor
            remaining_dividend -= subtracted_value
            remaining_remainder = remainder ?? HugeRemainder(dividend: remaining_dividend, divisor: divisor)
            let maximum_divisions_int:UInt8 = maximum_divisions.to_int() ?? 0
            if let same_max_division_indexes:[Int] = get_indexes_of(value: maximum_divisions_int, array: result, set_value: maximum_divisions_int+1) {
                var index_of_same_max_division:Int = 0
                for same_max_division_index in same_max_division_indexes {
                    if remaining_remainder == result_remainders[same_max_division_index] {
                        var included_previous_values:Int = 0
                        for previous_index in 0..<index_of_same_max_division {
                            if maximum_divisions_int == result[same_max_division_indexes[previous_index]] {
                                included_previous_values += 1
                            }
                        }
                        let starting_index:Int = same_max_division_index - included_previous_values + 1
                        repeated_value = Array(result[starting_index..<index])
                        result = result[0..<starting_index]
                        break while_loop
                    }
                    index_of_same_max_division += 1
                }
            }
            result[index] = maximum_divisions_int
            result_remainders[index] = remaining_remainder
            index += 1
        }
        if let repeated_value:[UInt8] = repeated_value {
            index = 0
            while result.first == 0 && repeated_value[index] == 0 {
                result.removeFirst()
                index += 1
            }
        } else {
            result = result[0..<index]
        }
        return HugeDecimal(value: HugeInt(is_negative: is_negative, result.reversed()), repeating_numbers: repeated_value?.reversed())
    }
    private func get_indexes_of(value: UInt8, array: ArraySlice<UInt8>, set_value: UInt8) -> [Int]? {
        guard let first_index:Int = array.firstIndex(of: value) else { return nil }
        var array_copy:ArraySlice<UInt8> = array
        var indexes:[Int] = [first_index]
        array_copy[first_index] = set_value
        while let index:Int = array_copy.firstIndex(of: value) {
            indexes.append(index)
            array_copy[index] = set_value
        }
        return indexes
    }
    
    /// - Warning: Using this assumes the dividend is smaller than the divisor.
    mutating func simplify() async {
        if divisor % dividend == HugeInt.zero {
            divisor = (divisor / dividend).quotient
            dividend = HugeInt.one
        } else if let shared_factors:Set<HugeInt> = await dividend.get_shared_factors_parallel(divisor), let maximum_shared_factor:HugeInt = shared_factors.max() {
            dividend /= maximum_shared_factor
            divisor /= maximum_shared_factor
        }
    }
}

/*
 Comparable
 */
public extension HugeRemainder {
    static func < (left: HugeRemainder, right: HugeRemainder) -> Bool {
        var left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
        if left.divisor != right.divisor {
            let (_, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = HugeRemainder.get_common_denominator(left: left, right: right)
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
    static func == (left: HugeRemainder, right: HugeRemainder) -> Bool {
        return left.dividend == right.dividend && left.divisor == right.divisor || left.is_zero && right.is_zero
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
    static func get_common_denominator(left: HugeRemainder, right: HugeRemainder) -> (denominator: HugeInt, left_multiplier: HugeInt?, right_multiplier: HugeInt?) {
        let left_divisor:HugeInt = left.divisor, right_divisor:HugeInt = right.divisor
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
    static func + (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        if left == HugeRemainder.zero {
            return right
        } else if right == HugeRemainder.zero {
            return left
        } else if left.divisor == right.divisor {
            return HugeRemainder(dividend: left.dividend + right.dividend, divisor: left.divisor)
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(left: left, right: right)
            let left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            return HugeRemainder(dividend: left_result + right_result, divisor: common_denominator)
        }
    }
    static func + (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return left + HugeRemainder(dividend: right, divisor: HugeInt.one)
    }
    
    static func += (left: inout HugeRemainder, right: HugeRemainder) {
        if left == HugeRemainder.zero {
            left.dividend = right.dividend
            left.divisor = right.divisor
        } else if right == HugeRemainder.zero {
            return
        } else if left.divisor == right.divisor {
            left.dividend += right.dividend
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(left: left, right: right)
            let left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            left.dividend = left_result + right_result
            left.divisor = common_denominator
        }
    }
}
/*
 Subtraction
 */
public extension HugeRemainder {
    static func - (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        return left + -right
    }
    static func - (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return left - HugeRemainder(dividend: right, divisor: HugeInt.one)
    }
    
    static func -= (left: inout HugeRemainder, right: HugeRemainder) {
        if left == HugeRemainder.zero {
            left.dividend = right.dividend
            left.divisor = right.divisor
        } else if right == HugeRemainder.zero {
            return
        } else if left.divisor == right.divisor {
            left.dividend -= right.dividend
        } else {
            let (common_denominator, left_multiplier, right_multiplier):(HugeInt, HugeInt?, HugeInt?) = get_common_denominator(left: left, right: right)
            let left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            left.dividend = left_result - right_result
            left.divisor = common_denominator
        }
    }
}
/*
 Multiplication
 */
public extension HugeRemainder {
    static func * (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        return HugeRemainder(dividend: left.dividend * right.dividend, divisor: left.divisor * right.divisor)
    }
    static func * (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return HugeRemainder(dividend: left.dividend * right, divisor: left.divisor)
    }
    
    static func * (left: HugeRemainder, right: any BinaryInteger) -> HugeRemainder {
        return left * HugeRemainder(dividend: HugeInt(right), divisor: HugeInt.one)
    }
        
    static func *= (left: inout HugeRemainder, right: HugeRemainder) {
        left.dividend *= right.dividend
        left.divisor *= right.divisor
    }
    static func *= (left: inout HugeRemainder, right: HugeInt) {
        left.dividend *= right
    }
}
/*
 Division
 */
public extension HugeRemainder {
    static func / (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        let reciprocal:HugeRemainder = HugeRemainder(dividend: right.divisor, divisor: right.dividend)
        return left * reciprocal
    }
}

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
    
    public var description : String {
        return dividend.description + "/" + divisor.description
    }
    
    public var is_zero : Bool {
        return dividend == HugeInt.zero
    }
    
    public func to_decimal(precision: HugeInt = HugeInt.default_precision) -> HugeDecimal {
        let precision_int:Int = precision.to_int() ?? Int.max
        let zero:HugeInt = HugeInt.zero, zero_remainder:HugeRemainder = HugeRemainder.zero
        var result:ArraySlice<UInt8> = ArraySlice<UInt8>.init(repeating: 255, count: precision_int)
        var result_remainders:[HugeRemainder] = [HugeRemainder].init(repeating: zero_remainder, count: precision_int)
        var repeated_value:[UInt8]? = nil
        var remaining_dividend:HugeInt = dividend, remaining_remainder:HugeRemainder = zero_remainder
        var index:Int = 0
    while_loop:
        while index < precision_int && (remaining_dividend != zero || remaining_remainder != zero_remainder) && remaining_dividend <= divisor {
            remaining_dividend *= 10
            let (maximum_divisions, remainder):(HugeInt, HugeRemainder?) = HugeInt.get_maximum_divisions(dividend: remaining_dividend, divisor: divisor)
            let subtracted_value:HugeInt = maximum_divisions * divisor
            remaining_dividend -= subtracted_value
            remaining_remainder = remainder ?? HugeRemainder(dividend: remaining_dividend, divisor: divisor)
            let maximum_divisions_int:UInt8 = maximum_divisions.to_int()!
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
        if let repeated_value:[UInt8] {
            index = 0
            while result.first == 0 && repeated_value[index] == 0 {
                result.removeFirst()
                index += 1
            }
        } else {
            result = result[0..<index]
        }
        return HugeDecimal(value: HugeInt(is_negative: false, result.reversed()), repeating_numbers: repeated_value?.reversed())
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
}

/*
 Comparable
 */
public extension HugeRemainder {
    static func < (left: HugeRemainder, right: HugeRemainder) -> Bool {
        let left_divisor:HugeInt = left.divisor, right_divisor:HugeInt = right.divisor
        return left_divisor == right_divisor ? left.dividend < right.dividend : false // TODO: fix
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
internal extension HugeRemainder {
    static func get_common_denominator(left: HugeRemainder, right: HugeRemainder) -> (denominator: HugeInt, are_equal: Bool, left_multiplier: HugeInt?, right_multiplier: HugeInt?) {
        let left_divisor:HugeInt = left.divisor, right_divisor:HugeInt = right.divisor
        if left_divisor == right_divisor {
            return (left_divisor, true, nil, nil)
        } else {
            return (left_divisor * right_divisor, false, right_divisor, left_divisor)
        }
    }
}
/*
 Addition
 */
public extension HugeRemainder {
    static func + (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        let (common_denominator, are_equal, left_multiplier, right_multiplier):(HugeInt, Bool, HugeInt?, HugeInt?) = get_common_denominator(left: left, right: right)
        if are_equal {
            return HugeRemainder(dividend: left.dividend + right.dividend, divisor: common_denominator)
        } else {
            let left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            return HugeRemainder(dividend: left_result + right_result, divisor: common_denominator)
        }
    }
    static func + (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return left + HugeRemainder(dividend: right, divisor: HugeInt.one)
    }
}
/*
 Subtraction
 */
public extension HugeRemainder {
    static func - (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        let (common_denominator, are_equal, left_multiplier, right_multiplier):(HugeInt, Bool, HugeInt?, HugeInt?) = get_common_denominator(left: left, right: right)
        if are_equal {
            return HugeRemainder(dividend: left.dividend - right.dividend, divisor: common_denominator)
        } else {
            let left_dividend:HugeInt = left.dividend, right_dividend:HugeInt = right.dividend
            let left_result:HugeInt = left_dividend * left_multiplier!, right_result:HugeInt = right_dividend * right_multiplier!
            return HugeRemainder(dividend: left_result - right_result, divisor: common_denominator)
        }
    }
    static func - (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return left - HugeRemainder(dividend: right, divisor: HugeInt.one)
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
    
}

//
//  HugeRemainder.swift
//  
//
//  Created by Evan Anderson on 4/11/23.
//

import Foundation

public struct HugeRemainder : Hashable, Comparable {
    public static var zero:HugeRemainder = HugeRemainder(dividend: HugeInt.zero, divisor: HugeInt.zero)
    
    public private(set) var dividend:HugeInt
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
    
    public func to_decimal(precision: HugeInt = HugeInt.default_precision) -> HugeDecimal { // TODO: finish
        let precision_int:Int = precision.to_int() ?? Int.max
        let zero:HugeInt = HugeInt.zero, zero_remainder:HugeRemainder = HugeRemainder.zero
        var result:[UInt8] = [UInt8].init(repeating: 0, count: precision_int)
        var remaining_dividend:HugeInt = dividend, remaining_remainder:HugeRemainder = HugeRemainder(dividend: zero, divisor: zero)
        var index:Int = 0
        while index < precision_int && (remaining_dividend != zero || remaining_remainder != zero_remainder) && remaining_dividend <= divisor {
            remaining_dividend *= 10
            let (maximum_divisions, remainder):(HugeInt, HugeRemainder) = HugeInt.get_maximum_divisions(dividend: remaining_dividend, divisor: divisor)
            let subtracted_value:HugeInt = maximum_divisions * divisor
            remaining_dividend -= subtracted_value
            remaining_remainder = remainder
            result[index] = maximum_divisions.to_int()!
            index += 1
        }
        result.removeLast(precision_int-index)
        return HugeDecimal(value: HugeInt(is_negative: false, result.reversed()), is_repeating: false, repeating_numbers: [])
    }
}

/*
 Comparable
 */
public extension HugeRemainder {
    static func < (lhs: HugeRemainder, rhs: HugeRemainder) -> Bool { // TODO: fix
        return false
    }
}
public extension HugeRemainder {
    static func == (left: HugeRemainder, right: HugeRemainder) -> Bool {
        return left.dividend == right.dividend && left.divisor == right.divisor || left.is_zero && right.is_zero
    }
}
/*
 Subtraction
 */
public extension HugeRemainder {
    static func - (left: HugeRemainder, right: HugeRemainder) -> HugeRemainder {
        return HugeRemainder(dividend: left.dividend-right.dividend, divisor: left.divisor-right.divisor)
    }
    
    static func - (left: HugeRemainder, right: HugeInt) -> HugeRemainder {
        return left - HugeRemainder(dividend: right, divisor: right * right)
    }
}

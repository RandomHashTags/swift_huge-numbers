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
    
    public func to_decimal(precision: HugeInt = HugeInt.default_precision) -> HugeDecimal {
        let precision_int:Int = precision.to_int() ?? Int.max
        let zero:HugeInt = HugeInt.zero, zero_remainder:HugeRemainder = HugeRemainder.zero
        var result:[UInt8] = [UInt8].init(repeating: 255, count: precision_int)
        var result_remainders:[HugeRemainder] = [HugeRemainder].init(repeating: HugeRemainder.zero, count: precision_int)
        var repeated_value:[UInt8]! = nil
        var remaining_dividend:HugeInt = dividend, remaining_remainder:HugeRemainder = HugeRemainder(dividend: zero, divisor: zero)
        var index:Int = 0, repeating:Bool = false
        let values_index:Int = max(dividend.length, divisor.length)
    while_loop: while index < precision_int && (remaining_dividend != zero || remaining_remainder != zero_remainder) && remaining_dividend <= divisor {
            remaining_dividend *= 10
            let (maximum_divisions, remainder):(HugeInt, HugeRemainder) = HugeInt.get_maximum_divisions(dividend: remaining_dividend, divisor: divisor)
            let subtracted_value:HugeInt = maximum_divisions * divisor
            remaining_dividend -= subtracted_value
            remaining_remainder = remainder
            let maximum_divisions_int:UInt8 = maximum_divisions.to_int()!
            if index >= values_index, let indexes:[Int] = get_indexes_of(value: maximum_divisions_int, array: result, set_value: maximum_divisions_int+1) {
                for target_index in indexes {
                    if maximum_divisions_int == result[target_index+1] && remaining_remainder == result_remainders[target_index] {
                        repeating = true
                        repeated_value = result[target_index..<index].map({ $0 })
                        result = result[0..<target_index].map({ $0 })
                        break while_loop
                    }
                }
            }
            result[index] = maximum_divisions_int
            result_remainders[index] = remaining_remainder
            index += 1
        }
        if !repeating {
            result.removeLast(precision_int-index)
        }
        return HugeDecimal(value: HugeInt(is_negative: false, result.reversed()), is_repeating: repeating, repeating_numbers: repeating ? repeated_value.reversed() : [])
    }
    private func get_indexes_of(value: UInt8, array: [UInt8], set_value: UInt8) -> [Int]? {
        guard let first_index:Int = array.firstIndex(of: value) else { return nil }
        var array_copy:[UInt8] = array
        let array_count:Int = array.count
        var indexes:[Int] = [Int].init(repeating: 0, count: array_count)
        indexes[0] = first_index
        array_copy[first_index] = set_value
        var found_indexes:Int = 1
        while let index:Int = array_copy.firstIndex(of: value) {
            indexes[found_indexes] = index
            array_copy[index] = set_value
            found_indexes += 1
        }
        return indexes
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

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
            //print("index=" + index.description + ";maximum_divisions_int=" + maximum_divisions.description + ";remaining_remainder=" + remaining_remainder.description)
            if let indexes:[Int] = get_indexes_of(value: maximum_divisions_int, array: result, set_value: maximum_divisions_int+1) {
                //print("indexes=" + indexes.description)
                for target_index in indexes {
                    if maximum_divisions_int == result[target_index] && remaining_remainder == result_remainders[target_index] { // TODO: fix (check if next number is the same as well)
                        repeated_value = Array(result[target_index..<index])
                        result = result[0..<target_index]
                        //print("returned with target_index " + target_index.description)
                        break while_loop
                    }
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
        //print("result1=\(result)")
        //print("repeated_value1=\(repeated_value)")
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

//
//  HugeInt.swift
//  
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

public struct HugeInt : Hashable, Comparable, CustomStringConvertible {
    public private(set) var is_negative:Bool
    /// The 8-bit numbers representing this huge integer, in reverse order.
    public private(set) var numbers:[UInt8]
    
    public init(is_negative: Bool, _ numbers: [UInt8]) {
        self.is_negative = is_negative
        self.numbers = numbers
    }
    public init(_ string: any StringProtocol) {
        let start_index:String.Index = string.startIndex
        self.is_negative = string[start_index] == "-"
        self.numbers = (is_negative ? string[string.index(start_index, offsetBy: 1)...] : string).map({ UInt8(exactly: $0.wholeNumberValue!)! }).reversed()
    }
    
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    public var length : Int {
        return numbers.count
    }
    public var description : String {
        return (is_negative ? "-" : "") + numbers.reversed().map({ String(describing: $0) }).joined()
    }
    
    public mutating func adding(value: HugeInt) -> HugeInt { // TODO: fix | can only add positive numbers
        numbers = HugeInt.combine(left: numbers, right: value.numbers)
        return self
    }
    
    public mutating func multiply(by value: HugeInt) -> HugeInt {
        numbers = HugeInt.multiply(left: numbers, right: value.numbers)
        return self
    }
}

/*
 Comparable
 */
public extension HugeInt {
    static func < (lhs: HugeInt, rhs: HugeInt) -> Bool {
        guard lhs.is_negative == rhs.is_negative else {
            return lhs.is_negative && !rhs.is_negative
        }
        let left_numbers:[UInt8] = lhs.numbers, right_numbers:[UInt8] = rhs.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count < right_numbers.count
        }
        for index in 0..<left_numbers.count {
            if left_numbers[index] < right_numbers[index] {
                return true
            }
        }
        return false
    }
    static func < (left: HugeInt, rhs: any BinaryInteger) -> Bool {
        return left < HugeInt(rhs)
    }
    static func < (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) < right
    }
}
public extension HugeInt {
    static func > (lhs: HugeInt, rhs: HugeInt) -> Bool {
        guard lhs.is_negative == rhs.is_negative else {
            return lhs.is_negative && !rhs.is_negative
        }
        let left_numbers:[UInt8] = lhs.numbers, right_numbers:[UInt8] = rhs.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count > right_numbers.count
        }
        for index in 0..<left_numbers.count {
            if left_numbers[index] > right_numbers[index] {
                return true
            }
        }
        return false
    }
    static func > (left: HugeInt, rhs: any BinaryInteger) -> Bool {
        return left > HugeInt(rhs)
    }
    static func > (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) > right
    }
}
public extension HugeInt {
    static func == (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return lhs.is_negative == rhs.is_negative && lhs.numbers.count == rhs.numbers.count && lhs.numbers.elementsEqual(rhs.numbers)
    }
    static func == (left: HugeInt, rhs: any BinaryInteger) -> Bool {
        return left == HugeInt(rhs)
    }
    static func == (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) == right
    }
}
public extension HugeInt {
    static func <= (lhs: HugeInt, rhs: HugeInt) -> Bool {
        guard lhs.is_negative == rhs.is_negative else {
            return lhs.is_negative && !rhs.is_negative
        }
        let left_numbers:[UInt8] = lhs.numbers, right_numbers:[UInt8] = rhs.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count <= right_numbers.count
        }
        for index in 0..<left_numbers.count {
            if left_numbers[index] <= right_numbers[index] {
                return true
            }
        }
        return false
    }
    static func <= (left: HugeInt, rhs: any BinaryInteger) -> Bool {
        return left < HugeInt(rhs)
    }
    static func <= (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) <= right
    }
}
public extension HugeInt {
    static func >= (lhs: HugeInt, rhs: HugeInt) -> Bool {
        guard lhs.is_negative == rhs.is_negative else {
            return lhs.is_negative && !rhs.is_negative
        }
        let left_numbers:[UInt8] = lhs.numbers, right_numbers:[UInt8] = rhs.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count >= right_numbers.count
        }
        for index in 0..<left_numbers.count {
            if left_numbers[index] >= right_numbers[index] {
                return true
            }
        }
        return false
    }
    static func >= (left: HugeInt, rhs: any BinaryInteger) -> Bool {
        return left >= HugeInt(rhs)
    }
    static func >= (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) >= right
    }
}
/*
 prefixes
 */
public extension HugeInt {
    static prefix func - (value: HugeInt) -> HugeInt {
        return HugeInt(is_negative: !value.is_negative, value.numbers)
    }
}
/*
 Addition
 */
internal extension HugeInt {
    static func combine(left: [UInt8], right: [UInt8]) -> [UInt8] {
        let bigger_numbers:[UInt8], smaller_numbers:[UInt8]
        if left.count > right.count {
            bigger_numbers = left
            smaller_numbers = right
        } else {
            smaller_numbers = left
            bigger_numbers = right
        }
        return HugeInt.add(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
    }
    /// Finds the sum of two 8-bit number arrays.
    /// - Returns: the sum of the two arrays, in reverse order.
    static func add(bigger_numbers: [UInt8], smaller_numbers: [UInt8]) -> [UInt8] {
        let array_count:Int = bigger_numbers.count
        let smaller_numbers_length:Int = smaller_numbers.count
        let result_count:Int = array_count + 1
        var result:[UInt8] = [UInt8].init(repeating: 0, count: result_count)
        
        var index:Int = 0
        while index < smaller_numbers_length {
            let new_value:UInt8 = bigger_numbers[index] + smaller_numbers[index]
            result[index] = new_value
            
            while index < result_count && result[index] > 9 {
                let original_value:UInt8 = result[index]
                let remainder:UInt8 = original_value / 10
                result[index] -= (remainder * 10)
                index += 1
                
                let existing_value:UInt8 = bigger_numbers.get(index) ?? 0
                let adding_value:UInt8 = smaller_numbers.get(index) ?? 0
                let new_value:UInt8 = existing_value + adding_value + remainder
                result[index] = new_value
            }
            index += 1
        }
        while index < result_count-1 {
            result[index] = bigger_numbers[index]
            index += 1
        }
        while result.last == 0 {
            result.removeLast()
        }
        return result
    }
}
/*
 Subtraction // TODO: support
 */
public extension HugeInt {
    /// Finds the net of two 8-bit number arrays.
    /// - Returns: the net of the two arrays, in reverse order.
    static func subtract(bigger_numbers: [UInt8], smaller_numbers: [UInt8]) -> [UInt8] { // TODO: finish
        let array_count:Int = bigger_numbers.count
        let smaller_numbers_length:Int = smaller_numbers.count
        let result_count:Int = array_count
        var result:[UInt8] = [UInt8].init(repeating: 0, count: result_count)
        
        var index:Int = 0
        while index < smaller_numbers_length {
            let new_value:UInt8 = bigger_numbers[index] + smaller_numbers[index]
            result[index] = new_value
            
            while index < result_count && result[index] > 9 {
                let original_value:UInt8 = result[index]
                let remainder:UInt8 = original_value / 10
                result[index] -= (remainder * 10)
                index += 1
                
                let existing_value:UInt8 = bigger_numbers.get(index) ?? 0
                let adding_value:UInt8 = smaller_numbers.get(index) ?? 0
                let new_value:UInt8 = existing_value + adding_value + remainder
                result[index] = new_value
            }
            index += 1
        }
        while result.last == 0 {
            result.removeLast()
        }
        return result
    }
}
/*
 Multiplication
 */
public extension HugeInt {
    static func * (left: HugeInt, right: HugeInt) -> HugeInt {
        let numbers:[UInt8] = HugeInt.multiply(left: left.numbers, right: right.numbers)
        let is_negative:Bool = left.is_negative == !right.is_negative
        return HugeInt(is_negative: is_negative, numbers)
    }
    static func * (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left * HugeInt(right)
    }
    static func * (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return right * HugeInt(left)
    }
    
    static func *= (left: inout HugeInt, right: HugeInt) {
        left.is_negative = left.is_negative == !right.is_negative
        left.numbers = HugeInt.multiply(left: left.numbers, right: right.numbers)
    }
    static func *= (left: inout HugeInt, right: any BinaryInteger) {
        left *= HugeInt(right)
    }
}
internal extension HugeInt {
    static func multiply(left: [UInt8], right: [UInt8]) -> [UInt8] {
        let bigger_numbers:[UInt8], smaller_numbers:[UInt8]
        if left.count > right.count {
            bigger_numbers = left
            smaller_numbers = right
        } else {
            smaller_numbers = left
            bigger_numbers = right
        }
        return HugeInt.multiply(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
    }
    /// Multiplies two 8-bit number arrays together.
    /// - Parameters:
    ///     - bigger_numbers: An array of 8-bit numbers in reverse order. This array's count should be bigger than or equal to `smaller_numbers` array count.
    ///     - smaller_numbers: An array of 8-bit numbers in reverse order. This array's count should be less than or equal to `bigger_numbers` array count.
    /// - Returns: the product of the two 8-bit number arrays, in reversed order.
    static func multiply(bigger_numbers: [UInt8], smaller_numbers: [UInt8]) -> [UInt8] {
        let array_count:Int = bigger_numbers.count
        let smaller_numbers_length:Int = smaller_numbers.count, smaller_numbers_length_minus_one:Int = smaller_numbers_length-1
        let result_count:Int = array_count + smaller_numbers_length, result_count_minus_one:Int = result_count-1
        var result:[UInt8] = [UInt8].init(repeating: 0, count: result_count)
        
        var small_number_index:Int = 0
        while small_number_index < smaller_numbers_length {
            let smaller_number:UInt8 = smaller_numbers[small_number_index]
            var big_number_index:Int = 0, remainder:UInt8 = 0
            var small_number_result:[UInt8] = [UInt8].init(repeating: 0, count: result_count)
            while big_number_index < array_count {
                let bigger_number:UInt8 = bigger_numbers.get(big_number_index) ?? 0
                let calculated_value:UInt8 = smaller_number * bigger_number
                let total_value:UInt8 = calculated_value + remainder
                remainder = total_value / 10
                let ending_result:UInt8 = total_value - (remainder * 10)
                small_number_result[small_number_index + big_number_index] = ending_result
                big_number_index += 1
            }
            if remainder > 0 {
                let ending_index:Int = small_number_index == smaller_numbers_length_minus_one ? result_count_minus_one : small_number_index + big_number_index
                small_number_result[ending_index] = remainder
                remainder = 0
            }
            result = HugeInt.combine(left: result, right: small_number_result)
            small_number_index += 1
        }
        while result.last == 0 {
            result.removeLast()
        }
        return result
    }
}
/*
 Division // TODO: support
 */
/*
 Multiplicative inverse // TODO: support
 */
/*
 Square root // TODO: support
 */
/*
 Percent // TODO: support
 */
/*
 Trigonometry // TODO: support
 */

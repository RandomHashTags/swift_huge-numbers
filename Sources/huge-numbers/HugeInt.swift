//
//  HugeInt.swift
//  
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: improve arthmetic performance by using SIMD instructions/vectors
public struct HugeInt : Hashable, Comparable {
    
    public static var default_precision:HugeInt = HugeInt("1000")
    public static var zero:HugeInt = HugeInt(is_negative: false, [])
    
    public private(set) var is_negative:Bool
    /// The 8-bit numbers representing this huge integer, in reverse order.
    public internal(set) var numbers:[UInt8]
    
    public init(is_negative: Bool, _ numbers: [UInt8]) {
        self.is_negative = is_negative
        self.numbers = numbers.count == 1 && numbers[0] == 0 ? [] : numbers
    }
    public init<T: StringProtocol & RangeReplaceableCollection>(_ string: T, remove_leading_zeros: Bool = true) {
        var target_string:T = string
        if remove_leading_zeros {
            target_string.remove_leading_zeros()
        }
        if target_string.isEmpty {
            is_negative = false
            numbers = []
        } else {
            let start_index:String.Index = target_string.startIndex
            self.is_negative = target_string[start_index] == "-"
            let characters:any StringProtocol = is_negative ? target_string[target_string.index(start_index, offsetBy: 1)...] : target_string
            self.numbers = characters.map({ UInt8(exactly: $0.wholeNumberValue!)! }).reversed()
        }
    }
    
    public init<T: StringProtocol & RangeReplaceableCollection>(is_negative: Bool, _ string: T) {
        self.init(string)
        self.is_negative = is_negative
    }
    public init(is_negative: Bool, _ numbers: ArraySlice<UInt8>) {
        self.init(is_negative: is_negative, Array(numbers))
    }
    public init(is_negative: Bool, _ integer: any BinaryInteger) {
        self.init(is_negative: is_negative, String(describing: integer))
    }
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    /// The amount of digits that represent this huge integer.
    public var length : Int {
        return numbers.count
    }
    /// The number the digits represent.
    public var description : String {
        return is_zero ? "0" : (is_negative ? "-" : "") + numbers.reversed().map({ String(describing: $0) }).joined()
    }
    /// The number the digits represent, in reverse order.
    public var literal_description : String {
        return is_zero ? "0" : (is_negative ? "-" : "") + numbers.map({ String(describing: $0) }).joined()
    }
    public var is_zero : Bool {
        return numbers.count == 0
    }
    public var to_float : HugeFloat {
        return HugeFloat(pre_decimal_number: self, post_decimal_number: HugeInt.zero, exponent: 0)
    }
    public func to_int<T: BinaryInteger & LosslessStringConvertible>() -> T? {
        return T.init(description)
    }
    
    public mutating func remove_trailing_zeros() {
        while numbers.first == 0 {
            numbers.removeFirst()
        }
    }
    
    public mutating func adding(_ value: HugeInt) -> HugeInt {
        self += value
        return self
    }
    
    public mutating func subtract(_ value: HugeInt) -> HugeInt {
        self -= value
        return self
    }
    
    public mutating func multiply(by value: HugeInt) -> HugeInt {
        self *= value
        return self
    }
    
    public mutating func dividing(by value: HugeInt) -> HugeInt {
        let _:HugeRemainder? = self /= value
        return self
    }
    public mutating func divide_with_remainder(by value: HugeInt) -> (result: HugeInt, remainder: HugeRemainder?) {
        return (self, self /= value)
    }
}

/*
 Comparable
 */
public extension HugeInt {
    static func < (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        var left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count < right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:UInt8 = left_numbers[index], right_number:UInt8 = right_numbers[index]
            if left_number != right_number {
                return left_number < right_number
            }
        }
        return false
    }
    static func < (left: HugeInt, right: any BinaryInteger) -> Bool {
        return left < HugeInt(right)
    }
    static func < (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) < right
    }
}
public extension HugeInt {
    static func > (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        var left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count > right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:UInt8 = left_numbers[index], right_number:UInt8 = right_numbers[index]
            if left_number != right_number {
                return left_number > right_number
            }
        }
        return false
    }
    static func > (left: HugeInt, right: any BinaryInteger) -> Bool {
        return left > HugeInt(right)
    }
    static func > (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) > right
    }
}
public extension HugeInt {
    static func == (left: HugeInt, right: HugeInt) -> Bool {
        return left.is_negative == right.is_negative && left.numbers.count == right.numbers.count && left.numbers.elementsEqual(right.numbers) || left.is_zero && right.is_zero
    }
    static func == (left: HugeInt, right: any BinaryInteger) -> Bool {
        return left == HugeInt(right)
    }
    static func == (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) == right
    }
}
public extension HugeInt {
    static func <= (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        var left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count <= right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:UInt8 = left_numbers[index], right_number:UInt8 = right_numbers[index]
            if left_number != right_number {
                return left_number <= right_number
            }
        }
        return true
    }
    static func <= (left: HugeInt, right: any BinaryInteger) -> Bool {
        return left <= HugeInt(right)
    }
    static func <= (left: any BinaryInteger, right: HugeInt) -> Bool {
        return HugeInt(left) <= right
    }
}
public extension HugeInt {
    static func >= (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        var left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        guard left_numbers.count == right_numbers.count else {
            return left_numbers.count >= right_numbers.count
        }
        left_numbers = left_numbers.reversed()
        right_numbers = right_numbers.reversed()
        for index in 0..<left_numbers.count {
            let left_number:UInt8 = left_numbers[index], right_number:UInt8 = right_numbers[index]
            if left_number != right_number {
                return left_number >= right_number
            }
        }
        return true
    }
    static func >= (left: HugeInt, right: any BinaryInteger) -> Bool {
        return left >= HugeInt(right)
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
 Misc
 */
internal extension HugeInt {
    static func left_int_is_bigger(left: HugeInt, right: HugeInt) -> Bool {
        return get_bigger_int(left: left, right: right).left_is_bigger
    }
    static func get_bigger_int(left: HugeInt, right: HugeInt) -> (bigger_int: HugeInt, smaller_int: HugeInt, left_is_bigger: Bool) {
        let (_, _, left_is_bigger):([UInt8], [UInt8], Bool) = get_bigger_numbers(left: left, right: right)
        if left_is_bigger {
            return (left, right, true)
        } else {
            return (right, left, false)
        }
    }
    static func get_bigger_numbers(left: HugeInt, right: HugeInt) -> (bigger_numbers: [UInt8], smaller_numbers: [UInt8], left_is_bigger: Bool) {
        let left_is_negative:Bool = left.is_negative, left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        if left_is_negative == right.is_negative {
            return get_bigger_numbers(left: left_numbers, right: right_numbers)
        } else {
            return left_is_negative ? (right_numbers, left_numbers, false) : (left_numbers, right_numbers, true)
        }
    }
    static func get_bigger_numbers(left: [UInt8], right: [UInt8]) -> (bigger_numbers: [UInt8], smaller_numbers: [UInt8], left_is_bigger: Bool) {
        let left_count:Int = left.count, right_count:Int = right.count
        if left_count == right_count {
            let reversed_left:[UInt8] = left.reversed(), reversed_right:[UInt8] = right.reversed()
            for index in 0..<left_count {
                if reversed_right[index] > reversed_left[index] {
                    return (right, left, false)
                } else if reversed_left[index] > reversed_right[index] {
                    return (left, right, true)
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
/*
 Addition
 */
public extension HugeInt {
    static func + (left: HugeInt, right: HugeInt) -> HugeInt {
        let is_bigger:Bool, result:[UInt8], is_negative:Bool
        let left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        if right.is_negative {
            if left.is_negative {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            } else {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            }
        } else {
            if left.is_negative {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            } else {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = false
            }
        }
        return HugeInt(is_negative: is_negative, result)
    }
    static func + (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left + HugeInt(right)
    }
    static func + (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return HugeInt(left) + right
    }
    
    static func += (left: inout HugeInt, right: HugeInt) {
        let is_bigger:Bool, result:[UInt8], is_negative:Bool
        let left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        if right.is_negative {
            if left.is_negative {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            } else {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            }
        } else {
            if left.is_negative {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            } else {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = false
            }
        }
        left.is_negative = is_negative
        left.numbers = result
    }
    static func += (left: inout HugeInt, right: any BinaryInteger) {
        left += HugeInt(right)
    }
}
internal extension HugeInt {
    static func add(left: [UInt8], right: [UInt8]) -> (result: [UInt8], left_is_bigger: Bool) {
        let (bigger_numbers, smaller_numbers, left_is_bigger):([UInt8], [UInt8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[UInt8] = HugeInt.add(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, left_is_bigger)
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
            let new_value:UInt8 = (bigger_numbers.get(index) ?? 0) + smaller_numbers[index]
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
        return result
    }
}
/*
 Subtraction
 */
public extension HugeInt {
    static func - (left: HugeInt, right: HugeInt) -> HugeInt {
        let is_bigger:Bool, result:[UInt8], is_negative:Bool
        let left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        if right.is_negative {
            if left.is_negative {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            } else {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            }
        } else {
            if left.is_negative {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            } else {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            }
        }
        return HugeInt(is_negative: is_negative, result)
    }
    static func - (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left - HugeInt(right)
    }
    static func - (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return HugeInt(left) - right
    }
    
    static func -= (left: inout HugeInt, right: HugeInt) {
        let is_bigger:Bool, result:[UInt8], is_negative:Bool
        let left_numbers:[UInt8] = left.numbers, right_numbers:[UInt8] = right.numbers
        if right.is_negative {
            if left.is_negative {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            } else {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            }
        } else {
            if left.is_negative {
                (result, is_bigger) = HugeInt.add(left: left_numbers, right: right_numbers)
                is_negative = true
            } else {
                (result, is_bigger) = HugeInt.subtract(left: left_numbers, right: right_numbers)
                is_negative = left_numbers == right_numbers ? false : !is_bigger
            }
        }
        left.is_negative = is_negative
        left.numbers = result
    }
    static func -= (left: inout HugeInt, right: any BinaryInteger) {
        left -= HugeInt(right)
    }
}
internal extension HugeInt {
    static func subtract(left: [UInt8], right: [UInt8]) -> (result: [UInt8], left_is_bigger: Bool) {
        let (bigger_numbers, smaller_numbers, left_is_bigger):([UInt8], [UInt8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[UInt8] = HugeInt.subtract(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, left_is_bigger)
    }
    /// Finds the net of two 8-bit number arrays.
    /// - Returns: the net of the two arrays, in reverse order.
    static func subtract(bigger_numbers: [UInt8], smaller_numbers: [UInt8]) -> [UInt8] {
        let smaller_numbers_length:Int = smaller_numbers.count
        let result_count:Int = bigger_numbers.count
        var result:[UInt8] = [UInt8].init(repeating: 0, count: result_count)
        
        var index:Int = 0, bigger_numbers_copy:[UInt8] = bigger_numbers
        while index < smaller_numbers_length {
            let smaller_number:UInt8 = smaller_numbers[index]
            var bigger_number:UInt8 = bigger_numbers_copy[index]
            while bigger_number < smaller_number {
                var next_index:Int = index + 1
                var next_value:UInt8 = bigger_numbers_copy[next_index]
                if next_value != 0 {
                    next_value -= 1
                    bigger_numbers_copy[next_index] = next_value
                    result[next_index] = next_value
                } else {
                    var offset:Int = 1
                    while next_value == 0 {
                        next_value = bigger_numbers_copy[next_index + offset]
                        offset += 1
                    }
                    var offset_index:Int = next_index + offset - 1
                    while offset_index > 0 {
                        bigger_numbers_copy[offset_index] -= 1
                        result[offset_index] = 9
                        offset_index -= 1
                        let value:UInt8 = UInt8(offset_index == 0 ? 9 : offset_index > 0 ? 10 : 0)
                        if offset_index >= 0 {
                            bigger_numbers_copy[offset_index] += value
                            result[offset_index] += value
                        }
                    }
                    next_value = bigger_numbers_copy[next_index]
                }
                bigger_number += 10
                next_index += 1
            }
            result[index] = bigger_number - smaller_number
            index += 1
        }
        while index < result_count {
            result[index] = bigger_numbers_copy[index]
            index += 1
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
        let (bigger_numbers, smaller_numbers, _):([UInt8], [UInt8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[UInt8] = HugeInt.multiply(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        while result.last == 0 {
            result.removeLast()
        }
        return result
    }
    /// Multiplies two 8-bit number arrays together.
    /// - Parameters:
    ///     - bigger_numbers: An array of 8-bit numbers in reverse order. This array's count should be bigger than or equal to `smaller_numbers` array count.
    ///     - smaller_numbers: An array of 8-bit numbers in reverse order. This array's count should be less than or equal to `bigger_numbers` array count.
    /// - Returns: the product of the two 8-bit number arrays, in reverse order.
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
            result = HugeInt.add(bigger_numbers: result, smaller_numbers: small_number_result)
            small_number_index += 1
        }
        return result
    }
}
/*
 Division (https://www.wikihow.com/Do-Short-Division , but optimized for a computer)
 */
public extension HugeInt {
    static func / (dividend: HugeInt, divisor: HugeInt) -> (result: HugeInt, remainder: HugeRemainder?) {
        guard dividend >= divisor else {
            return (HugeInt.zero, HugeRemainder(dividend: dividend, divisor: divisor))
        }
        if divisor == HugeInt.zero {
            return (HugeInt.zero, nil)
        }
        return get_maximum_divisions(dividend: dividend, divisor: divisor)
    }
    static func get_maximum_divisions(dividend: HugeInt, divisor: HugeInt) -> (result: HugeInt, remainder: HugeRemainder?) {
        let is_negative:Bool = !(dividend.is_negative == divisor.is_negative)
        var maximum_divisions:UInt8 = 0
        var next_value:HugeInt = divisor
        while dividend >= next_value {
            maximum_divisions += 1
            next_value = divisor * maximum_divisions
        }
        guard maximum_divisions > 0 else { return (HugeInt.zero, nil) }
        let subtracted_value:HugeInt = next_value - divisor
        let remainder:HugeInt = dividend - subtracted_value
        return (HugeInt(is_negative: is_negative, maximum_divisions-1), remainder.is_zero ? nil : HugeRemainder(dividend: remainder, divisor: divisor))
    }
    
    static func / (left: HugeInt, right: any BinaryInteger) -> (result: HugeInt, remainder: HugeRemainder?) {
        return left / HugeInt(right)
    }
    static func / (left: any BinaryInteger, right: HugeInt) -> (result: HugeInt, remainder: HugeRemainder?) {
        return HugeInt(left) / right
    }
    
    static func /= (left: inout HugeInt, right: HugeInt) -> HugeRemainder? {
        let (result, remainder):(HugeInt, HugeRemainder?) = left / right
        left.is_negative = result.is_negative
        left.numbers = result.numbers
        return remainder
    }
    static func /= (left: inout HugeInt, right: any BinaryInteger) -> HugeRemainder? {
        return left /= HugeInt(right)
    }
}
/*
 Percent
 */
public extension HugeInt {
    static func % (left: HugeInt, right: HugeInt) -> HugeInt {
        return (left / right).remainder?.dividend ?? HugeInt.zero
    }
    static func % (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left % HugeInt(right)
    }
}
/*
 Multiplicative inverse // TODO: support
 */
/*
 Square root // TODO: support
 */
/*
 Trigonometry // TODO: support
 */
/*
public func sin(_ x: HugeInt) -> (result: HugeInt, remainder: HugeRemainder) { // TODO: finish
    return x
}
public func cos(_ x: HugeInt) -> (result: HugeInt, remainder: HugeRemainder) { // TODO: finish
    return x
}
public func tan(_ x: HugeInt) -> (result: HugeInt, remainder: HugeRemainder) { // TODO: finish
    return x
}
*/

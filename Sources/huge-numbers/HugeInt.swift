//
//  HugeInt.swift
//  
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: improve arthmetic performance by using SIMD instructions/vectors
public struct HugeInt : Hashable, Comparable, Codable {
    public static var default_precision:HugeInt = HugeInt(is_negative: false, [0, 0, 1])
    public static var zero:HugeInt = HugeInt(is_negative: false, [])
    public static var one:HugeInt = HugeInt(is_negative: false, [1])
    
    public internal(set) var is_negative:Bool
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
    
    public init(from decoder: Decoder) throws {
        let container:SingleValueDecodingContainer = try decoder.singleValueContainer()
        let string:String = try container.decode(String.self)
        self.init(string)
    }
    public func encode(to encoder: Encoder) throws {
        var container:SingleValueEncodingContainer = encoder.singleValueContainer()
        try container.encode(description)
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
    public var description_literal : String {
        return is_zero ? "0" : (is_negative ? "-" : "") + numbers.map({ String(describing: $0) }).joined()
    }
    public var is_zero : Bool {
        return numbers.count == 0 || all_digits_satisfy({ $0 == 0 })
    }
    public var to_float : HugeFloat {
        return HugeFloat(integer: self)
    }
    public var to_remainder : HugeRemainder {
        return HugeRemainder(dividend: self, divisor: HugeInt.one)
    }
    public func to_int<T: BinaryInteger & LosslessStringConvertible>() -> T? {
        return T.init(description)
    }
    
    public func all_digits_satisfy(_ transform: (UInt8) -> Bool) -> Bool {
        return numbers.allSatisfy(transform)
    }
    
    /// - Warning: This is very resource intensive when using a big number.
    public func get_all_factors() -> Set<HugeInt> {
        let maximum:HugeInt = (self / 2).quotient
        return get_factors(maximum: maximum)
    }
    /// - Warning: This is very resource intensive when using a big number.
    public func get_factors(maximum: HugeInt) -> Set<HugeInt> {
        var maximum:HugeInt = maximum
        var array:Set<HugeInt> = [self]
        while maximum >= 2 {
            if self % maximum == HugeInt.zero {
                array.insert(maximum)
            }
            maximum -= 1
        }
        return array
    }
    /// - Warning: This assumes this number is less than or equal to the given number; can be very resource intensive when using big numbers.
    public func get_shared_factors(_ integer: HugeInt) -> Set<HugeInt>? {
        let (self_array, other_array):(Set<HugeInt>, Set<HugeInt>) = (get_all_factors(), integer.get_factors(maximum: self))
        let bigger_array:Set<HugeInt>, smaller_array:Set<HugeInt>
        if self_array.count > other_array.count {
            bigger_array = self_array
            smaller_array = other_array
        } else {
            bigger_array = other_array
            smaller_array = self_array
        }
        let array:Set<HugeInt> = bigger_array.filter({ smaller_array.contains($0) })
        return array.isEmpty ? nil : array
    }
    
    /// - Warning: This is very resource intensive when using a big number.
    public func get_all_factors_parallel() async -> Set<HugeInt> {
        let maximum:HugeInt = (self / 2).quotient
        return await get_factors_parallel(maximum: maximum)
    }
    /// - Warning: This is very resource intensive when using a big number.
    public func get_factors_parallel(maximum: HugeInt) async -> Set<HugeInt> {
        let this:HugeInt = self
        var maximum:HugeInt = maximum
        let factors:Set<HugeInt> = await withTaskGroup(of: HugeInt?.self, body: { group in
            while maximum >= 2 {
                let target_number:HugeInt = maximum
                group.addTask {
                    return this % target_number == HugeInt.zero ? target_number : nil
                }
                maximum -= 1
            }
            var array:Set<HugeInt> = [this]
            for await integer in group {
                if let integer:HugeInt = integer {
                    array.insert(integer)
                }
            }
            return array
        })
        return factors
    }
    /// - Warning: This assumes this number is less than or equal to the given number; can be very resource intensive when using big numbers.
    public func get_shared_factors_parallel(_ integer: HugeInt) async -> Set<HugeInt>? {
        let (self_array, other_array):(Set<HugeInt>, Set<HugeInt>) = await (get_all_factors_parallel(), integer.get_factors_parallel(maximum: self))
        let array:Set<HugeInt> = self_array.filter({ other_array.contains($0) })
        return array.isEmpty ? nil : array
    }
    
    public mutating func remove_trailing_zeros() {
        while numbers.first == 0 {
            numbers.removeFirst()
        }
    }
    public mutating func remove_leading_zeros() {
        while numbers.last == 0 {
            numbers.removeLast()
        }
    }
}

/*
 Comparable
 */
public extension HugeInt {
    static func < (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative == !right.is_negative
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
            return left.is_negative == !right.is_negative
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
}
public extension HugeInt {
    static func <= (left: HugeInt, right: HugeInt) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative == !right.is_negative
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
            return left.is_negative == !right.is_negative
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
 prefixes / postfixes
 */
public extension HugeInt {
    static prefix func - (value: HugeInt) -> HugeInt {
        return HugeInt(is_negative: !value.is_negative, value.numbers)
    }
    func factorial() -> HugeInt {
        let one:HugeInt = HugeInt.one
        var remaining_value:HugeInt = self
        var value:HugeInt = self
        while remaining_value != one {
            remaining_value -= 1
            value *= remaining_value
        }
        return value
    }
}
/*
 Misc
 */
public func abs(_ integer: HugeInt) -> HugeInt {
    return HugeInt(is_negative: false, integer.numbers)
}
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
        if left == HugeInt.zero {
            return right
        } else if right == HugeInt.zero {
            return left
        } else {
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
    }
    static func + (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left + HugeInt(right)
    }
    static func + (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return HugeInt(left) + right
    }
    
    static func += (left: inout HugeInt, right: HugeInt) {
        if left == HugeInt.zero {
            left.is_negative = right.is_negative
            left.numbers = right.numbers
        } else if right == HugeInt.zero {
            return
        } else {
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
        return left + -right
    }
    static func - (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left - HugeInt(right)
    }
    static func - (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return HugeInt(left) - right
    }
    
    static func -= (left: inout HugeInt, right: HugeInt) {
        left += -right
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
        
        var index:Int = 0, remaining_numbers:[UInt8] = bigger_numbers
        while index < smaller_numbers_length {
            let smaller_number:UInt8 = smaller_numbers[index]
            var bigger_number:UInt8 = remaining_numbers[index]
            if bigger_number < smaller_number {
                var next_index:Int = index + 1
                var next_value:UInt8 = remaining_numbers[next_index]
                if next_value == 0 {
                    while next_value == 0 {
                        next_index += 1
                        next_value = remaining_numbers[next_index]
                    }
                    remaining_numbers[next_index] -= 1
                    next_index -= 1
                    while next_index > index {
                        remaining_numbers[next_index] += 9
                        next_index -= 1
                    }
                } else {
                    remaining_numbers[next_index] -= 1
                }
                bigger_number += 10
            }
            result[index] = bigger_number - smaller_number
            index += 1
        }
        while index < result_count {
            result[index] = remaining_numbers[index]
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
        if left.is_zero || right.is_zero {
            return HugeInt.zero
        } else if left == HugeInt.one {
            return right
        } else if right == HugeInt.one {
            return left
        } else {
            let numbers:[UInt8] = HugeInt.multiply(left: left.numbers, right: right.numbers)
            let is_negative:Bool = !(left.is_negative == right.is_negative)
            return HugeInt(is_negative: is_negative, numbers)
        }
    }
    static func * (left: HugeInt, right: any BinaryInteger) -> HugeInt {
        return left * HugeInt(right)
    }
    static func * (left: any BinaryInteger, right: HugeInt) -> HugeInt {
        return right * HugeInt(left)
    }
    
    static func *= (left: inout HugeInt, right: HugeInt) {
        left.is_negative = !(left.is_negative == right.is_negative)
        left.numbers = HugeInt.multiply(left: left.numbers, right: right.numbers)
    }
    static func *= (left: inout HugeInt, right: any BinaryInteger) {
        left *= HugeInt(right)
    }
}
internal extension HugeInt {
    static func multiply(left: [UInt8], right: [UInt8], remove_leading_zeros: Bool = true) -> [UInt8] {
        let (bigger_numbers, smaller_numbers, _):([UInt8], [UInt8], Bool) = get_bigger_numbers(left: left, right: right)
        var result:[UInt8] = HugeInt.multiply(bigger_numbers: bigger_numbers, smaller_numbers: smaller_numbers)
        if remove_leading_zeros {
            while result.last == 0 {
                result.removeLast()
            }
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
    static func / (dividend: HugeInt, divisor: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        if dividend == HugeInt.zero {
            return (HugeInt.zero, divisor == HugeInt.zero ? nil : HugeRemainder(dividend: dividend, divisor: divisor))
        } else if divisor.numbers == [1] {
            if divisor.is_negative {
                return (-dividend, nil)
            } else {
                return (dividend, nil)
            }
        }
        guard dividend >= divisor else {
            return (HugeInt.zero, HugeRemainder(dividend: dividend, divisor: divisor))
        }
        return HugeInt.divide(dividend: dividend, divisor: divisor)
    }
    /*static func get_maximum_divisions(dividend: HugeInt, divisor: HugeInt) -> (result: HugeInt, remainder: HugeRemainder?) {
        let is_negative:Bool = !(dividend.is_negative == divisor.is_negative)
        var maximum_divisions:UInt64 = max(0, 10 * UInt64(dividend.length-divisor.length))
        var next_value:HugeInt = divisor * (maximum_divisions != 0 ? maximum_divisions : 1)
        let dividend:HugeInt = HugeInt(is_negative: false, dividend.numbers)
        print("HugeInt;get_maximum_divisions;dividend=" + dividend.description + ";divisor=" + divisor.description)
        while dividend >= next_value {
            //print("maximum_divisions=" + maximum_divisions.description + ";next_value=" + next_value.description)
            maximum_divisions += 1
            next_value += divisor
        }
        guard maximum_divisions > 0 else {
            return (HugeInt(is_negative: is_negative, "0"), HugeRemainder(dividend: dividend, divisor: divisor))
        }
        let subtracted_value:HugeInt = next_value - divisor
        let remainder:HugeInt = dividend - subtracted_value
        return (HugeInt(is_negative: is_negative, maximum_divisions-1), remainder.is_zero ? nil : HugeRemainder(dividend: remainder, divisor: divisor))
    }*/
    
    static func / (left: HugeInt, right: any BinaryInteger) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        return left / HugeInt(right)
    }
    static func / (left: any BinaryInteger, right: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        return HugeInt(left) / right
    }
    
    static func /= (left: inout HugeInt, right: HugeInt) {
        let quotient:HugeInt = (left / right).quotient
        left.is_negative = quotient.is_negative
        left.numbers = quotient.numbers
    }
    static func /= (left: inout HugeInt, right: any BinaryInteger) {
        left /= HugeInt(right)
    }
}
internal extension HugeInt {
    /// - Warning: Using this function assumes the dividend is greater than or equal to the divisor.
    static func divide(dividend: HugeInt, divisor: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        let is_negative:Bool = !(dividend.is_negative == divisor.is_negative)
        
        let dividend_numbers:[UInt8] = dividend.numbers
        var remaining_dividend:HugeInt = HugeInt(is_negative: false, dividend_numbers)
        let dividend_length:Int = dividend.length, divisor_length:Int = divisor.length
        let result_count:Int = dividend_length - divisor_length + 1
        var quotient_numbers:[UInt8] = [UInt8].init(repeating: 255, count: result_count)
        
        var included_digits:Int = divisor_length
        var quotient_index:Int = 0
        while remaining_dividend >= divisor {
            var divisible_dividend_numbers:[UInt8] = [UInt8].init(repeating: 0, count: included_digits)
            let remaining_dividend_numbers_reversed:[UInt8] = remaining_dividend.numbers.reversed()
            var index:Int = 0
            for i in 0..<included_digits {
                divisible_dividend_numbers[index] = remaining_dividend_numbers_reversed[i]
                index += 1
            }
            var divisible_dividend:HugeInt = HugeInt(is_negative: false, divisible_dividend_numbers.reversed())
            if divisible_dividend >= divisor {
                divisible_dividend -= divisor
                var subtracted_amount:HugeInt = divisor
                quotient_numbers[quotient_index] = 1
                while divisible_dividend >= divisor {
                    quotient_numbers[quotient_index] += 1
                    divisible_dividend -= divisor
                    subtracted_amount += divisor
                }
                quotient_index += 1
                let remaining_dividend_numbers:[UInt8] = remaining_dividend.numbers
                let remaining_dividend_numbers_count:Int = remaining_dividend_numbers.count
                if remaining_dividend_numbers[remaining_dividend_numbers_count-1] < 10 {
                    for _ in included_digits..<remaining_dividend_numbers_count {
                        subtracted_amount.numbers.insert(0, at: 0)
                    }
                }
                
                var bruh:[UInt8] = HugeInt.subtract(bigger_numbers: remaining_dividend_numbers, smaller_numbers: subtracted_amount.numbers)
                for _ in 0..<included_digits {
                    if bruh.last == 0 {
                        bruh.removeLast()
                    }
                }
                if bruh.last == 0 {
                    if quotient_index < result_count {
                        quotient_numbers[quotient_index] = 0
                        quotient_index += 1
                    }
                    bruh.removeLast()
                }
                remaining_dividend = HugeInt(is_negative: false, bruh)
                if included_digits > 1 {
                    included_digits -= 1
                }
            } else {
                included_digits += 1
            }
        }
        while quotient_numbers.last == 255 {
            quotient_numbers.removeLast()
        }
        
        var quotient:HugeInt = HugeInt(is_negative: is_negative, quotient_numbers.reversed())
        quotient.is_negative = is_negative
        
        let remainder:HugeRemainder?
        if remaining_dividend == HugeInt.zero {
            remainder = nil
        } else {
            remainder = HugeRemainder(dividend: remaining_dividend, divisor: divisor)
            let proof:HugeInt = quotient * divisor
            if proof != dividend && ((proof.is_negative ? proof - remaining_dividend : proof + remaining_dividend) != dividend) { // TODO: find more efficient alternative
                quotient.numbers.insert(0, at: 0)
            }
        }
        return (quotient, remainder)
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
 Square root
 */
public func sqrt(_ x: HugeInt) -> HugeFloat { // TODO: fix | doesn't support remainders
    guard x > HugeInt.zero else { return HugeFloat.zero }
    let numbers:[UInt8] = x.numbers
    guard let ending_number:UInt8 = numbers.first else { return HugeFloat.zero }
    let ending_root_1:UInt8, ending_root_2:UInt8
    switch ending_number {
    case 0:
        if let integer:Int = x.to_int() { // TODO: fix
            let closest:Int = get_closest_sqrt_number(integer)
            return HugeFloat(closest)
        } else {
            return HugeFloat(integer: HugeInt.zero) // TODO: fix
        }
    case 1:
        ending_root_1 = 1
        ending_root_2 = 9
        break
    case 4:
        ending_root_1 = 2
        ending_root_2 = 8
        break
    case 6:
        ending_root_1 = 4
        ending_root_2 = 6
        break
    case 9:
        ending_root_1 = 3
        ending_root_2 = 7
        break
    default:
        ending_root_1 = 5
        ending_root_2 = 5
        break
    }
    if numbers.count <= 2 {
        let result:UInt8 = ending_root_1 * ending_root_1 == x.to_int() ? ending_root_1 : ending_root_2
        return HugeFloat(result)
    }
    let first_numbers:Int = Int(numbers.reversed()[0..<numbers.count-2].map({ String(describing: $0) }).joined())!
    let first_result:Int = get_closest_sqrt_number(first_numbers)
    let second_value:Int = first_result * (first_result + 1)
    let second_result:UInt8 = first_numbers < second_value ? ending_root_1 : ending_root_2
    return HugeFloat(UInt64(String(describing: first_result) + String(describing: second_result))!)
}
private func get_closest_sqrt_number(_ number: Int, starting_number: Int = 4) -> Int {
    for index in starting_number...45_000 {
        let squared:Int = index * index
        if number < squared {
            return index-1
        }
    }
    return 0
}
public extension HugeInt {
    /// - Parameters:
    ///     - amount: how many times to multiply by itself.
    func squared(amount: UInt64 = 2) -> HugeInt {
        var result:HugeInt = self
        for _ in 0..<amount {
            result *= result
        }
        return result
    }
}
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

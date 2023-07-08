//
//  HugeInt.swift
//  
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

public struct HugeInt : SomeHugeInt {
    /// Default value is 100 decimal places.
    public static var default_precision:HugeInt = HugeInt(is_negative: false, [0, 0, 1])
    /// 6 decimal places.
    public static let float_precision:HugeInt = HugeInt(is_negative: false, [6])
    /// 15 decimal places.
    public static let double_precision:HugeInt = HugeInt(is_negative: false, [5, 1])
    
    public static let zero:HugeInt = HugeInt(is_negative: false, [])
    public static let one:HugeInt = HugeInt(is_negative: false, [1])
    
    public static func random(in range: Range<HugeInt>) -> HugeInt {
        let minimum_integer:UInt64 = range.lowerBound.to_int()!, maximum_integer:UInt64 = range.upperBound.to_int()!
        let number:UInt64 = UInt64.random(in: minimum_integer...maximum_integer)
        return HugeInt(number)
    }
        
    public var is_negative:Bool
    public var numbers:[Int8]
    
    public init(is_negative: Bool, _ numbers: [Int8]) {
        self.is_negative = is_negative
        self.numbers = numbers.count == 1 && numbers[0] == 0 ? [] : numbers
    }
    public init<T: StringProtocol & RangeReplaceableCollection>(_ string: T) {
        self.init(string, remove_leading_zeros: true)
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
            self.numbers = characters.map({ Int8(exactly: $0.wholeNumberValue!)! }).reversed()
        }
    }
    
    public init<T: StringProtocol & RangeReplaceableCollection>(is_negative: Bool, _ string: T) {
        self.init(string)
        self.is_negative = is_negative
    }
    public init(is_negative: Bool, _ numbers: ArraySlice<Int8>) {
        self.init(is_negative: is_negative, Array(numbers))
    }
    public init(is_negative: Bool, _ integer: any BinaryInteger) {
        self.init(is_negative: is_negative, String(describing: integer))
    }
    
    /// The number the digits represent, in reverse order.
    public var description_literal : String {
        return is_zero ? "0" : (is_negative ? "-" : "") + numbers.map({ String(describing: $0) }).joined()
    }
    
    public var to_float : AnyHugeFloat {
        return HugeFloat(integer: self)
    }
    /// Converts this huge integer to a ``HugeRemainder``.
    public var to_remainder : HugeRemainder {
        return HugeRemainder(dividend: self, divisor: HugeInt.one)
    }
    
    /// - Warning: Very resource intensive when using a big number.
    public func get_all_factors() -> Set<Self> {
        let maximum:Self = (self / 2).quotient
        return get_factors(maximum: maximum)
    }
    /// - Parameters:
    ///     - maximum: the starting number
    /// - Complexity: O(_n_ - 1) where _n_ is equal to the _maximum_ parameter.
    /// - Warning: Very resource intensive when using a big number.
    public func get_factors(maximum: Self) -> Set<Self> {
        var maximum:Self = maximum
        var array:Set<Self> = [self]
        let two:Self = Self(is_negative: false, [2]), one:Self = Self.one
        while maximum >= two {
            if (self % maximum).is_zero {
                array.insert(maximum)
            }
            maximum.subtract(one)
        }
        return array
    }
    /// - Warning: This function assumes self is less than or equal to `integer`.
    /// - Warning: Very resource intensive when using big numbers.
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
    
    /// - Warning: Very resource intensive when using a big number.
    public func get_all_factors_parallel() async -> Set<Self> {
        let maximum:Self = (self / 2).quotient
        return await get_factors_parallel(maximum: maximum)
    }
    /// - Warning: Very resource intensive when using a big number.
    public func get_factors_parallel(maximum: Self) async -> Set<Self> {
        let this:Self = self
        var maximum:Self = maximum
        let two:Self = Self(is_negative: false, [2]), one:Self = Self.one
        return await withTaskGroup(of: Self?.self, body: { group in
            while maximum >= two {
                let target_number:Self = maximum
                group.addTask {
                    return (this % target_number).is_zero ? target_number : nil
                }
                maximum.subtract(one)
            }
            var array:Set<Self> = [this]
            for await integer in group {
                if let integer:Self = integer {
                    array.insert(integer)
                }
            }
            return array
        })
    }
    /// - Warning: This function assumes self is less than or equal to the given number.
    /// - Warning: Very resource intensive when using big numbers.
    public func get_shared_factors_parallel(_ integer: Self) async -> Set<Self>? {
        let (self_array, other_array):(Set<Self>, Set<Self>) = await (get_all_factors_parallel(), integer.get_factors_parallel(maximum: self))
        let array:Set<Self> = self_array.filter({ other_array.contains($0) })
        return array.isEmpty ? nil : array
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
    let numbers:[Int8] = x.numbers
    guard let ending_number:Int8 = numbers.first else { return HugeFloat.zero }
    let ending_root_1:Int8, ending_root_2:Int8
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
        let result:Int8 = ending_root_1 * ending_root_1 == x.to_int() ? ending_root_1 : ending_root_2
        return HugeFloat(result)
    }
    let first_numbers:Int = Int(numbers.reversed()[0..<numbers.count-2].map({ String(describing: $0) }).joined())!
    let first_result:Int = get_closest_sqrt_number(first_numbers)
    let second_value:Int = first_result * (first_result + 1)
    let second_result:Int8 = first_numbers < second_value ? ending_root_1 : ending_root_2
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

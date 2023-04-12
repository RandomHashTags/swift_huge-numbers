//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: expand functionality
public struct HugeFloat : Hashable, Comparable {
    public static var pi_default_precision:HugeInt = HugeInt("1000")
    public static func pi(precision: HugeInt = pi_default_precision) -> HugeFloat { // TODO: finish
        let (division_result, division_remainder):(HugeInt, HugeRemainder) = 180 / precision
        return HugeFloat("0") // TODO: add trig arithmetic
    }
    
    private var pre_decimal_number:HugeInt
    private var post_decimal_number:HugeInt
    private var exponent:Int
    private var remainder:HugeRemainder? = nil
    
    public var is_negative : Bool {
        return pre_decimal_number.is_negative
    }
    
    public init(pre_decimal_number: HugeInt, post_decimal_number: HugeInt, exponent: Int, remainder: HugeRemainder? = nil) {
        self.pre_decimal_number = pre_decimal_number
        self.post_decimal_number = post_decimal_number
        self.exponent = exponent
        self.remainder = remainder
    }
    
    public init(_ string: String) {
        self.init(string: string)
    }
    /// This init is only here because Xcode cannot link the ambiguous version.
    public init(string: String) {
        let values:[Substring] = string.split(separator: ".")
        let target_pre_decimal_number:Substring = values[0]
        var target_post_decimal_number:Substring = values.get(1) ?? "0"
        if let exponent_range:Range<Substring.Index> = target_post_decimal_number.rangeOfCharacter(from: ["e", "E"]) {
            let is_negative:Bool = target_pre_decimal_number[target_pre_decimal_number.startIndex] == "-"
            let exponent_string:Substring = target_post_decimal_number[exponent_range.upperBound..<target_post_decimal_number.endIndex]
            target_post_decimal_number = target_post_decimal_number[target_post_decimal_number.startIndex..<exponent_range.lowerBound]
            target_post_decimal_number.remove_trailing_zeros()
            exponent = Int(exponent_string)!
            if exponent < 0 {
                pre_decimal_number = HugeInt(is_negative: is_negative, [])
                var post_numbers:[UInt8] = [UInt8].init(repeating: 0, count: abs(exponent) + target_post_decimal_number.count)
                var index:Int = target_post_decimal_number.count-1
                for pre_number_char in target_pre_decimal_number {
                    post_numbers[index] = UInt8(exactly: pre_number_char.wholeNumberValue!)!
                    index -= 1
                }
                index = target_post_decimal_number.count
                for post_number_char in target_post_decimal_number {
                    post_numbers[index] = UInt8(exactly: post_number_char.wholeNumberValue!)!
                    index += 1
                }
                post_decimal_number = HugeInt(is_negative: false, post_numbers)
            } else {
                pre_decimal_number = HugeInt(target_pre_decimal_number)
                post_decimal_number = HugeInt(target_post_decimal_number)
            }
        } else if let _:Range<Substring.Index> = string.rangeOfCharacter(from: ["r"]) {
            let values:[Substring] = string.split(separator: "r"), remainder_string:[Substring] = values[1].split(separator: "/")
            pre_decimal_number = HugeInt(values[0])
            post_decimal_number = HugeInt.zero
            exponent = 0
            remainder = HugeRemainder(dividend: HugeInt(remainder_string[0]), divisor: HugeInt(remainder_string[1]))
        } else {
            pre_decimal_number = HugeInt(target_pre_decimal_number)
            target_post_decimal_number.remove_trailing_zeros()
            post_decimal_number = HugeInt(target_post_decimal_number)
            exponent = 0
        }
    }
    
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    public init(_ float: any FloatingPoint) {
        self.init(String(describing: float))
    }
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    public var represented_float : Float {
        return Float(description) ?? 0
    }
    public var description : String {
        return (is_negative ? "-" : "") + literal_description
    }
    public var literal_description : String {
        let suffix:String
        if let remainder:HugeRemainder = remainder {
            suffix = "r" + remainder.description
        } else {
            suffix = "." + post_decimal_number.literal_description
        }
        return pre_decimal_number.literal_description + suffix
    }
    
    public var description_simplified : String {
        var description:String = literal_description
        if pre_decimal_number == 0 {
            description.removeFirst()
            var exponent:Int = exponent
            while exponent < 0 {
                description.removeFirst()
                exponent += 1
            }
            description.insert(".", at: description.index(description.startIndex, offsetBy: 1))
        } else {
            description.remove_trailing_zeros()
        }
        return (is_negative ? "-" : "") + description + (exponent != 0 ? "e" + String(describing: exponent) : "")
    }
    
    public func to_radians() -> HugeFloat {
        return self * 0.01745329252
    }
    public func to_degrees(precision: HugeInt = pi_default_precision) -> HugeFloat { // TODO: support trig arithemtic
        return self * (180 / HugeFloat.pi(precision: precision))
    }
}
/*
 Comparable
 */
public extension HugeFloat {
    static func == (left: HugeFloat, right: HugeFloat) -> Bool {
        return left.is_negative == right.is_negative && left.exponent == right.exponent && left.pre_decimal_number == right.pre_decimal_number && left.post_decimal_number == right.post_decimal_number
    }
    static func == (left: HugeFloat, right: HugeInt) -> Bool {
        return left == right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func == (left: HugeFloat, right: any FloatingPoint) -> Bool {
        return left == HugeFloat(right)
    }
    static func == (left: HugeFloat, right: any BinaryInteger) -> Bool {
        return left == HugeFloat(right)
    }
}
public extension HugeFloat {
    static func < (left: HugeFloat, right: HugeFloat) -> Bool {
        guard left.is_negative == right.is_negative else {
            return left.is_negative && !right.is_negative
        }
        guard left.exponent >= right.exponent else { return true }
        let left_pre_decimal_number:HugeInt = left.pre_decimal_number, right_pre_decimal_number:HugeInt = right.pre_decimal_number
        return left_pre_decimal_number < right_pre_decimal_number || left_pre_decimal_number == right_pre_decimal_number && left.post_decimal_number < right.post_decimal_number
    }
}
/*
 prefixes
 */
public extension HugeFloat {
    static prefix func - (value: HugeFloat) -> HugeFloat {
        return HugeFloat(pre_decimal_number: -value.pre_decimal_number, post_decimal_number: value.post_decimal_number, exponent: value.exponent, remainder: value.remainder)
    }
}
/*
 Addition
 */
public extension HugeFloat {
    static func + (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let bigger_pre_int:HugeInt = left.pre_decimal_number, smaller_pre_int:HugeInt = right.pre_decimal_number
        var (bigger_post_int, smaller_post_int, _):(HugeInt, HugeInt, Bool) = HugeInt.get_bigger_int(left: left.post_decimal_number, right: right.post_decimal_number)
        let bigger_post_length:Int = bigger_post_int.length, smaller_post_length:Int = smaller_post_int.length
        let result_decimal_count:Int = bigger_post_length
        
        if bigger_post_length != result_decimal_count {
            bigger_post_int.numbers.insert(0, at: 0)
        } else if smaller_post_length != result_decimal_count {
            smaller_post_int.numbers.insert(0, at: 0)
        }
        
        var pre_decimal_result:HugeInt = bigger_pre_int + smaller_pre_int
        var post_decimal_result:HugeInt = bigger_post_int + smaller_post_int
        
        let moved_decimal_count:Int = post_decimal_result.length - result_decimal_count
        if moved_decimal_count > 0 {
            let moved_decimals:[UInt8] = post_decimal_result.numbers[moved_decimal_count..<post_decimal_result.numbers.count].map({ $0 })
            pre_decimal_result = HugeInt(is_negative: false, HugeInt.add(left: pre_decimal_result.numbers, right: moved_decimals).result)
            post_decimal_result.numbers.removeLast(moved_decimal_count)
            post_decimal_result.remove_trailing_zeros()
        }
        return HugeFloat(pre_decimal_number: pre_decimal_result, post_decimal_number: post_decimal_result, exponent: 0)
    }
    static func + (left: HugeFloat, right: HugeInt) -> HugeFloat {
        return left + right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func + (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left + HugeFloat(right)
    }
    static func + (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left + HugeFloat(right)
    }
}
/*
 Multiplication
 */
public extension HugeFloat {
    static func * (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let left_post_number:HugeInt = left.post_decimal_number, right_post_number:HugeInt = right.post_decimal_number
        let result_decimal_places:Int = left_post_number.length + right_post_number.length
        
        var left_numbers:[UInt8] = left_post_number.numbers
        left_numbers.append(contentsOf: left.pre_decimal_number.numbers)
        
        var right_numbers:[UInt8] = right_post_number.numbers
        right_numbers.append(contentsOf: right.pre_decimal_number.numbers)
        
        var result:[UInt8] = HugeInt.multiply(left: left_numbers, right: right_numbers)
        
        let is_negative:Bool = left.is_negative == !right.is_negative
        let pre_decimal_numbers:[UInt8] = result[result_decimal_places...].map({ $0 })
        let pre_decimal_number:HugeInt = HugeInt(is_negative: is_negative, pre_decimal_numbers)
        
        while result.first == 0 {
            result.removeFirst()
        }
        let post_decimal_numbers:[UInt8] = result[0..<result_decimal_places].map({ $0 })
        let post_decimal_number:HugeInt = HugeInt(is_negative: false, post_decimal_numbers)
        
        return HugeFloat(pre_decimal_number: pre_decimal_number, post_decimal_number: post_decimal_number, exponent: 0) // TODO: fix exponent
    }
    static func * (left: HugeFloat, right: HugeInt) -> HugeFloat {
        return left * right.to_float
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func * (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left * HugeFloat(right)
    }
    static func * (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left * HugeFloat(right)
    }
}
/*
 Division
 */
public extension HugeFloat {
    static func / (left: HugeFloat, right: HugeFloat) -> HugeFloat { // TODO: finish
        let left_post_number:HugeInt = left.post_decimal_number, right_post_number:HugeInt = right.post_decimal_number
        let left_post_number_length:Int = left_post_number.length, right_post_number_length:Int = right_post_number.length
        
        let post_number:HugeInt
        if left_post_number_length == right_post_number_length {
            //post_number = left_post_number / right_post_number
        }
        return HugeFloat("0")
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left / HugeFloat(right)
    }
    /// - Warning: The float will not be represented literally. It will be set to the closest double-precision floating point number. Use ``HugeFloat/init(string:)`` for literal representation.
    static func / (left: any FloatingPoint, right: HugeFloat) -> HugeFloat {
        return HugeFloat(left) / right
    }
}

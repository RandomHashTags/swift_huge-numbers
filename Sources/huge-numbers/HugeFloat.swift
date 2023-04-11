//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

// TODO: expand functionality
public struct HugeFloat : Hashable, Comparable {
    private var pre_decimal_number:HugeInt
    private var post_decimal_number:HugeInt
    private var exponent:Int
    
    public var is_negative : Bool {
        return pre_decimal_number.is_negative
    }
    
    public init(pre_decimal_number: HugeInt, post_decimal_number: HugeInt, exponent: Int) {
        self.pre_decimal_number = pre_decimal_number
        self.post_decimal_number = post_decimal_number
        self.exponent = exponent
    }
    public init(_ string: String) {
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
        } else {
            pre_decimal_number = HugeInt(target_pre_decimal_number)
            target_post_decimal_number.remove_trailing_zeros()
            post_decimal_number = HugeInt(target_post_decimal_number)
            exponent = 0
        }
    }
    
    public init(_ float: any FloatingPoint) {
        self.init(String(describing: float))
    }
    
    var description : String {
        return (is_negative ? "-" : "") + literal_description
    }
    var literal_description : String {
        return pre_decimal_number.description + "." + post_decimal_number.description
    }
    
    var description_simplified : String {
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
}
/*
 Comparable
 */
public extension HugeFloat {
    static func == (left: HugeFloat, right: HugeFloat) -> Bool {
        return left.is_negative == right.is_negative && left.exponent == right.exponent && left.pre_decimal_number == right.pre_decimal_number && left.post_decimal_number == right.post_decimal_number
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
 Addition
 */
public extension HugeFloat {
    static func + (left: HugeFloat, right: HugeFloat) -> HugeFloat {
        let left_post_number:HugeInt = left.post_decimal_number, right_post_number:HugeInt = right.post_decimal_number
        let result_decimal_places:Int = max(left_post_number.length, right_post_number.length)
        
        var left_numbers:[UInt8] = left_post_number.numbers
        left_numbers.append(contentsOf: left.pre_decimal_number.numbers)
        
        var right_numbers:[UInt8] = right_post_number.numbers
        right_numbers.append(contentsOf: right.pre_decimal_number.numbers)
        
        var (result, left_is_bigger):([UInt8], Bool) = HugeInt.add(left: left_numbers, right: right_numbers) // TODO: fix
        
        let is_negative:Bool = left.is_negative == !right.is_negative
        let pre_decimal_numbers:[UInt8] = result.dropFirst(result_decimal_places).map({ $0 })
        let pre_decimal_number:HugeInt = HugeInt(is_negative: is_negative, pre_decimal_numbers)
        
        while result.first == 0 {
            result.removeFirst()
        }
        let post_decimal_numbers:[UInt8] = result[result_decimal_places...].map({ $0 })
        let post_decimal_number:HugeInt = HugeInt(is_negative: false, post_decimal_numbers)
        
        return HugeFloat(pre_decimal_number: pre_decimal_number, post_decimal_number: post_decimal_number, exponent: 0) // TODO: fix exponent
    }
    static func + (left: HugeFloat, right: HugeInt) -> HugeFloat {
        return left + right.to_float
    }
    static func + (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left + HugeFloat(right)
    }
    static func + (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left + HugeFloat(String(describing: right))
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
    static func * (left: HugeFloat, right: any FloatingPoint) -> HugeFloat {
        return left * HugeFloat(right)
    }
    static func * (left: HugeFloat, right: any BinaryInteger) -> HugeFloat {
        return left * HugeFloat(String(describing: right))
    }
}

//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

public struct HugeFloat : Hashable { // TODO: expand functionality
    private var pre_decimal_number:HugeInt
    private var post_decimal_number:HugeInt
    private var exponent:Int
    
    public var is_negative : Bool {
        return pre_decimal_number.is_negative
    }
    
    public init(_ string: String) {
        let values:[Substring] = string.split(separator: ".")
        let target_pre_decimal_number:Substring = values[0]
        var target_post_decimal_number:Substring = values[1]
        if let exponent_range:Range<Substring.Index> = target_post_decimal_number.rangeOfCharacter(from: ["e", "E"]) {
            let is_negative:Bool = target_pre_decimal_number[target_pre_decimal_number.startIndex] == "-"
            let exponent_string:Substring = target_post_decimal_number[exponent_range.upperBound..<target_post_decimal_number.endIndex]
            target_post_decimal_number = target_post_decimal_number[target_post_decimal_number.startIndex..<exponent_range.lowerBound]
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
            post_decimal_number = HugeInt(target_post_decimal_number)
            exponent = 0
        }
    }
    
    public init(_ float: any ExpressibleByFloatLiteral) {
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
            while description.last == "0" {
                description.removeLast()
            }
        }
        return (is_negative ? "-" : "") + description + (exponent != 0 ? "e" + String(describing: exponent) : "")
    }
}

public extension HugeFloat {
    
}

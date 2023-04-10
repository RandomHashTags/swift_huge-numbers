//
//  HugeFloat.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

public struct HugeFloat { // TODO: expand functionality
    private var pre_decimal_number:HugeInt
    private var post_decimal_number:HugeInt
    
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
            let exponent:Int = Int(exponent_string)!
            if exponent < 0 {
                pre_decimal_number = HugeInt(is_negative: is_negative, [0])
                var post_numbers:[UInt8] = [UInt8].init(repeating: 0, count: abs(exponent) + target_post_decimal_number.count)
                var index:Int = target_post_decimal_number.count
                for post_number_char in target_post_decimal_number {
                    post_numbers[index] = UInt8(exactly: post_number_char.wholeNumberValue!)!
                    index += 1
                }
                post_decimal_number = HugeInt(is_negative: false, post_numbers)
            } else {
                let decimal_index:Substring.Index = string.index(string.startIndex, offsetBy: target_pre_decimal_number.count)
                target_post_decimal_number.remove(at: decimal_index)
                pre_decimal_number = HugeInt(target_pre_decimal_number)
                post_decimal_number = HugeInt(target_post_decimal_number)
            }
        } else {
            pre_decimal_number = HugeInt(target_pre_decimal_number)
            post_decimal_number = HugeInt(target_post_decimal_number)
        }
    }
    
    public init(_ float: any ExpressibleByFloatLiteral) {
        self.init(String(describing: float))
    }
    
    var description : String {
        return pre_decimal_number.description + "." + post_decimal_number.description
    }
    
    /*var description_simplified : String { // TODO: get exponent?
        let sign:String = is_negative ? "-" : ""
        let pre_decimal_string:String = pre_decimal_numbers.map({ String(describing: $0) }).joined()
        let post_decimal_string:String = post_decimal_numbers.map({ String(describing: $0) }).joined()
        return sign + pre_decimal_string + "." + post_decimal_string + (exponent != 0 ? "e" + String(describing: exponent) : "")
    }*/
}

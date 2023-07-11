//
//  huge_numbers.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
public extension String.LocalizationValue.StringInterpolation {
    mutating func appendLiteral(_ value: HugeInt) {
        // TODO: fix (doesn't support any number larger than UInt64.max)
        let number:Int = value.to_int() ?? -1
        appendInterpolation(number)
    }
    mutating func appendInterpolation(_ value: HugeInt) {
        appendLiteral(value)
    }
    
    mutating func appendLiteral(_ value: HugeFloat) {
        // TODO: fix (doesn't support any number larger than Double.max -> gets represented as an infinity symbol; only supports 6 decimal digits; can only be represented in base 2)
        let number:Float = value.represented_float
        appendInterpolation(number)
    }
    mutating func appendInterpolation(_ value: HugeFloat) {
        appendLiteral(value)
    }
}

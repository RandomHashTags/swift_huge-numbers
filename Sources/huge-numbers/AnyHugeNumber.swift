//
//  AnyHugeNumber.swift
//  
//
//  Created by Evan Anderson on 7/7/23.
//

import Foundation

// MARK: AnyHugeNumber
public protocol AnyHugeNumber : Codable, CustomStringConvertible {
    static var zero : Self { get }
    static var one : Self { get }
    
    init<T: StringProtocol & RangeReplaceableCollection>(_ string: T)
    
    var is_negative : Bool { get set }
    
    var description_literal : String { get }
    
    /// Whether or not this huge number equals zero.
    var is_zero : Bool { get }
    
    /// Toggles ``is_negative``.
    mutating func flip_sign()
    /// Creates a new ``Self`` and toggles its ``is_negative`` value.
    func flipped_sign() -> Self
    
    func formatted(style: NumberFormatter.Style) -> String?
}
public extension AnyHugeNumber {
    init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    mutating func flip_sign() {
        is_negative = !is_negative
    }
    
    init(from decoder: Decoder) throws {
        let container:SingleValueDecodingContainer = try decoder.singleValueContainer()
        let string:String = try container.decode(String.self)
        self.init(string)
    }
    func encode(to encoder: Encoder) throws {
        var container:SingleValueEncodingContainer = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    func formatted(style: NumberFormatter.Style = NumberFormatter.Style.decimal) -> String? {
        let formatter:NumberFormatter = NumberFormatter()
        formatter.numberStyle = style
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = (self as? HugeFloat)?.decimal?.value.length ?? 0
        formatter.thousandSeparator = ","
        formatter.decimalSeparator = "."
        return formatter.string(from: self)
    }
}
private struct Brother {
    var test:AnyHugeNumber
}

// MARK: HugeNumber
public protocol HugeNumber : Hashable, Comparable, AnyHugeNumber {
}
public extension HugeNumber {
    static func < (left: Self, right: any BinaryInteger) -> Bool {
        return left < Self(right)
    }
    static func < (left: any BinaryInteger, right: Self) -> Bool {
        return Self(left) < right
    }
    
    static func > (left: Self, right: any BinaryInteger) -> Bool {
        return left > Self(right)
    }
    static func > (left: any BinaryInteger, right: Self) -> Bool {
        return Self(left) > right
    }
}


// MARK: Global Extensions
public extension NumberFormatter {
    /// - Warning: only supports `NumberFormatter.Style.none` and  `NumberFormatter.Style.decimal` for now
    func string(from number: AnyHugeNumber) -> String? {
        guard numberStyle != .none else { return String(describing: number) }
        switch number {
        case is AnyHugeInt:
            return format_integer(number as! AnyHugeInt)
        case is AnyHugeFloat:
            return format_float(number as! AnyHugeFloat, remainder_precision: HugeInt.default_precision)
        default:
            return nil
        }
    }
}

private extension NumberFormatter {
    func format_float(_ float: AnyHugeFloat, remainder_precision: AnyHugeInt) -> String? {
        switch numberStyle {
        case .decimal: return format_float_decimal(float, remainder_precision: remainder_precision)
        default: return nil
        }
    }
    func format_float_decimal(_ float: AnyHugeFloat, remainder_precision: AnyHugeInt) -> String {
        var string:String = format_integer_decimal(float.integer_generic)
        guard minimumFractionDigits >= 0, maximumFractionDigits > 0 else { return string }
        if alwaysShowsDecimalSeparator, let decimalSeparator:String = decimalSeparator {
            string.append(decimalSeparator)
        }
        var decimal_string:String
        if let decimal_value:HugeInt = float.rounded(UInt(maximumFractionDigits), remainder_precision: remainder_precision).decimal?.value {
            decimal_string = String(describing: decimal_value)
        } else {
            decimal_string = ""
        }
        if decimal_string.count < minimumFractionDigits {
            decimal_string.append((decimal_string.count..<minimumFractionDigits).map({ _ in "0" }).joined())
        }
        string.append(decimal_string)
        return string
    }
}

private extension NumberFormatter {
    func format_integer(_ integer: AnyHugeInt) -> String? {
        switch numberStyle {
        case .decimal: return format_integer_decimal(integer)
        default: return nil
        }
    }
    func format_integer_decimal(_ integer: AnyHugeInt) -> String {
        var string:String = String(describing: integer)
        guard let thousand_separator:String = thousandSeparator else { return string }
        let thousand_separator_length:Int = thousand_separator.count-1
        let commas:Int = (integer.length-1) / 3
        let end_index:String.Index = string.endIndex
        for i in 1...commas {
            let offset:Int
            if i == 1 {
                offset = -(i * 3)
            } else {
                offset = -(i * (3 + thousand_separator_length))
            }
            string.insert(contentsOf: thousand_separator, at: string.index(end_index, offsetBy: offset))
        }
        return string
    }
}

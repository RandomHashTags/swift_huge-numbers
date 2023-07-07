//
//  huge_numbers.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

public protocol AnyHugeNumber : Codable, CustomStringConvertible {
    static var zero : Self { get }
    static var one : Self { get }
    
    init<T: StringProtocol & RangeReplaceableCollection>(_ string: T)
    
    var is_negative : Bool { get }
    
    var description_literal : String { get }
    
    /// Whether or not this huge number equals zero.
    var is_zero : Bool { get }
}
public extension AnyHugeNumber {
    init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
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
}

public protocol HugeNumber : Hashable, Comparable, AnyHugeNumber {
    associatedtype DivisionResult
    
    static func == (left: Self, right: Self) -> Bool
    
    static func < (left: Self, right: Self) -> Bool
    static func <= (left: Self, right: Self) -> Bool
    
    static func > (left: Self, right: Self) -> Bool
    static func >= (left: Self, right: Self) -> Bool
    
    static func + (left: Self, right: Self) -> Self
    static func - (left: Self, right: Self) -> Self
    static func * (left: Self, right: Self) -> Self
    static func / (left: Self, right: Self) -> DivisionResult
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

private struct Brother {
    var test:AnyHugeNumber
}

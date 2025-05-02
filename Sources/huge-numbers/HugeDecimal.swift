//
//  HugeDecimal.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

public struct HugeDecimal : Hashable, CustomStringConvertible {
    
    public static let zero:HugeDecimal = HugeDecimal(value: HugeInt.zero)
    
    /// The `HugeInt` that represents this decimal.
    public private(set) var value:HugeInt
    /// The infinitely repeating numbers, in reverse order.
    public private(set) var repeating_numbers:[Int8]?
    
    public init(value: HugeInt, repeating_numbers: [Int8]? = nil) {
        self.value = value
        self.repeating_numbers = repeating_numbers
    }
    public init<T: StringProtocol & RangeReplaceableCollection>(_ string: T, removeLeadingZeros: Bool = true, repeating_numbers: [Int8]? = nil) {
        self.init(value: HugeInt(string, removeLeadingZeros: removeLeadingZeros), repeating_numbers: repeating_numbers)
    }
    
    /// The number the digits represent.
    @inlinable
    public var description: String {
        if let repeating_numbers:[Int8] = repeating_numbers {
            return value.description + String(repeating_numbers.reversed().map({ $0.repeatingSymbol }))
        } else {
            return value.description
        }
    }
    
    /// The number the digits represent, in reverse order.
    @inlinable
    public var descriptionLiteral : String {
        if let repeating_numbers:[Int8] = repeating_numbers {
            return value.description + String(repeating_numbers.map({ $0.repeatingSymbol }))
        } else {
            return value.descriptionLiteral
        }
    }
    
    /// Whether or not this huge decimal equals zero.
    @inlinable
    public var isZero : Bool {
        return value.isZero && (repeating_numbers == nil || repeating_numbers!.allSatisfy({ $0 == 0 }))
    }
    
    /// Returns a `HugeRemainder` in which the decimal is the _dividend_, and the divisor is _10 to the power of decimal length plus one_.
    @inlinable
    public var toRemainder : HugeRemainder {
        var divisor_numbers:[Int8] = [Int8].init(repeating: 0, count: value.length+1)
        divisor_numbers[divisor_numbers.count-1] = 1
        let divisor = HugeInt(isNegative: value.isNegative, divisor_numbers)
        return HugeRemainder(dividend: value, divisor: divisor)
    }
    
    /// Returns the distance to the next whole number.
    @inlinable
    public var distance_to_next_quotient : HugeDecimal {
        let value_numbers:[Int8] = value.numbers.reversed()
        var numbers:[Int8] = [Int8].init(repeating: 0, count: value_numbers.count)
        let indices:Range<Int> = value_numbers.indices
        for index in indices {
            numbers[index] = 9 - value_numbers[index]
        }
        numbers[indices.last!] += 1
        return HugeDecimal(value: HugeInt(isNegative: false, numbers.reversed()))
    }
}

// MARK: Comparable
extension HugeDecimal: Comparable {
    @inlinable
    public static func < (lhs: HugeDecimal, rhs: HugeDecimal) -> Bool {
        return lhs.value < rhs.value
    }
    @inlinable
    public static func < (lhs: HugeDecimal, rhs: any BinaryInteger) -> Bool {
        return lhs.value < HugeInt(rhs)
    }

    @inlinable
    public static func <= (lhs: HugeDecimal, rhs: HugeDecimal) -> Bool {
        return lhs.value <= rhs.value
    }
    @inlinable
    public static func <= (lhs: HugeDecimal, rhs: any BinaryInteger) -> Bool {
        return lhs.value < HugeInt(rhs)
    }

    @inlinable
    public func is_less_than(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self < value
    }
    @inlinable
    public func is_less_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self <= value
    }
}
extension HugeDecimal {
    @inlinable
    public static func > (lhs: HugeDecimal, rhs: HugeDecimal) -> Bool {
        return lhs.value > rhs.value
    }
    @inlinable
    public static func > (lhs: HugeDecimal, rhs: any BinaryInteger) -> Bool {
        return lhs.value > HugeInt(rhs)
    }

    @inlinable
    public static func >= (lhs: HugeDecimal, rhs: HugeDecimal) -> Bool {
        return lhs.value >= rhs.value
    }
    @inlinable
    public static func >= (lhs: HugeDecimal, rhs: any BinaryInteger) -> Bool {
        return lhs.value >= HugeInt(rhs)
    }

    @inlinable
    public func is_greater_than(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self > value
    }
    @inlinable
    public func is_greater_than_or_equal_to(_ value: HugeDecimal?) -> Bool {
        guard let value:HugeDecimal = value else { return true }
        return self >= value
    }
}
extension HugeDecimal {
    @inlinable
    public static func == (lhs: HugeDecimal, rhs: HugeDecimal) -> Bool {
        return lhs.value == rhs.value && lhs.repeating_numbers == rhs.repeating_numbers
    }
}

// MARK: Prefixes/postfixes
extension HugeDecimal {
    @inlinable
    public static prefix func - (value: HugeDecimal) -> HugeDecimal {
        return HugeDecimal(value: -value.value, repeating_numbers: value.repeating_numbers)
    }
}
/*
 Addition
 */
public extension HugeDecimal {
    static func + (lhs: HugeDecimal, rhs: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) {
        return HugeDecimal.add(lhs: lhs, rhs: rhs)
    }
    
    /// - Warning: This doesn't add the resulting quotient to the `lhs` variable.
    static func += (lhs: inout HugeDecimal, rhs: HugeDecimal) { // TODO: support addition of repeating numbers
        lhs = HugeDecimal.add(lhs: lhs, rhs: rhs).result
    }
}
extension HugeDecimal {
    static func add(lhs: HugeDecimal, rhs: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) { // TODO: support addition of repeating numbers
        var leftValue:HugeInt = lhs.value, rightValue:HugeInt = rhs.value
        let decimal_length:Int = max(leftValue.length, rightValue.length)
        while leftValue.length < decimal_length {
            leftValue.numbers.insert(0, at: 0)
        }
        while rightValue.length < decimal_length {
            rightValue.numbers.insert(0, at: 0)
        }
        var result:HugeInt = leftValue + rightValue, result_length:Int = result.length
        var quotient:HugeInt? = nil
        if result_length > decimal_length {
            let difference:Int = result_length - decimal_length
            quotient = HugeInt(isNegative: false, result.numbers[decimal_length..<result_length])
            for _ in 0..<difference {
                result.numbers.removeLast()
            }
        } else if result_length < decimal_length {
            let array:[Int8] = [Int8].init(repeating: 0, count: decimal_length - result_length)
            result.numbers.append(contentsOf: array)
        }
        return (HugeDecimal(value: result), quotient)
    }
}

// MARK: Subtraction
public extension HugeDecimal {
    static func - (lhs: HugeDecimal, rhs: HugeDecimal) -> (result: HugeDecimal, quotient: HugeInt?) {
        return lhs + -rhs
    }
    
    static func -= (lhs: inout HugeDecimal, rhs: HugeDecimal) { // TODO: support subtraction of repeating numbers
        lhs += -rhs
    }
}

// MARK: Multiplication
public extension HugeDecimal {
    static func * (lhs: HugeDecimal, rhs: HugeInt) -> (quotient: HugeInt?, result: HugeDecimal) {
        let result_string:String = HugeDecimal.multiply(lhs: lhs.value, rhs: rhs, decimal_places: lhs.value.length)
        let result:HugeFloat = HugeFloat(result_string)
        return (result.integer == HugeInt.zero ? nil : result.integer, result.decimal ?? HugeDecimal.zero)
    }
    static func * (lhs: HugeDecimal, rhs: HugeDecimal) -> (quotient: HugeInt?, result: HugeDecimal) {
        let result_string:String = HugeDecimal.multiply(lhs: lhs.value, rhs: rhs.value, decimal_places: lhs.value.length + rhs.value.length)
        let result:HugeFloat = HugeFloat(result_string)
        return (result.integer == HugeInt.zero ? nil : result.integer, result.decimal ?? HugeDecimal.zero)
    }
}
internal extension HugeDecimal {
    static func multiply(lhs: HugeInt, rhs: HugeInt, decimal_places: Int) -> String {
        var result_string:String = (lhs * rhs).description
        result_string.insert(".", at: result_string.index(result_string.endIndex, offsetBy: -decimal_places))
        if result_string[result_string.startIndex] == "." {
            result_string.insert("0", at: result_string.startIndex)
        }
        return result_string
    }
}
/*
 Misc
 */
public func abs(_ integer: HugeInt) -> HugeDecimal {
    return HugeDecimal(value: HugeInt(isNegative: false, integer.numbers))
}

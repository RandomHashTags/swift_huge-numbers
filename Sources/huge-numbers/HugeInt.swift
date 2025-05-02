//
//  HugeInt.swift
//  
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

public struct HugeInt : Hashable, Comparable, Codable, CustomStringConvertible {
    /// 100 decimal places.
    public private(set) static var defaultPrecision = HugeInt(isNegative: false, [0, 0, 1])
    /// 6 decimal places.
    public private(set) static var floatPrecision = HugeInt(isNegative: false, [6])
    /// 15 decimal places.
    public private(set) static var doublePrecision = HugeInt(isNegative: false, [5, 1])
    
    public private(set) static var zero = HugeInt(isNegative: false, [])
    public private(set) static var one = HugeInt(isNegative: false, [1])
    public private(set) static var two = HugeInt(isNegative: false, [2])
    public private(set) static var sixtyFour = HugeInt(isNegative: false, [4, 6])
    public private(set) static var sixtyFifthBitValue = HugeInt("18446744073709551616")

    public enum Sign: Sendable {
        case minus
        case plus
    }
    
    public static func random(in range: Range<HugeInt>) -> HugeInt {
        let minimum_integer:UInt64 = range.lowerBound.toInt()!, maximum_integer:UInt64 = range.upperBound.toInt()!
        let number:UInt64 = UInt64.random(in: minimum_integer...maximum_integer)
        return HugeInt(number)
    }

    /// The 8-bit numbers representing this huge integer, in reverse order.
    public internal(set) var numbers:[Int8]

    public internal(set) var sign:Sign

    @inlinable
    public var isNegative: Bool {
        sign == .minus
    }
    
    public init(isNegative: Bool, _ numbers: [Int8]) {
        self.numbers = numbers.count == 1 && numbers[0] == 0 ? [] : numbers
        self.sign = isNegative ? .minus : .plus
    }
    public init<T: StringProtocol & RangeReplaceableCollection>(_ string: T, removeLeadingZeros: Bool = true) {
        var targetString:T = string
        if removeLeadingZeros {
            targetString.removeLeadingZeros()
        }
        if targetString.isEmpty {
            sign = .plus
            numbers = []
        } else {
            let startIndex = targetString.startIndex
            self.sign = targetString[startIndex] == "-" ? .minus : .plus
            let characters = sign == .minus ? T(targetString[targetString.index(startIndex, offsetBy: 1)...]) : targetString
            self.numbers = characters.map({ Int8(exactly: $0.wholeNumberValue!)! }).reversed()
        }
    }

    public init<T: StringProtocol & RangeReplaceableCollection>(isNegative: Bool, _ string: T) {
        self.init(string)
        sign = isNegative ? .minus : .plus
    }
    @inlinable
    public init(isNegative: Bool, _ numbers: ArraySlice<Int8>) {
        self.init(isNegative: isNegative, Array(numbers))
    }
    @inlinable
    public init(isNegative: Bool, _ integer: any BinaryInteger) {
        self.init(isNegative: isNegative, String(describing: integer))
    }
    @inlinable
    public init(_ integer: any BinaryInteger) {
        self.init(String(describing: integer))
    }
    
    @inlinable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self.init(string)
    }
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    /// The amount of digits that represent this huge integer.
    @inlinable
    public var length : Int {
        return numbers.count
    }

    /// The number the digits represent.
    @inlinable
    public var description : String {
        return isZero ? "0" : (isNegative ? "-" : "") + numbers.reversed().map({ String(describing: $0) }).joined()
    }

    /// The number the digits represent, in reverse order.
    @inlinable
    public var descriptionLiteral : String {
        return isZero ? "0" : (isNegative ? "-" : "") + numbers.map({ String(describing: $0) }).joined()
    }

    /// Whether or not this huge integer equals zero.
    @inlinable
    public var isZero : Bool {
        return numbers.count == 0 || allDigitsSatisfy({ $0 == 0 })
    }

    /// Converts this huge integer to a `HugeFloat`.
    @inlinable
    public var toFloat : HugeFloat {
        return HugeFloat(integer: self)
    }

    /// Converts this huge integer to a `HugeRemainder`.
    @inlinable
    public var toRemainder : HugeRemainder {
        return HugeRemainder(dividend: self, divisor: HugeInt.one)
    }

    /// Converts this huge integer to a concrete integer, if possible.
    @inlinable
    public func toInt<T: BinaryInteger & LosslessStringConvertible>() -> T? {
        return T.init(description)
    }
    
    /// Whether or not all the digits that represent this huge integer satisfy a predicate.
    @inlinable
    public func allDigitsSatisfy(_ transform: (Int8) throws -> Bool) rethrows -> Bool {
        return try numbers.allSatisfy(transform)
    }
    
    public mutating func multipliedByTen(_ amount: Int) {
        let array = [Int8].init(repeating: 0, count: abs(amount))
        if amount > 0 {
            numbers.insert(contentsOf: array, at: 0)
        } else {
            numbers.insert(contentsOf: array, at: numbers.count-1)
        }
    }
    @inlinable
    public func multiplyByTen(_ amount: Int) -> HugeInt {
        let isNegative = isNegative != (amount < 0 ? true : false)
        var numbers = numbers
        numbers.insert(contentsOf: [Int8].init(repeating: 0, count: abs(amount)), at: 0)
        return HugeInt(isNegative: isNegative, numbers)
    }
    
    /// - Warning: Very resource intensive when using a big number.
    public func getAllFactors() -> Set<HugeInt> {
        let maximum = (self / 2).quotient
        return getFactors(maximum: maximum)
    }
    /// - Parameters:
    ///     - maximum: the starting number
    /// - Complexity: O(_n_ - 1) where _n_ is equal to the _maximum_ parameter.
    /// - Warning: Very resource intensive when using a big number.
    @inlinable
    public func getFactors(maximum: HugeInt) -> Set<HugeInt> {
        var maximum = maximum
        var array:Set<HugeInt> = [self]
        let two = HugeInt(isNegative: false, [2])
        while maximum >= two {
            if self % maximum == HugeInt.zero {
                array.insert(maximum)
            }
            maximum -= HugeInt.one
        }
        return array
    }

    /// - Warning: This function assumes self is less than or equal to `integer`.
    /// - Warning: Very resource intensive when using big numbers.
    @inlinable
    public func get_shared_factors(_ integer: HugeInt) -> Set<HugeInt>? {
        let (selfArray, otherArray) = (getAllFactors(), integer.getFactors(maximum: self))
        let biggerArray:Set<HugeInt>, smallerArray:Set<HugeInt>
        if selfArray.count > otherArray.count {
            biggerArray = selfArray
            smallerArray = otherArray
        } else {
            biggerArray = otherArray
            smallerArray = selfArray
        }
        let array = biggerArray.filter({ smallerArray.contains($0) })
        return array.isEmpty ? nil : array
    }
    
    /// - Warning: Very resource intensive when using a big number.
    @inlinable
    public func getAllFactorsParallel() async -> Set<HugeInt> {
        let maximum = (self / 2).quotient
        return await getFactorsParallel(maximum: maximum)
    }

    /// - Warning: Very resource intensive when using a big number.
    @inlinable
    public func getFactorsParallel(maximum: HugeInt) async -> Set<HugeInt> {
        let this = self
        var maximum = maximum
        let two = HugeInt(isNegative: false, [2])
        return await withTaskGroup(of: HugeInt?.self, body: { group in
            while maximum >= two {
                let targetNumber = maximum
                group.addTask {
                    return this % targetNumber == HugeInt.zero ? targetNumber : nil
                }
                maximum -= HugeInt.one
            }
            var array:Set<HugeInt> = [this]
            for await integer in group {
                if let integer {
                    array.insert(integer)
                }
            }
            return array
        })
    }
    /// - Warning: This function assumes self is less than or equal to the given number.
    /// - Warning: Very resource intensive when using big numbers.
    @inlinable
    public func getSharedFactorsParallel(_ integer: HugeInt) async -> Set<HugeInt>? {
        let (selfArray, otherArray) = await (getAllFactorsParallel(), integer.getFactorsParallel(maximum: self))
        let array = selfArray.filter({ otherArray.contains($0) })
        return array.isEmpty ? nil : array
    }
    
    public mutating func removeTrailingZeros() {
        while numbers.first == 0 {
            numbers.removeFirst()
        }
    }
    public mutating func removeLeadingZeros() {
        while numbers.last == 0 {
            numbers.removeLast()
        }
    }
}

// MARK: Comparable
extension HugeInt {
    @inlinable
    static func compare(
        lhs: HugeInt,
        rhs: HugeInt,
        operation: (HugeInt, HugeInt) -> Bool,
        operation2: (Int8, Int8) -> Bool,
        fallbackValue: () -> Bool = { false }
    ) -> Bool {
        guard lhs.sign == rhs.sign else {
            return lhs.isNegative == !rhs.isNegative
        }
        guard lhs.numbers.count == rhs.numbers.count else {
            return operation(lhs, rhs)
        }
        let leftNumbers = lhs.numbers.reversed()
        let rightNumbers = rhs.numbers.reversed()
        for index in leftNumbers.indices {
            let leftNumber = leftNumbers[index]
            let rightNumber = rightNumbers[index]
            if leftNumber != rightNumber {
                return operation2(leftNumber, rightNumber)
            }
        }
        return fallbackValue()
    }
}
extension HugeInt {
    @inlinable
    public static func < (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return compare(lhs: lhs, rhs: rhs) {
            $0.numbers.count < $1.numbers.count
        } operation2: {
            $0 < $1
        }
    }

    @inlinable
    public static func < (lhs: HugeInt, rhs: any BinaryInteger) -> Bool {
        return lhs < HugeInt(rhs)
    }

    @inlinable
    public static func < (lhs: any BinaryInteger, rhs: HugeInt) -> Bool {
        return HugeInt(lhs) < rhs
    }
}
extension HugeInt {
    @inlinable
    public static func > (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return compare(lhs: lhs, rhs: rhs) {
            $0.numbers.count > $1.numbers.count
        } operation2: {
            $0 > $1
        }
    }

    @inlinable
    public static func > (lhs: HugeInt, rhs: any BinaryInteger) -> Bool {
        return lhs > HugeInt(rhs)
    }

    @inlinable
    public static func > (lhs: any BinaryInteger, rhs: HugeInt) -> Bool {
        return HugeInt(lhs) > rhs
    }
}
extension HugeInt {
    @inlinable
    public static func == (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return lhs.sign == rhs.sign && lhs.numbers.count == rhs.numbers.count && lhs.numbers.elementsEqual(rhs.numbers) || lhs.isZero && rhs.isZero
    }
}
extension HugeInt {
    @inlinable
    public static func <= (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return compare(lhs: lhs, rhs: rhs) {
            $0.numbers.count <= $1.numbers.count
        } operation2: {
            $0 <= $1
        } fallbackValue: {
            true
        }
    }

    @inlinable
    public static func <= (lhs: HugeInt, rhs: any BinaryInteger) -> Bool {
        return lhs <= HugeInt(rhs)
    }

    @inlinable
    public static func <= (lhs: any BinaryInteger, rhs: HugeInt) -> Bool {
        return HugeInt(lhs) <= rhs
    }
}
extension HugeInt {
    @inlinable
    public static func >= (lhs: HugeInt, rhs: HugeInt) -> Bool {
        return compare(lhs: lhs, rhs: rhs) {
            $0.numbers.count >= $1.numbers.count
        } operation2: {
            $0 >= $1
        } fallbackValue: {
            true
        }
    }

    @inlinable
    public static func >= (lhs: HugeInt, rhs: any BinaryInteger) -> Bool {
        return lhs >= HugeInt(rhs)
    }

    @inlinable
    public static func >= (lhs: any BinaryInteger, rhs: HugeInt) -> Bool {
        return HugeInt(lhs) >= rhs
    }
}

// MARK: Prefixes / postfixes
extension HugeInt {
    @inlinable
    public static prefix func - (value: HugeInt) -> HugeInt {
        return HugeInt(isNegative: !value.isNegative, value.numbers)
    }
    /// - Complexity: O(_n_ - 1) where _n_ equals this huge integer.
    /// - Warning: Very resource intensive when using big numbers.
    @inlinable
    public func factorial() -> HugeInt {
        let one = HugeInt.one
        var remainingValue = HugeInt(isNegative: false, numbers)
        var value = remainingValue
        while remainingValue != one {
            remainingValue -= one
            value *= remainingValue
        }
        return HugeInt(isNegative: isNegative, value.numbers)
    }
}

// MARK: Misc
public func abs(_ integer: HugeInt) -> HugeInt {
    return HugeInt(isNegative: false, integer.numbers)
}
extension HugeInt {
    static func leftIntIsBigger(lhs: HugeInt, rhs: HugeInt) -> Bool {
        return getBiggerInt(lhs: lhs, rhs: rhs).leftIsBigger
    }
    static func getBiggerInt(lhs: HugeInt, rhs: HugeInt) -> (biggerInt: HugeInt, smallerInt: HugeInt, leftIsBigger: Bool) {
        let (_, _, leftIsBigger) = getBiggerNumbers(lhs: lhs, rhs: rhs)
        if leftIsBigger {
            return (lhs, rhs, true)
        } else {
            return (rhs, lhs, false)
        }
    }
    static func getBiggerNumbers(lhs: HugeInt, rhs: HugeInt) -> (biggerNumbers: [Int8], smallerNumbers: [Int8], leftIsBigger: Bool) {
        let leftNumbers = lhs.numbers
        let rightNumbers = rhs.numbers
        if lhs.sign == rhs.sign {
            return getBiggerNumbers(lhs: leftNumbers, rhs: rightNumbers)
        } else {
            return lhs.isNegative  ? (rightNumbers, leftNumbers, false) : (leftNumbers, rightNumbers, true)
        }
    }
    static func getBiggerNumbers(lhs: [Int8], rhs: [Int8]) -> (biggerNumbers: [Int8], smallerNumbers: [Int8], leftIsBigger: Bool) {
        let lhsCount = lhs.count
        let rhsCount = rhs.count
        if lhsCount == rhsCount {
            let lhsReversed = lhs.reversed()
            let rhsReversed = rhs.reversed()
            for index in lhsReversed.indices {
                let leftNumber = lhsReversed[index]
                let rightNumber = rhsReversed[index]
                if leftNumber != rightNumber {
                    if leftNumber > rightNumber {
                        return (lhs, rhs, true)
                    } else {
                        return (rhs, lhs, false)
                    }
                }
            }
            return (rhs, lhs, false)
        } else if lhsCount > rhsCount {
            return (lhs, rhs, true)
        } else {
            return (rhs, lhs, false)
        }
    }
}

// MARK: Addition
public extension HugeInt {
    static func + (lhs: HugeInt, rhs: HugeInt) -> HugeInt {
        if lhs == HugeInt.zero {
            return rhs
        } else if rhs == HugeInt.zero {
            return lhs
        } else {
            let isBigger:Bool
            let result:[Int8]
            let isNegative:Bool
            let leftNumbers = lhs.numbers
            let rightNumbers = rhs.numbers
            if rhs.isNegative {
                if lhs.isNegative {
                    (result, isBigger) = HugeInt.add(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = true
                } else {
                    (result, isBigger) = HugeInt.subtract(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = leftNumbers == rightNumbers ? false : !isBigger
                }
            } else {
                if lhs.isNegative {
                    (result, isBigger) = HugeInt.subtract(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = leftNumbers == rightNumbers ? false : !isBigger
                } else {
                    (result, isBigger) = HugeInt.add(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = false
                }
            }
            return HugeInt(isNegative: isNegative, result)
        }
    }
    static func + (lhs: HugeInt, rhs: any BinaryInteger) -> HugeInt {
        return lhs + HugeInt(rhs)
    }
    static func + (lhs: any BinaryInteger, rhs: HugeInt) -> HugeInt {
        return HugeInt(lhs) + rhs
    }
    
    static func += (lhs: inout HugeInt, rhs: HugeInt) {
        if lhs == HugeInt.zero {
            lhs.sign = rhs.sign
            lhs.numbers = rhs.numbers
        } else if rhs == HugeInt.zero {
            return
        } else {
            let isBigger:Bool, result:[Int8], isNegative:Bool
            let leftNumbers = lhs.numbers
            let rightNumbers = rhs.numbers
            if rhs.isNegative {
                if lhs.isNegative {
                    (result, isBigger) = HugeInt.add(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = true
                } else {
                    (result, isBigger) = HugeInt.subtract(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = leftNumbers == rightNumbers ? false : !isBigger
                }
            } else {
                if lhs.isNegative {
                    (result, isBigger) = HugeInt.subtract(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = leftNumbers == rightNumbers ? false : !isBigger
                } else {
                    (result, isBigger) = HugeInt.add(lhs: leftNumbers, rhs: rightNumbers)
                    isNegative = false
                }
            }
            lhs.sign = isNegative ? .minus : .plus
            lhs.numbers = result
        }
    }
    static func += (lhs: inout HugeInt, rhs: any BinaryInteger) {
        lhs += HugeInt(rhs)
    }
}
extension HugeInt {
    static func add(lhs: [Int8], rhs: [Int8]) -> (result: [Int8], leftIsBigger: Bool) {
        let (biggerNumbers, smallerNumbers, leftIsBigger) = getBiggerNumbers(lhs: lhs, rhs: rhs)
        var result = HugeInt.add(biggerNumbers: biggerNumbers, smallerNumbers: smallerNumbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, leftIsBigger)
    }

    /// Finds the sum of two 8-bit number arrays.
    /// 
    /// - Complexity: O(_n_ + 1) where _n_ equals _bigger_numbers.count_.
    /// - Returns: the sum of the two arrays, in reverse order.
    static func add(biggerNumbers: [Int8], smallerNumbers: [Int8]) -> [Int8] {
        var result = biggerNumbers
        result.append(0)
        
        for index in 0..<smallerNumbers.count {
            result[index] += smallerNumbers[index]
        }
        for i in 0..<(biggerNumbers.count + 1) {
            if result[i] > 9 {
                result[i] -= 10
                result[i+1] += 1
            }
        }
        return result
    }
}

// MARK: Subtraction
extension HugeInt {
    @inlinable
    public static func - (lhs: HugeInt, rhs: HugeInt) -> HugeInt {
        return lhs + -rhs
    }
    @inlinable
    public static func - (lhs: HugeInt, rhs: any BinaryInteger) -> HugeInt {
        return lhs - HugeInt(rhs)
    }
    @inlinable
    public static func - (lhs: any BinaryInteger, rhs: HugeInt) -> HugeInt {
        return HugeInt(lhs) - rhs
    }
    
    @inlinable
    public static func -= (lhs: inout HugeInt, rhs: HugeInt) {
        lhs += -rhs
    }
    @inlinable
    public static func -= (lhs: inout HugeInt, rhs: any BinaryInteger) {
        lhs -= HugeInt(rhs)
    }
}
internal extension HugeInt {
    static func subtract(lhs: [Int8], rhs: [Int8]) -> (result: [Int8], leftIsBigger: Bool) {
        let (biggerNumbers, smallerNumbers, leftIsBigger) = getBiggerNumbers(lhs: lhs, rhs: rhs)
        var result = HugeInt.subtract(biggerNumbers: biggerNumbers, smallerNumbers: smallerNumbers)
        while result.last == 0 {
            result.removeLast()
        }
        return (result, leftIsBigger)
    }

    /// Finds the net of two 8-bit number arrays.
    /// 
    /// - Returns: the net of the two arrays, in reverse order.
    static func subtract(biggerNumbers: [Int8], smallerNumbers: [Int8]) -> [Int8] {
        var result = biggerNumbers
        for index in 0..<smallerNumbers.count {
            result[index] -= smallerNumbers[index]
        }
        for i in 0..<biggerNumbers.count {
            if result[i] < 0 {
                result[i] += 10
                result[i+1] -= 1
            }
        }
        return result
    }
}

// MARK: Multiplication
extension HugeInt {
    public static func * (lhs: HugeInt, rhs: HugeInt) -> HugeInt {
        if lhs.isZero || rhs.isZero {
            return HugeInt.zero
        } else if lhs == HugeInt.one {
            return rhs
        } else if rhs == HugeInt.one {
            return lhs
        } else {
            let numbers = HugeInt.multiply(lhs: lhs.numbers, rhs: rhs.numbers)
            let isNegative = !(lhs.isNegative == rhs.isNegative)
            return HugeInt(isNegative: isNegative, numbers)
        }
    }
    @inlinable
    public static func * (lhs: HugeInt, rhs: any BinaryInteger) -> HugeInt {
        return lhs * HugeInt(rhs)
    }
    @inlinable
    public static func * (lhs: any BinaryInteger, rhs: HugeInt) -> HugeInt {
        return rhs * HugeInt(lhs)
    }
    
    public static func *= (lhs: inout HugeInt, rhs: HugeInt) {
        lhs.sign = !(lhs.isNegative == rhs.isNegative) ? .minus : .plus
        lhs.numbers = HugeInt.multiply(lhs: lhs.numbers, rhs: rhs.numbers)
    }
    @inlinable
    public static func *= (lhs: inout HugeInt, rhs: any BinaryInteger) {
        lhs *= HugeInt(rhs)
    }
}
extension HugeInt {
    static func multiply(lhs: [Int8], rhs: [Int8], removeLeadingZeros: Bool = true) -> [Int8] {
        let (biggerNumbers, smallerNumbers, _) = getBiggerNumbers(lhs: lhs, rhs: rhs)
        var result = HugeInt.multiply(biggerNumbers: biggerNumbers, smallerNumbers: smallerNumbers)
        if removeLeadingZeros {
            while result.last == 0 {
                result.removeLast()
            }
        }
        return result
    }

    // TODO: optimize | n * log(n)
    /// Multiplies two 8-bit number arrays together.
    /// - Parameters:
    ///     - biggerNumbers: An array of 8-bit numbers in reverse order. This array's size should be bigger than or equal to _smaller_numbers_ size.
    ///     - smallerNumbers: An array of 8-bit numbers in reverse order. This array's size should be less than or equal to _bigger_numbers_ size.
    /// - Complexity: O(_n_ \* _m_), where _n_ is the _bigger\_numbers_ size, and _m_ is the _smaller\_numbers_ size.
    /// - Returns: the product of the two 8-bit number arrays, in reverse order.
    static func multiply(biggerNumbers: [Int8], smallerNumbers: [Int8]) -> [Int8] {
        let array_count = biggerNumbers.count
        let smallerNumbersLength = smallerNumbers.count
        let smallerNumbersLengthMinusOne = smallerNumbersLength-1
        let resultCount = array_count + smallerNumbersLength
        let resultCountMinusOne = resultCount-1
        var result = [Int8].init(repeating: 0, count: resultCount)
        
        var smallNumberIndex = 0
        while smallNumberIndex < smallerNumbersLength {
            let smallerNumber = smallerNumbers[smallNumberIndex]
            if smallerNumber != 0 {
                var bigNumberIndex = 0
                var remainder:Int8 = 0
                var smallNumberResult = [Int8].init(repeating: 0, count: resultCount)
                while bigNumberIndex < array_count {
                    let calculatedValue = smallerNumber * biggerNumbers[bigNumberIndex]
                    let totalValue = calculatedValue + remainder
                    remainder = totalValue / 10
                    let endingResult = totalValue - (remainder * 10)
                    smallNumberResult[smallNumberIndex + bigNumberIndex] = endingResult
                    bigNumberIndex += 1
                }
                if remainder > 0 {
                    let endingIndex = smallNumberIndex == smallerNumbersLengthMinusOne ? resultCountMinusOne : smallNumberIndex + bigNumberIndex
                    smallNumberResult[endingIndex] = remainder
                    remainder = 0
                }
                result = HugeInt.add(biggerNumbers: result, smallerNumbers: smallNumberResult)
            }
            smallNumberIndex += 1
        }
        return result
    }
}

// MARK: Division
// https://www.wikihow.com/Do-Short-Division , but optimized for a computer)
extension HugeInt {
    public static func / (dividend: HugeInt, divisor: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        if dividend == HugeInt.zero {
            return (HugeInt.zero, divisor == HugeInt.zero ? nil : HugeRemainder(dividend: dividend, divisor: divisor))
        } else if divisor.numbers == [1] {
            if divisor.isNegative {
                return (-dividend, nil)
            } else {
                return (dividend, nil)
            }
        }
        return HugeInt.divide(dividend: dividend, divisor: divisor)
    }
    
    @inlinable
    public static func / (lhs: HugeInt, rhs: any BinaryInteger) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        return lhs / HugeInt(rhs)
    }
    @inlinable
    public static func / (lhs: any BinaryInteger, rhs: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        return HugeInt(lhs) / rhs
    }
    
    @inlinable
    public static func /= (lhs: inout HugeInt, rhs: HugeInt) {
        lhs = (lhs / rhs).quotient
    }
    @inlinable
    public static func /= (lhs: inout HugeInt, rhs: any BinaryInteger) {
        lhs /= HugeInt(rhs)
    }
}
extension HugeInt {
    static func divide(dividend: HugeInt, divisor: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        if let dividendNumber:UInt64 = dividend.toInt(), let divisorNumber:UInt64 = divisor.toInt() {
            let result = dividendNumber / divisorNumber
            let remainderNumber = dividendNumber - (divisorNumber * result)
            let remainder = remainderNumber != 0 ? HugeRemainder(dividend: HugeInt(remainderNumber), divisor: divisor) : nil
            return (HugeInt(result), remainder)
        } else if let dividendNumber:Int64 = dividend.toInt(), let divisorNumber:Int64 = divisor.toInt() {
            let result = dividendNumber / divisorNumber
            let remainderNumber = dividendNumber - (divisorNumber * result)
            let remainder = remainderNumber != 0 ? HugeRemainder(dividend: HugeInt(abs(remainderNumber)), divisor: divisor) : nil
            return (HugeInt(result), remainder)
        }
        guard dividend >= divisor else {
            return (HugeInt.zero, HugeRemainder(dividend: dividend, divisor: divisor))
        }
        return divideVeryLargeNumbers(dividend: dividend, divisor: divisor)
    }

    static func divideVeryLargeNumbers(dividend: HugeInt, divisor: HugeInt) -> (quotient: HugeInt, remainder: HugeRemainder?) {
        let isNegative = !(dividend.isNegative == divisor.isNegative)
        var remainingDividend = HugeInt(isNegative: false, dividend.numbers)
        let dividendLength = dividend.length
        let divisorLength = divisor.length
        let resultCount = dividendLength - divisorLength + 1
        var quotientNumbers = [Int8].init(repeating: Int8.max, count: resultCount)
        
        var includedDigits = divisorLength
        var quotientIndex = 0
        var lastSubtractedAmount = HugeInt.zero
        while remainingDividend >= divisor {
            var divisibleDividendNumbers = [Int8].init(repeating: 0, count: includedDigits)
            let remainingDividendNumbersReversed = remainingDividend.numbers.reversed()
            for index in 0..<includedDigits {
                divisibleDividendNumbers[index] = remainingDividendNumbersReversed[remainingDividendNumbersReversed.index(remainingDividendNumbersReversed.startIndex, offsetBy: index)]
            }
            var divisibleDividend = HugeInt(isNegative: false, divisibleDividendNumbers.reversed())
            if divisibleDividend >= divisor {
                divisibleDividend -= divisor
                lastSubtractedAmount = divisor
                quotientNumbers[quotientIndex] = 1
                while divisibleDividend >= divisor {
                    quotientNumbers[quotientIndex] += 1
                    divisibleDividend -= divisor
                    lastSubtractedAmount += divisor
                }
                quotientIndex += 1
                let remainingDividendNumbers = remainingDividend.numbers
                let remainingDividendNumbersCount = remainingDividendNumbers.count
                if remainingDividendNumbers[remainingDividendNumbersCount-1] < 10 {
                    for _ in includedDigits..<remainingDividendNumbersCount {
                        lastSubtractedAmount.numbers.insert(0, at: 0)
                    }
                }
                
                var bruh = HugeInt.subtract(biggerNumbers: remainingDividendNumbers, smallerNumbers: lastSubtractedAmount.numbers)
                for _ in 0..<includedDigits {
                    if bruh.last == 0 {
                        bruh.removeLast()
                    }
                }
                while bruh.last == 0 {
                    if quotientIndex < resultCount {
                        quotientNumbers[quotientIndex] = 0
                        quotientIndex += 1
                    }
                    bruh.removeLast()
                }
                remainingDividend = HugeInt(isNegative: false, bruh)
                if includedDigits > 1 {
                    includedDigits -= 1
                }
            } else {
                includedDigits += 1
            }
        }
        let remainder:HugeRemainder?
        if remainingDividend.isZero {
            remainder = nil
        } else {
            remainder = HugeRemainder(dividend: remainingDividend, divisor: divisor)
            if lastSubtractedAmount.numbers.last == divisor.numbers.last && lastSubtractedAmount.numbers.count == dividendLength && quotientIndex < resultCount {
                quotientNumbers[quotientIndex] = 0
            }
        }
        
        while quotientNumbers.last == Int8.max {
            quotientNumbers.removeLast()
        }
        return (HugeInt(isNegative: isNegative, quotientNumbers.reversed()), remainder)
    }
}
// MARK: Percent
extension HugeInt {
    @inlinable
    public static func % (lhs: HugeInt, rhs: HugeInt) -> HugeInt {
        return (lhs / rhs).remainder?.dividend ?? HugeInt.zero
    }
    @inlinable
    public static func % (lhs: HugeInt, rhs: any BinaryInteger) -> HugeInt {
        return lhs % HugeInt(rhs)
    }
}
/*
 Multiplicative inverse // TODO: support
 */

// MARK: Square root
@inlinable
public func sqrt(_ x: HugeInt) -> HugeFloat { // TODO: fix | doesn't support remainders
    guard x > HugeInt.zero else { return HugeFloat.zero }
    let numbers = x.numbers
    guard let endingNumber = numbers.first else { return HugeFloat.zero }
    let endingRoot1:Int8, endingRoot2:Int8
    switch endingNumber {
    case 0:
        if let integer:Int = x.toInt() { // TODO: fix
            let closest = getClosestSqrtNumber(integer)
            return HugeFloat(closest)
        } else {
            return HugeFloat(integer: HugeInt.zero) // TODO: fix
        }
    case 1:
        endingRoot1 = 1
        endingRoot2 = 9
    case 4:
        endingRoot1 = 2
        endingRoot2 = 8
    case 6:
        endingRoot1 = 4
        endingRoot2 = 6
    case 9:
        endingRoot1 = 3
        endingRoot2 = 7
    default:
        endingRoot1 = 5
        endingRoot2 = 5
    }
    if numbers.count <= 2 {
        let result = endingRoot1 * endingRoot1 == x.toInt() ? endingRoot1 : endingRoot2
        return HugeFloat(result)
    }
    let reversed = numbers.reversed()
    let firstNumbers = Int(reversed[reversed.startIndex..<reversed.index(reversed.startIndex, offsetBy: numbers.count-2)].map({ String(describing: $0) }).joined())!
    let firstResult = getClosestSqrtNumber(firstNumbers)
    let secondValue = firstResult * (firstResult + 1)
    let secondResult = firstNumbers < secondValue ? endingRoot1 : endingRoot2
    return HugeFloat(UInt64(String(describing: firstResult) + String(describing: secondResult))!)
}
@inlinable
func getClosestSqrtNumber(_ number: Int, starting_number: Int = 4) -> Int {
    for index in starting_number...45_000 {
        let squared = index * index
        if number < squared {
            return index-1
        }
    }
    return 0
}

// MARK: Exponent
extension HugeInt {
    @inlinable public func squared() -> HugeInt { toThePowerOf(2) }
    @inlinable public func cubed() -> HugeInt   { toThePowerOf(3) }
    
    /// Returns a `HugeInt` taken to a given power.
    /// 
    /// - Complexity: O(n) where _n_ equals _x_.
    /// - Parameters:
    ///     - x: the amount of times to multiply self by self.
    @inlinable
    public func toThePowerOf(_ x: UInt64) -> HugeInt {
        var result = self
        for _ in 1..<x {
            result *= self
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

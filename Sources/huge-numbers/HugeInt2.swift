//
//  HugeInt2.swift
//
//
//  Created by Evan Anderson on 11/11/23.
//

import Foundation

// abandon due to scaling issue??
public struct HugeInt2 : Equatable {
    
    public static var zero:HugeInt2 = HugeInt2(0)
    public static var one:HugeInt2 = HugeInt2(1)
    
    public private(set) var isNegative:Bool
    public private(set) var binary:[Bool]
    
    public var binary_string : String {
        return binary.map({ $0 ? "1" : "0" }).joined()
    }
    
    public func binary_complement_one(totalBits: Int) -> [Bool] {
        var inverted:[Bool] = binary.map({ !$0 })
        if inverted.count != totalBits {
            inverted.insert(contentsOf: [Bool].init(repeating: true, count: totalBits - inverted.count), at: 0)
        }
        while !(inverted.first ?? true) {
            inverted.removeFirst()
        }
        return inverted
    }
    public func binary_complement_two(totalBits: Int) -> [Bool] {
        return HugeInt2.add(left_binary: [true], right_binary: binary_complement_one(totalBits: totalBits))
    }
    
    public init<T: BinaryInteger>(_ integer: T) {
        isNegative = integer < 0
        binary = integer.toBinary()
    }
    public init(isNegative: Bool = false, binary: [Bool]) {
        self.isNegative = isNegative
        self.binary = binary
    }
    
    public var description : String {
        guard binary.count > 64 else {
            return (isNegative ? "-" : "") + "\(UInt64(binary_string, radix: 2)!)"
        }
        return "?" // TODO: fix
    }
    public var isZero : Bool {
        return binary.count == 1 && !binary[0]
    }
}

public extension HugeInt2 {
    static func == (lhs: HugeInt2, rhs: HugeInt2) -> Bool {
        return lhs.isNegative == rhs.isNegative && lhs.binary.elementsEqual(rhs.binary)
    }
}

extension HugeInt2 {
    static func add(left_binary: [Bool], right_binary: [Bool]) -> [Bool] {
        var left_binary:[Bool] = left_binary
        var right_binary:[Bool] = right_binary
        let binary_length:Int = max(left_binary.count, right_binary.count)
        var result_binary:[Bool] = [Bool].init(repeating: false, count: binary_length)
        
        if left_binary.count != right_binary.count {
            for _ in left_binary.count..<binary_length {
                left_binary.insert(false, at: 0)
            }
            for _ in right_binary.count..<binary_length {
                right_binary.insert(false, at: 0)
            }
        }
        
        var carry_over:Bool = false
        let starting_index:Int = binary_length - 1
        for bit in 0..<binary_length {
            let value:Bool
            let index:Int = starting_index - bit
            if left_binary[index] {
                if right_binary[index] {
                    value = carry_over
                    carry_over = true
                } else {
                    value = !carry_over
                }
            } else if right_binary[index] {
                value = !carry_over
            } else {
                value = carry_over
                carry_over = false
            }
            result_binary[index] = value
        }
        if carry_over {
            result_binary.insert(true, at: 0)
        }
        return result_binary
    }
}
extension HugeInt2 {
    static func subtract(lhs: HugeInt2, rhs: HugeInt2) -> HugeInt2 {
        let max_length:Int = max(lhs.binary.count, rhs.binary.count)
        var binary:[Bool] = HugeInt2.add(left_binary: lhs.binary, right_binary: rhs.binary_complement_two(totalBits: max_length))
        while binary.count > max_length || binary.count != 0 && !binary[0] {
            binary.removeFirst()
        }
        return HugeInt2(isNegative: false, binary: binary) // TODO: fix
    }
}

public extension HugeInt2 {
    static func + (lhs: HugeInt2, rhs: HugeInt2) -> HugeInt2 {
        if lhs.isNegative == rhs.isNegative {
            let binary:[Bool] = HugeInt2.add(left_binary: lhs.binary, right_binary: rhs.binary)
            return HugeInt2(isNegative: lhs.isNegative, binary: binary)
        } else {
            return HugeInt2.subtract(lhs: lhs, rhs: rhs)
        }
    }
    static func += (lhs: inout HugeInt2, rhs: HugeInt2) {
        let value:HugeInt2 = lhs + rhs
        lhs.isNegative = value.isNegative
        lhs.binary = value.binary
    }
}
public extension HugeInt2 {
    static func - (lhs: HugeInt2, rhs: HugeInt2) -> HugeInt2 {
        if lhs.isNegative && rhs.isNegative || !lhs.isNegative && rhs.isNegative || lhs.isNegative && !rhs.isNegative {
            let binary:[Bool] = HugeInt2.add(left_binary: lhs.binary, right_binary: rhs.binary) // TODO: fix
            return HugeInt2(isNegative: false, binary: binary) // TODO: fix
        } else {
            return HugeInt2.subtract(lhs: lhs, rhs: rhs)
        }
    }
    static func -= (lhs: inout HugeInt2, rhs: HugeInt2) {
        let value:HugeInt2 = lhs - rhs
        lhs.isNegative = value.isNegative
        lhs.binary = value.binary
    }
}

internal extension HugeInt2 {
    static func multiply(lhs: [Bool], rhs: [Bool]) -> [Bool] {
        let lhsCount:Int = lhs.count, rhsCount:Int = rhs.count
        let max_digits:Int = max(lhsCount, rhsCount)
        let result_digits:Int = lhsCount + rhsCount
        let index:Int = result_digits-1
        
        var left_binary:[Bool] = lhs
        var right_binary:[Bool] = rhs
        
        for _ in lhsCount..<max_digits {
            left_binary.insert(false, at: 0)
        }
        for _ in rhsCount..<max_digits {
            right_binary.insert(false, at: 0)
        }
        
        var value:HugeInt2 = HugeInt2(0)
        var binary:[Bool] = [Bool].init(repeating: false, count: result_digits)
        for left_index in 0..<lhsCount {
            if left_binary[lhsCount - 1 - left_index] {
                for right_index in 0..<rhsCount {
                    binary[index - left_index - right_index] = right_binary[rhsCount - 1 - right_index]
                }
                value += HugeInt2(binary: binary)
                for i in 0..<result_digits {
                    binary[i] = false
                }
            }
        }
        return value.binary
    }
}
public extension HugeInt2 {
    static func * (lhs: HugeInt2, rhs: HugeInt2) -> HugeInt2 {
        return HugeInt2(isNegative: !(lhs.isNegative == rhs.isNegative), binary: HugeInt2.multiply(lhs: lhs.binary, rhs: rhs.binary))
    }
    static func *= (lhs: inout HugeInt2, rhs: HugeInt2) {
        let value:HugeInt2 = lhs * rhs
        lhs.isNegative = value.isNegative
        lhs.binary = value.binary
    }
}

extension HugeInt2 {
    @inlinable
    public static func getBitValue(bitWidth: UInt64) -> [Int8] {
        return getBitValue(bitWidth: HugeInt(bitWidth))
    }
    @inlinable
    public static func getBitValue(bitWidth: HugeInt) -> [Int8] {
        guard bitWidth > 64 else {
            let integer:Int = bitWidth.toInt()!
            return String(2^integer).map({ Int8(String($0))! }).reversed()
        }
        var value = HugeInt.sixtyFifthBitValue
        var bitWidth = bitWidth - HugeInt.sixtyFour
        while bitWidth > 0 {
            value *= HugeInt.two
            bitWidth -= HugeInt.one
        }
        return value.numbers
    }
}

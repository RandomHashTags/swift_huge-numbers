//
//  HugeInt2.swift
//
//
//  Created by Evan Anderson on 11/11/23.
//

import Foundation

// abandond due to scaling issue??
public struct HugeInt2 : Equatable {
    
    public static var zero:HugeInt2 = HugeInt2(0)
    public static var one:HugeInt2 = HugeInt2(1)
    
    public private(set) var is_negative:Bool
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
        is_negative = integer < 0
        binary = integer.to_binary()
    }
    public init(is_negative: Bool = false, binary: [Bool]) {
        self.is_negative = is_negative
        self.binary = binary
    }
    
    public var description : String {
        guard binary.count > 64 else {
            return (is_negative ? "-" : "") + "\(UInt64(binary_string, radix: 2)!)"
        }
        return "?" // TODO: fix
    }
    public var is_zero : Bool {
        return binary.count == 1 && !binary[0]
    }
}

public extension HugeInt2 {
    static func == (left: HugeInt2, right: HugeInt2) -> Bool {
        return left.is_negative == right.is_negative && left.binary.elementsEqual(right.binary)
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
    static func subtract(left: HugeInt2, right: HugeInt2) -> HugeInt2 {
        let max_length:Int = max(left.binary.count, right.binary.count)
        var binary:[Bool] = HugeInt2.add(left_binary: left.binary, right_binary: right.binary_complement_two(totalBits: max_length))
        while binary.count > max_length || binary.count != 0 && !binary[0] {
            binary.removeFirst()
        }
        return HugeInt2(is_negative: false, binary: binary) // TODO: fix
    }
}

public extension HugeInt2 {
    static func + (left: HugeInt2, right: HugeInt2) -> HugeInt2 {
        if left.is_negative == right.is_negative {
            let binary:[Bool] = HugeInt2.add(left_binary: left.binary, right_binary: right.binary)
            return HugeInt2(is_negative: left.is_negative, binary: binary)
        } else {
            return HugeInt2.subtract(left: left, right: right)
        }
    }
    static func += (left: inout HugeInt2, right: HugeInt2) {
        let value:HugeInt2 = left + right
        left.is_negative = value.is_negative
        left.binary = value.binary
    }
}
public extension HugeInt2 {
    static func - (left: HugeInt2, right: HugeInt2) -> HugeInt2 {
        if left.is_negative && right.is_negative || !left.is_negative && right.is_negative || left.is_negative && !right.is_negative {
            let binary:[Bool] = HugeInt2.add(left_binary: left.binary, right_binary: right.binary) // TODO: fix
            return HugeInt2(is_negative: false, binary: binary) // TODO: fix
        } else {
            return HugeInt2.subtract(left: left, right: right)
        }
    }
    static func -= (left: inout HugeInt2, right: HugeInt2) {
        let value:HugeInt2 = left - right
        left.is_negative = value.is_negative
        left.binary = value.binary
    }
}

internal extension HugeInt2 {
    static func multiply(left: [Bool], right: [Bool]) -> [Bool] {
        let left_count:Int = left.count, right_count:Int = right.count
        let max_digits:Int = max(left_count, right_count)
        let result_digits:Int = left_count + right_count
        let index:Int = result_digits-1
        
        var left_binary:[Bool] = left
        var right_binary:[Bool] = right
        
        for _ in left_count..<max_digits {
            left_binary.insert(false, at: 0)
        }
        for _ in right_count..<max_digits {
            right_binary.insert(false, at: 0)
        }
        
        var value:HugeInt2 = HugeInt2(0)
        var binary:[Bool] = [Bool].init(repeating: false, count: result_digits)
        for left_index in 0..<left_count {
            if left_binary[left_count - 1 - left_index] {
                for right_index in 0..<right_count {
                    binary[index - left_index - right_index] = right_binary[right_count - 1 - right_index]
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
    static func * (left: HugeInt2, right: HugeInt2) -> HugeInt2 {
        return HugeInt2(is_negative: !(left.is_negative == right.is_negative), binary: HugeInt2.multiply(left: left.binary, right: right.binary))
    }
    static func *= (left: inout HugeInt2, right: HugeInt2) {
        let value:HugeInt2 = left * right
        left.is_negative = value.is_negative
        left.binary = value.binary
    }
}

public extension HugeInt2 {
    static func get_bit_value(bit_width: UInt64) -> [Int8] {
        return get_bit_value(bit_width: HugeInt(bit_width))
    }
    static func get_bit_value(bit_width: HugeInt) -> [Int8] {
        guard bit_width > 64 else {
            let integer:Int = bit_width.to_int()!
            return String(2^integer).map({ Int8(String($0))! }).reversed()
        }
        var value:HugeInt = HugeInt.sixty_fifth_bit_value
        var bit_width:HugeInt = bit_width - HugeInt.sixty_four
        while bit_width > 0 {
            value *= HugeInt.two
            bit_width -= HugeInt.one
        }
        return value.numbers
    }
}

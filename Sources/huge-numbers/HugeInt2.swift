//
//  HugeInt2.swift
//
//
//  Created by Evan Anderson on 11/11/23.
//

import Foundation

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
        let left_binary:[Bool] = left_binary.reversed()
        let right_binary:[Bool] = right_binary.reversed()
        let binary_length:Int = max(left_binary.count, right_binary.count)
        var result_binary:[Bool] = [Bool].init(repeating: false, count: binary_length)
        
        var carry_over:Bool = false
        if left_binary.count == right_binary.count { // equal amount of bits that represent each number
            for bit in 0..<binary_length {
                var value:Bool = carry_over
                if left_binary[bit] {
                    if right_binary[bit] {
                        carry_over = true
                    } else {
                        value = !value
                    }
                } else if right_binary[bit] {
                    value = !carry_over
                }
                result_binary[bit] = value
            }
        } else {
            let smaller_binary:[Bool], larger_binary:[Bool]
            if left_binary.count < right_binary.count {
                smaller_binary = left_binary
                larger_binary = right_binary
            } else {
                smaller_binary = right_binary
                larger_binary = left_binary
            }
            for bit in 0..<larger_binary.count {
                result_binary[bit] = larger_binary[bit]
            }
            for bit in 0..<smaller_binary.count {
                var value:Bool = carry_over
                if smaller_binary[bit] {
                    if result_binary[bit] {
                        carry_over = true
                    } else {
                        value = !value
                    }
                } else if result_binary[bit] && carry_over {
                    value = false
                    carry_over = false
                }
                result_binary[bit] = value
            }
            var bit:Int = smaller_binary.count
            while carry_over && bit < larger_binary.count {
                if result_binary[bit] {
                    result_binary[bit] = !result_binary[bit]
                } else {
                    result_binary[bit] = true
                    carry_over = false
                }
                bit += 1
            }
        }
        if carry_over {
            result_binary.append(true)
        }
        return result_binary.reversed()
    }
}
extension HugeInt2 {
    static func subtract(left: HugeInt2, right: HugeInt2) -> HugeInt2 {
        let max_length:Int = max(left.binary.count, right.binary.count)
        var binary:[Bool] = HugeInt2.add(left_binary: left.binary, right_binary: right.binary_complement_two(totalBits: max_length))
        while binary.count > max_length || !binary[0] {
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
}

public extension HugeInt2 {
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

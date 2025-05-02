//
//  huge_numbersTests.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

#if compiler(>=6.0)

import Foundation
import HugeNumbers
import Testing

struct huge_numbersTests {
    func testExample() async throws {
    }
    
    private func test_hugeint2() {
        var integer = HugeInt2(UInt64.max) + HugeInt2(3)
        
        var target_binary = [Bool].init(repeating: false, count: 64)
        target_binary.insert(true, at: 0)
        target_binary[63] = true
        
        var result = HugeInt2(binary: target_binary)
        
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
        
        integer = HugeInt2(4) - HugeInt2(1)
        result = HugeInt2(3)
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
        
        integer = HugeInt2(15) - HugeInt2(1)
        result = HugeInt2(14)
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
        
        integer = HugeInt2(15) - HugeInt2(7)
        result = HugeInt2(8)
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
        
        integer = HugeInt2(14) + HugeInt2(28) + HugeInt2(112)
        result = HugeInt2(154)
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
        
        let test = HugeInt2.getBitValue(bitWidth: 128)
        print("test_hugeint2=" + test.debugDescription)
        
        integer = HugeInt2(11) * HugeInt2(14)
        result = HugeInt2(154)
        #expect(integer == result, "\(integer.binary_string) != \(result.binary_string)")
    }
}

#endif
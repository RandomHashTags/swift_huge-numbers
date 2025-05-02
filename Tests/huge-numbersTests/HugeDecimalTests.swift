//
//  HugeDecimalTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

#if compiler(>=6.0)

import HugeNumbers
import Testing

struct HugeDecimalTests {
    @Test
    func decimal() {
        var remainder = HugeRemainder(dividend: "1", divisor: "2")
        var result = remainder.toDecimal()
        var expectedResult = HugeDecimal("5")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "1", divisor: "4")
        result = remainder.toDecimal()
        expectedResult = HugeDecimal("25")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "1", divisor: "10")
        result = remainder.toDecimal()
        expectedResult = HugeDecimal("1")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "1", divisor: "1005")
        result = remainder.toDecimal()
        expectedResult = HugeDecimal(value: HugeInt.zero, repeating_numbers: [8, 9, 3, 0, 2, 9, 5, 1, 8, 6, 3, 6, 2, 7, 4, 5, 0, 9, 8, 1, 2, 6, 5, 7, 8, 4, 2, 0, 5, 9, 9, 0, 0])
        #expect(result == expectedResult)
        #expect(result.description == expectedResult.description, "result=\(result);expectedResult=\(expectedResult)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "1010")
        result = remainder.toDecimal()
        expectedResult = HugeDecimal(value: HugeInt.zero, repeating_numbers: [9, 9, 0, 0])
        #expect(result == expectedResult)
        #expect(result.description == expectedResult.description, "result=\(result);expectedResult=\(expectedResult)")
        
        remainder = HugeDecimal("124").toRemainder
        var expectedRemainder = HugeRemainder(dividend: "124", divisor: "1000")
        #expect(remainder == expectedRemainder, "remainder=\(result);expectedRemainder=\(expectedRemainder)")
        
        result = HugeDecimal("1234").distance_to_next_quotient
        expectedResult = HugeDecimal("8766")
        #expect(result == expectedResult)
        
        result = HugeDecimal("100852").distance_to_next_quotient
        expectedResult = HugeDecimal("899148")
        #expect(result == expectedResult)
        
        result = HugeDecimal("9999").distance_to_next_quotient
        expectedResult = HugeDecimal("0001", removeLeadingZeros: false)
        #expect(result == expectedResult)
    }
}

// MARK: Addition
extension HugeDecimalTests {
    @Test
    func decimalAddition() {
        var decimal = HugeDecimal("999")
        var (result, quotient) = decimal + HugeDecimal("001", removeLeadingZeros: false)
        var (expectedResult, expectedQuotient):(HugeDecimal, HugeInt?) = (HugeDecimal("000", removeLeadingZeros: false), HugeInt.one)
        #expect(result == expectedResult && quotient == expectedQuotient, "result=\(result);expectedResult=\(expectedResult);quotient=\(String(describing: quotient));expectedQuotient=\(String(describing: expectedQuotient))")
        
        (result, quotient) = HugeDecimal("998") + HugeDecimal("001", removeLeadingZeros: false)
        (expectedResult, expectedQuotient) = (decimal, nil)
        #expect(result == expectedResult && quotient == expectedQuotient, "result=\(result);expectedResult=\(expectedResult);quotient=\(String(describing: quotient));expectedQuotient=\(String(describing: expectedQuotient))")
    }
}

// MARK: Subtraction
extension HugeDecimalTests {
    @Test
    func decimalSubtraction() {
        var (result, quotient) = HugeDecimal("999") - HugeDecimal("001", removeLeadingZeros: false)
        var (expectedResult, expectedQuotient):(HugeDecimal, HugeInt?) = (HugeDecimal("998"), nil)
        #expect(result == expectedResult && quotient == expectedQuotient, "result=\(result);expectedResult=\(expectedResult);quotient=\(String(describing: quotient));expectedQuotient=\(String(describing: expectedQuotient))")
    }
}

// MARK: Multiplication
extension HugeDecimalTests {
    @Test
    func decimalMultiplication() {
        var (quotient, result) = HugeDecimal("999") * HugeDecimal("2")
        var (expectedQuotient, expectedResult):(HugeInt?, HugeDecimal) = (nil, HugeDecimal("1998"))
        #expect(result == expectedResult && quotient == expectedQuotient, "result=\(result);expectedResult=\(expectedResult);quotient=\(String(describing: quotient));expectedQuotient=\(String(describing: expectedQuotient))")
        
        (quotient, result) = HugeDecimal("999") * HugeInt("2")
        (expectedQuotient, expectedResult) = (HugeInt.one, HugeDecimal("998"))
        #expect(result == expectedResult && quotient == expectedQuotient, "result=\(result);expectedResult=\(expectedResult);quotient=\(String(describing: quotient));expectedQuotient=\(String(describing: expectedQuotient))")
    }
}

#endif
//
//  HugeDecimalTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

import XCTest
import HugeNumbers

struct HugeDecimalTests {
    func validate() async {
        await test_decimal()
    }
}

extension HugeDecimalTests {
    private func test_decimal() async {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeDecimal = remainder.to_decimal()
        var expected_result:HugeDecimal = HugeDecimal("5")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "4")
        result = remainder.to_decimal()
        expected_result = HugeDecimal("25")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "10")
        result = remainder.to_decimal()
        expected_result = HugeDecimal("1")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "1005")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt.zero, repeating_numbers: [8, 9, 3, 0, 2, 9, 5, 1, 8, 6, 3, 6, 2, 7, 4, 5, 0, 9, 8, 1, 2, 6, 5, 7, 8, 4, 2, 0, 5, 9, 9, 0, 0])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        XCTAssert(result.description.elementsEqual(expected_result.description), "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "1010")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt.zero, repeating_numbers: [9, 9, 0, 0])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        XCTAssert(result.description.elementsEqual(expected_result.description), "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeDecimal("124").to_remainder
        var expected_remainder:HugeRemainder = HugeRemainder(dividend: "124", divisor: "1000")
        XCTAssert(remainder == expected_remainder, "test_decimal;remainder=\(result);expected_remainder=\(expected_remainder)")
        
        result = HugeDecimal("1234").distance_to_next_quotient
        expected_result = HugeDecimal("8766")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        result = HugeDecimal("100852").distance_to_next_quotient
        expected_result = HugeDecimal("899148")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        result = HugeDecimal("9999").distance_to_next_quotient
        expected_result = HugeDecimal("0001", remove_leading_zeros: false)
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        test_decimal_addition()
        test_decimal_subtraction()
        test_decimal_multiplication()
    }
    private func test_decimal_addition() {
        var decimal:HugeDecimal = HugeDecimal("999")
        var (result, quotient):(HugeDecimal, HugeInt?) = decimal + HugeDecimal("001", remove_leading_zeros: false)
        var (expected_result, expected_quotient):(HugeDecimal, HugeInt?) = (HugeDecimal("000", remove_leading_zeros: false), HugeInt.one)
        XCTAssert(result == expected_result && quotient == expected_quotient, "test_decimal_addition;result=\(result);expected_result=\(expected_result);quotient=\(String(describing: quotient));expected_quotient=\(String(describing: expected_quotient))")
        
        (result, quotient) = HugeDecimal("998") + HugeDecimal("001", remove_leading_zeros: false)
        (expected_result, expected_quotient) = (decimal, nil)
        XCTAssert(result == expected_result && quotient == expected_quotient, "test_decimal_addition;result=\(result);expected_result=\(expected_result);quotient=\(String(describing: quotient));expected_quotient=\(String(describing: expected_quotient))")
    }
    private func test_decimal_subtraction() {
        var (result, quotient):(HugeDecimal, HugeInt?) = HugeDecimal("999") - HugeDecimal("001", remove_leading_zeros: false)
        var (expected_result, expected_quotient):(HugeDecimal, HugeInt?) = (HugeDecimal("998"), nil)
        XCTAssert(result == expected_result && quotient == expected_quotient, "test_decimal_subtraction;result=\(result);expected_result=\(expected_result);quotient=\(String(describing: quotient));expected_quotient=\(String(describing: expected_quotient))")
    }
    private func test_decimal_multiplication() {
        var (quotient, result):(HugeInt?, HugeDecimal) = HugeDecimal("999") * HugeDecimal("2")
        var (expected_quotient, expected_result):(HugeInt?, HugeDecimal) = (nil, HugeDecimal("1998"))
        XCTAssert(result == expected_result && quotient == expected_quotient, "test_decimal_multiplication;result=\(result);expected_result=\(expected_result);quotient=\(String(describing: quotient));expected_quotient=\(String(describing: expected_quotient))")
        
        (quotient, result) = HugeDecimal("999") * HugeInt("2")
        (expected_quotient, expected_result) = (HugeInt.one, HugeDecimal("998"))
        XCTAssert(result == expected_result && quotient == expected_quotient, "test_decimal_multiplication;result=\(result);expected_result=\(expected_result);quotient=\(String(describing: quotient));expected_quotient=\(String(describing: expected_quotient))")
    }
}

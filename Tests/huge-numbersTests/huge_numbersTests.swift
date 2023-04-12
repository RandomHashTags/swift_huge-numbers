//
//  huge_numbersTests.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

import XCTest
@testable import huge_numbers

final class huge_numbersTests: XCTestCase {
    func testExample() throws {
        test_int()
        test_float()
    }
    
    private func test_int() {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = -integer
        XCTAssert(integer != second_integer)
        XCTAssert(integer == -second_integer)
        XCTAssert(!(integer > integer))
        XCTAssert(!(integer < integer))
        XCTAssert(integer >= integer)
        XCTAssert(integer <= integer)
        
        let eleven:HugeInt = HugeInt("11")
        XCTAssert(eleven >= 4)
        XCTAssert(eleven >= 8)
        XCTAssert(!(eleven >= 12))
        XCTAssert(eleven >= eleven)
        XCTAssert(HugeInt("111") < HugeInt("220"))
        XCTAssert(!(HugeInt("222") < HugeInt("103")))
        
        XCTAssert(second_integer < integer)
        XCTAssert(second_integer <= integer)
        
        test_int_addition()
        test_int_subtraction()
        test_int_multiplication()
        test_int_division()
        test_decimal()
    }
    private func test_int_addition() {
        var integer:HugeInt = HugeInt("93285729350358025806")
        let second_integer:HugeInt = HugeInt("99999999999239579")
        XCTAssert(integer.adding(second_integer) == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer.adding(HugeInt("-1")) == HugeInt("93385729350357265384"))
        
        integer += 1
        XCTAssert(integer == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer+1 == HugeInt("93385729350357265386"), "test_int_addition;integer=\(integer)")
        integer += -1
        XCTAssert(integer == HugeInt("93385729350357265384"), "test_int_addition;integer=\(integer)")
    }
    private func test_int_subtraction() {
        var integer:HugeInt = HugeInt("82372958")
        let second_integer:HugeInt = HugeInt("82372959")
        var result:HugeInt = integer.subtract(second_integer)
        var expected_result:HugeInt = HugeInt("-1")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        XCTAssert(integer.subtract(integer) - 1 == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= 1
        expected_result = HugeInt("-2")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= -2
        expected_result = HugeInt.zero
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("10000") - HugeInt("9045")
        expected_result = HugeInt("955")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)") // TODO: fix (fails test)
    }
    private func test_int_multiplication() {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = -integer
        
        let result_multiplication:HugeInt = HugeInt("2469135782022242628303234363840")
        XCTAssert(integer * 2 == result_multiplication)
        XCTAssert(integer * -2 == -result_multiplication)
        XCTAssert(second_integer * 2 == -result_multiplication)
        XCTAssert(second_integer * -2 == result_multiplication)
    }
    private func test_int_division() {
        var integer:HugeInt = HugeInt("518")
        var number:HugeInt = HugeInt("4")
        var (result, result_remainder):(HugeInt, HugeRemainder) = integer / number
        XCTAssert(result == HugeInt("129") && result_remainder == HugeRemainder(dividend: "2", divisor: "4"), "test_int_division;result=" + result.description + ";remainder=" + result_remainder.description)
        
        (result, result_remainder) = HugeInt("18") / HugeInt("9")
        XCTAssert(result == HugeInt("2") && result_remainder == HugeRemainder(dividend: "0", divisor: "9"), "test_int_division;result=" + result.description + ";remainder=" + result_remainder.description)
        
        (result, result_remainder) = HugeInt("36") / HugeInt("7")
        XCTAssert(result == HugeInt("5") && result_remainder == HugeRemainder(dividend: "1", divisor: "7"), "test_int_division;result=" + result.description + ";remainder=" + result_remainder.description)
        
        (result, result_remainder) = HugeInt("3460987") / HugeInt("89345")
        XCTAssert(result == HugeInt("38") && result_remainder == HugeRemainder(dividend: "65877", divisor: "89345"), "test_int_division;result=" + result.description + ";remainder=" + result_remainder.description)
        
        integer = HugeInt("13")
        let remainder:HugeRemainder = integer /= 6
        XCTAssert(integer == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"))
    }
    
    private func test_float() {
        let float:HugeFloat = HugeFloat("3.1415926535e-10")
        XCTAssert(float.literal_description.elementsEqual("0.00000000031415926535"), "test_float;float=\(float), description=" + float.description)
        XCTAssert(float.description_simplified.elementsEqual("3.1415926535e-10"), "test_float;float=\(float), description_simplified=" + float.description_simplified)
        XCTAssert(HugeFloat("3r1/4") == HugeFloat(pre_decimal_number: HugeInt("3"), post_decimal_number: HugeInt.zero, exponent: 0, remainder: HugeRemainder(dividend: "1", divisor: "4")))
        
        test_float_addition()
        test_float_multiplication()
    }
    private func test_float_addition() {
        let float:HugeFloat = HugeFloat("3.5")
        var result:HugeFloat = float + 1
        var expected_result:HugeFloat = HugeFloat("4.5")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("1.5")
        expected_result = HugeFloat("5")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("2.7")
        expected_result = HugeFloat("6.2")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("10.16")
        expected_result = HugeFloat("13.66")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("196.555")
        expected_result = HugeFloat("200.055")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
    }
    private func test_float_multiplication() {
        var float:HugeFloat = HugeFloat("1.7959")
        var um:Int = 2
        var result:HugeFloat = float * um
        var expected_result:HugeFloat = HugeFloat("3.5918")
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
        
        float = HugeFloat("19385436.795909235895")
        um = 9
        result = float * um
        expected_result = HugeFloat("174468931.163183123055")
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
    }
    
    private func test_decimal() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeDecimal = remainder.to_decimal()
        var expected_result:HugeDecimal = HugeDecimal(value: HugeInt("5"), is_repeating: false, repeating_numbers: [])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "4")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt("25"), is_repeating: false, repeating_numbers: [])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "10")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt("1"), is_repeating: false, repeating_numbers: [])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        
        remainder = HugeRemainder(dividend: "1", divisor: "1005")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt("00099502487562189"), is_repeating: false, repeating_numbers: [])
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
    }
}

//
//  HugeFloatTests.swift
//  
//
//  Created by Evan Anderson on 7/9/23.
//

import XCTest
import HugeNumbers

final class HugeFloatTests : XCTestCase {
    func test_float() {
        var float:HugeFloat = HugeFloat("3.1415926535e-10")
        XCTAssert(float.description_literal.elementsEqual("0.00000000031415926535"), "float=\(float), description=" + float.description)
        XCTAssert(float.description_simplified.elementsEqual("3.1415926535e-10"), "float=\(float), description_simplified=" + float.description_simplified)
        XCTAssert(HugeFloat("3r1/4") == HugeFloat(integer: HugeInt("3"), remainder: HugeRemainder(dividend: "1", divisor: "4")))
        float = HugeFloat("-3")
        XCTAssert(float.description.elementsEqual("-3"), "float=\(float);float.description=" + float.description)
        XCTAssert(float.description_simplified.elementsEqual("-3"), "float=\(float);float.description_simplified=" + float.description_simplified)
        
        let five:HugeFloat = HugeFloat("5")
        XCTAssert(!(five < five))
        XCTAssert(!(five < -five))
        XCTAssert(-five < five)
        
        XCTAssert(five <= five)
        XCTAssert(five >= five)
        XCTAssert(-five <= five)
        XCTAssert(!(-five >= five))
        XCTAssert(five >= -five)
        
        float = HugeFloat(integer: "5", remainder: HugeRemainder(dividend: "5", divisor: "25")).multiply_by_ten(1)
        var expected_result:HugeFloat = HugeFloat(integer: "52", remainder: nil)
        XCTAssert(float == expected_result, "float=\(float);expected_result=\(expected_result)")
    }
    func test_float_addition() {
        let float:HugeFloat = HugeFloat("3.5")
        var result:HugeFloat = float + 1
        var expected_result:HugeFloat = HugeFloat("4.5")
        XCTAssertEqual(result, expected_result)
        
        result = float + HugeFloat("1.5")
        expected_result = HugeFloat("5")
        XCTAssertEqual(result, expected_result)
        
        result = float + HugeFloat("2.7")
        expected_result = HugeFloat("6.2")
        XCTAssertEqual(result, expected_result)
        
        result = float + HugeFloat("10.16")
        expected_result = HugeFloat("13.66")
        XCTAssertEqual(result, expected_result)
        
        result = float + HugeFloat("196.555")
        expected_result = HugeFloat("200.055")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3") + HugeFloat("0.25")
        expected_result = HugeFloat("3.25")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("0") + HugeFloat("-0.25")
        expected_result = HugeFloat("-0.25")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("2.005") + HugeFloat("0.000000000000000000002")
        expected_result = HugeFloat("2.005000000000000000002")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat.zero + HugeFloat("5.25")
        expected_result = HugeFloat("5.25")
        XCTAssertEqual(result, expected_result)
    }
    func test_float_subtraction() {
        var result:HugeFloat = HugeFloat("9.75") - HugeFloat("2")
        var expected_result:HugeFloat = HugeFloat("7.75")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("9.75")
        result -= HugeFloat("2")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3")
        result -= HugeFloat("0.25")
        expected_result = HugeFloat("2.75")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("2")
        result -= HugeFloat("2.25")
        expected_result = HugeFloat("-0.25")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("-2")
        result -= HugeFloat("2.25")
        expected_result = HugeFloat("-4.25")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3.15")
        result -= HugeFloat("0.25")
        expected_result = HugeFloat(integer: HugeInt("2"), decimal: HugeDecimal("90", remove_leading_zeros: false))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("0")
        result -= HugeFloat("9.80665")
        expected_result = HugeFloat("-9.80665")
        XCTAssertEqual(result, expected_result)
        
        result -= HugeFloat("9.80665")
        expected_result = HugeFloat(integer: "-19", decimal: HugeDecimal("61330", remove_leading_zeros: false))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("0")
        result -= HugeFloat("-2.13")
        expected_result = HugeFloat("2.13")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("1000000000000") - HugeFloat("4.2")
        expected_result = HugeFloat("999999999995.8")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3r2/10")
        result -= HugeFloat("0r9/10")
        expected_result = HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: "3", divisor: "10"))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3r2/5")
        result -= HugeFloat("0r9/10")
        expected_result = HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: "25", divisor: "50"))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3")
        result -= HugeFloat("0r2/3")
        expected_result = HugeFloat("2r1/3")
        XCTAssertEqual(result, expected_result)
    }
    func test_float_multiplication() {
        var result:HugeFloat = HugeFloat("1.7959") * HugeFloat(integer: "2")
        var expected_result:HugeFloat = HugeFloat("3.5918")
        XCTAssertEqual(result, expected_result)
        
        result = (HugeFloat("19385436.795909235895") * 9).remainder_to_decimal()
        expected_result = HugeFloat("174468931.163183123055")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("5.25")
        result *= HugeInt("6")
        expected_result = HugeFloat("31.5")
        XCTAssertEqual(result, expected_result)
        
        let planck_constant:HugeFloat = HugeFloat("0.000000000000000000000000000000000662607015")
        result = planck_constant * HugeFloat("1")
        expected_result = planck_constant
        XCTAssertEqual(result, expected_result)
        
        result = planck_constant * HugeFloat("2")
        expected_result = HugeFloat("0.00000000000000000000000000000000132521403")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        result *= HugeInt("5")
        expected_result = HugeFloat(integer: HugeInt("27"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("5")
        result *= HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        expected_result = HugeFloat(integer: HugeInt("27"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        result *= HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("4")))
        expected_result = HugeFloat(integer: HugeInt("12"), remainder: HugeRemainder(dividend: "12", divisor: "32"))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("-5.25") * HugeFloat("2")
        expected_result = HugeFloat("-10.50")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("-5.25") * HugeFloat("-2")
        expected_result = HugeFloat("10.50")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("69").multiply_by_ten(1)
        expected_result = HugeFloat("690")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("69").multiply_by_ten(-1)
        expected_result = HugeFloat("-690")
        XCTAssertEqual(result, expected_result)

        result = HugeFloat("69").multiply_by_ten(-2)
        expected_result = HugeFloat("-6900")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("69.42").multiply_by_ten(3)
        expected_result = HugeFloat("69420")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("69.42").multiply_by_ten(-3)
        expected_result = HugeFloat("-69420")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("1000").multiply_by_ten(-3)
        expected_result = HugeFloat("-1000000")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("999999999995.8").multiply_by_ten(-9)
        expected_result = HugeFloat("-999999999995800000000")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("999999999905.8").multiply_by_ten(-9)
        expected_result = HugeFloat("-999999999905800000000")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("5008").multiply_by_ten(-3)
        expected_result = HugeFloat("-5008000")
        XCTAssertEqual(result, expected_result)
    }
    func test_float_decimal_and_remainder_mismatch_multiplication() {
        var result:HugeFloat = HugeFloat("42.25") * HugeFloat(integer: HugeInt.one, remainder: HugeRemainder(dividend: "1", divisor: "2")).remainder_to_decimal()
        var expected_result:HugeFloat = HugeFloat(integer: "63", remainder: HugeRemainder(dividend: "375", divisor: "1000"))

        result = HugeFloat("42.25") * HugeFloat(integer: HugeInt.zero, remainder: HugeRemainder(dividend: "1", divisor: "2")).remainder_to_decimal()
        expected_result = HugeFloat("21.125")
        XCTAssertEqual(result, expected_result)
    }
    func test_float_move_decimal() {
        var result:HugeFloat = HugeFloat("69.42").move_decimal(-3)
        var expected_result:HugeFloat = HugeFloat("0.06942")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("69.42").move_decimal(3)
        expected_result = HugeFloat("69420")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("1000").move_decimal(-3)
        expected_result = HugeFloat("1")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("999999999995.8").move_decimal(-9)
        expected_result = HugeFloat("999.9999999958")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("999999999905.8").move_decimal(-9)
        expected_result = HugeFloat("999.9999999058")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("5008").move_decimal(-3)
        expected_result = HugeFloat("5.008")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("5036").move_decimal(3)
        expected_result = HugeFloat("5036000")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("1234").move_decimal(-6)
        expected_result = HugeFloat("0.001234")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("500r1/2").move_decimal(1)
        expected_result = HugeFloat("5005")
        XCTAssertEqual(result, expected_result)
    }
    func test_float_division() {
        var result:HugeFloat = HugeFloat("60") / 90
        var expected_result:HugeFloat = HugeFloat("0r60/90")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("9.80665") / HugeFloat("2")
        expected_result = HugeFloat("4.903325")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("9") / HugeFloat("2.5")
        expected_result = HugeFloat("3.6")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("9r6/10") / HugeFloat("2r4/10")
        expected_result = HugeFloat("4")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("1000") / HugeFloat("2")
        expected_result = HugeFloat("500")
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("3066") / HugeFloat("3840")
        expected_result = HugeFloat(integer: HugeInt.zero, remainder: HugeRemainder(dividend: "3066", divisor: "3840"))
        XCTAssertEqual(result, expected_result)
        
        result = HugeFloat("12345.678").divide_by(HugeFloat("54321.012"), precision: HugeInt("100"))
        expected_result = HugeFloat("0.2272726067769135081651277041745834926639437424324863461674830358462393889127102418489552440591497080", remove_trailing_zeros: false)
        XCTAssertEqual(result, expected_result)
    }
    func test_float_rounding() {
        var value:HugeFloat = HugeFloat("59.3551269911")
        var result:HugeFloat = value.rounded(1)
        var expected_result:HugeFloat = HugeFloat("59.3")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(2)
        expected_result = HugeFloat("59.35")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(3)
        expected_result = HugeFloat("59.355")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(4)
        expected_result = HugeFloat("59.3551")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(5)
        expected_result = HugeFloat("59.35513")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(6)
        expected_result = HugeFloat("59.355127")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(7)
        expected_result = HugeFloat("59.3551270")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(8)
        expected_result = HugeFloat("59.35512699")
        XCTAssertEqual(result, expected_result)
        
        value = HugeFloat("12.9999")
        result = value.rounded(1)
        expected_result = HugeFloat("13")
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(2)
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(3)
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(4)
        expected_result = value
        XCTAssertEqual(result, expected_result)
        
        result = value.rounded(5)
        XCTAssertEqual(result, expected_result)
        
        value = HugeFloat("11")
        result = value.rounded(1)
        expected_result = HugeFloat("11")
        XCTAssertEqual(result, expected_result)
    }
}

//
//  HugeIntTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

import XCTest
import HugeNumbers

struct HugeIntTests {
    func validate() async {
        await test_int()
    }
}

extension HugeIntTests {
    private func test_int() async {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = -integer
        XCTAssert(integer != second_integer)
        XCTAssert(integer == -second_integer)
        XCTAssert(!(integer > integer))
        XCTAssert(!(integer < integer))
        XCTAssert(integer >= integer)
        XCTAssert(integer <= integer)
        
        let eleven:HugeInt = HugeInt("11")
        let negative_eleven:HugeInt = HugeInt("-11")
        XCTAssert(eleven >= 4)
        XCTAssert(eleven >= 8)
        XCTAssert(!(eleven >= 12))
        XCTAssert(eleven >= eleven)
        XCTAssert(HugeInt("111") < HugeInt("220"))
        XCTAssert(!(HugeInt("222") < HugeInt("103")))
        
        XCTAssert(HugeInt("5") > HugeInt("-5"))
        XCTAssert(HugeInt("5") >= HugeInt("-5"))
        XCTAssert(HugeInt("-5") < HugeInt("5"))
        XCTAssert(HugeInt("-5") <= HugeInt("5"))
        
        XCTAssert(second_integer < integer)
        XCTAssert(second_integer <= integer)
        
        let six_factors:Set<HugeInt> = await HugeInt("6").get_all_factors_parallel()
        XCTAssert(six_factors.count == 3, "test_int;factors=" + six_factors.description)
        
        var result:HugeInt = eleven.multiply_by_ten(1)
        var expected_result:HugeInt = HugeInt(is_negative: false, [0, 1, 1])
        XCTAssert(result == expected_result, "test_int;result=\(result);expected_result=\(expected_result)")
    
        result = eleven.multiply_by_ten(-1)
        expected_result = HugeInt(is_negative: true, [0, 1, 1])
        XCTAssert(result == expected_result, "test_int;result=\(result);expected_result=\(expected_result)")
        
        
        result = negative_eleven.multiply_by_ten(1)
        expected_result = HugeInt(is_negative: true, [0, 1, 1])
        XCTAssert(result == expected_result, "test_int;result=\(result);expected_result=\(expected_result)")
        
        test_int_addition()
        test_int_subtraction()
        test_int_multiplication()
        test_int_division()
        test_int_factorial()
        test_int_percent()
        test_int_square_root()
        test_int_to_the_power_of()
    }
    private func test_int_addition() {
        var integer:HugeInt = HugeInt("93285729350358025806")
        let second_integer:HugeInt = HugeInt("99999999999239579")
        integer += second_integer
        XCTAssert(integer == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        integer += -1
        XCTAssert(integer == HugeInt("93385729350357265384"))
        
        integer += 1
        XCTAssert(integer == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer+1 == HugeInt("93385729350357265386"), "test_int_addition;integer=\(integer)")
        integer += -1
        XCTAssert(integer == HugeInt("93385729350357265384"), "test_int_addition;integer=\(integer)")
    }
    private func test_int_subtraction() {
        var integer:HugeInt = HugeInt("82372958")
        let second_integer:HugeInt = HugeInt("82372959")
        var result:HugeInt = integer - second_integer
        var expected_result:HugeInt = HugeInt("-1")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        XCTAssert(integer - integer - 1 == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= 1
        expected_result = HugeInt("-2")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= -2
        expected_result = HugeInt.zero
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("10000") - HugeInt("9045")
        expected_result = HugeInt("955")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("780637") - HugeInt("714760")
        expected_result = HugeInt("65877")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("200200") - HugeInt("1")
        expected_result = HugeInt("200199")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
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
        var (quotient, remainder):(HugeInt, HugeRemainder?) = (HugeInt("518") / HugeInt("4"))
        XCTAssert(quotient == HugeInt("129") && remainder == HugeRemainder(dividend: "2", divisor: "4"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("18") / HugeInt("9")
        XCTAssert(quotient == HugeInt("2") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("10") / HugeInt("2")
        XCTAssert(quotient == HugeInt("5") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("36") / HugeInt("7")
        XCTAssert(quotient == HugeInt("5") && remainder == HugeRemainder(dividend: "1", divisor: "7"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("3460987") / HugeInt("89345")
        XCTAssert(quotient == HugeInt("38") && remainder == HugeRemainder(dividend: "65877", divisor: "89345"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("13") / HugeInt("6")
        XCTAssert(quotient == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("25") / HugeInt("5")
        XCTAssert(quotient == HugeInt("5") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("448") / HugeInt("4")
        XCTAssert(quotient == HugeInt("112") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("44") / HugeInt("4")
        XCTAssert(quotient == HugeInt("11") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8320") / HugeInt("2")
        XCTAssert(quotient == HugeInt("4160") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8330") / HugeInt("2")
        XCTAssert(quotient == HugeInt("4165") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8420") / HugeInt("2")
        XCTAssert(quotient == HugeInt("4210") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8520") / HugeInt("2")
        XCTAssert(quotient == HugeInt("4260") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("30") / HugeInt("15")
        XCTAssert(quotient == HugeInt("2") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("40") / HugeInt("4")
        XCTAssert(quotient == HugeInt("10") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("41") / HugeInt("4")
        XCTAssert(quotient == HugeInt("10") && remainder == HugeRemainder(dividend: "1", divisor: "4"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("928359234") / HugeInt("18")
        XCTAssert(quotient == HugeInt("51575513") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("13") / HugeInt("6")
        XCTAssert(quotient == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("-13") / HugeInt("6")
        XCTAssert(quotient == HugeInt("-2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("14345645") / HugeInt("2")
        XCTAssert(quotient == HugeInt("7172822") && remainder == HugeRemainder(dividend: "1", divisor: "2"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("425") / HugeInt("25")
        XCTAssert(quotient == HugeInt("17") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("80665") / HugeInt("2")
        XCTAssert(quotient == HugeInt("40332") && remainder == HugeRemainder(dividend: "1", divisor: "2"), "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("1000") / HugeInt("2")
        XCTAssert(quotient == HugeInt("500") && remainder == nil, "test_int_division;quotient=\(quotient);remainder=\(String(describing: remainder))")
    }
    private func test_int_factorial() {
        var result:HugeInt = HugeInt("5").factorial()
        var expected_result:HugeInt = HugeInt("120")
        XCTAssert(result == expected_result, "test_int_factorial;result=\(result);expected_result=\(expected_result)")
    }
    private func test_int_percent() {
        var integer:HugeInt = HugeInt("100")
        var result:HugeInt = integer % HugeInt("10")
        var expected_result:HugeInt = HugeInt.zero
        XCTAssert(result == expected_result, "test_int_percent;result=\(result);expected_result=\(expected_result)")
        
        result = integer % HugeInt("40")
        expected_result = HugeInt("20")
        XCTAssert(result == expected_result, "test_int_percent;result=\(result);expected_result=\(expected_result)")
    }
    private func test_int_square_root() {
        var integer:HugeInt = HugeInt("7921")
        var result:HugeFloat = sqrt(integer)
        var expected_result:HugeFloat = HugeFloat("89")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("9")
        result = sqrt(integer)
        expected_result = HugeFloat("3")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("64")
        result = sqrt(integer)
        expected_result = HugeFloat("8")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("100")
        result = sqrt(integer)
        expected_result = HugeFloat("10")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("10000")
        result = sqrt(integer)
        expected_result = HugeFloat("100")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("2025")
        result = sqrt(integer)
        expected_result = HugeFloat("45")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("1444")
        result = sqrt(integer)
        expected_result = HugeFloat("38")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("5184")
        result = sqrt(integer)
        expected_result = HugeFloat("72")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("8281")
        result = sqrt(integer)
        expected_result = HugeFloat("91")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("24336")
        result = sqrt(integer)
        expected_result = HugeFloat("156")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("80")
        result = sqrt(integer)
        expected_result = HugeFloat("8")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
        
        integer = HugeInt("0")
        result = sqrt(integer)
        expected_result = HugeFloat("0")
        XCTAssert(result == expected_result, "test_int_square_root;result=\(result);expected_result=\(expected_result)")
    }
    private func test_int_to_the_power_of() {
        var result:HugeInt = HugeInt("2").squared()
        var expected_result:HugeInt = HugeInt("4")
        XCTAssert(result == expected_result, "test_int_to_the_power_of;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("3").cubed()
        expected_result = HugeInt("27")
        XCTAssert(result == expected_result, "test_int_to_the_power_of;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("5").to_the_power_of(5)
        expected_result = HugeInt("3125")
        XCTAssert(result == expected_result, "test_int_to_the_power_of;result=\(result);expected_result=\(expected_result)")
    }
}

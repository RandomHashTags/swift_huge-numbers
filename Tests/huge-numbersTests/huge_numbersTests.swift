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
        
        XCTAssert(second_integer < integer)
        XCTAssert(second_integer <= integer)
        
        test_int_addition()
        test_int_subtraction()
        test_int_multiplication()
        
        test_float()
    }
    private func test_int_addition() {
        var integer:HugeInt = HugeInt("93285729350358025806")
        let second_integer:HugeInt = HugeInt("99999999999239579")
        XCTAssert(integer.adding(second_integer) == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer.adding(HugeInt(-1)) == HugeInt("93385729350357265384"))
        
        integer += 1
        XCTAssert(integer == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer+1 == HugeInt("93385729350357265386"), "test_int_addition;integer=\(integer)")
        integer += -1
        XCTAssert(integer == HugeInt("93385729350357265384"), "test_int_addition;integer=\(integer)")
    }
    private func test_int_subtraction() {
        var integer:HugeInt = HugeInt("82372958")
        let second_integer:HugeInt = HugeInt("82372959")
        XCTAssert(integer.subtract(second_integer) == HugeInt("-1"), "test_int_subtraction;integer=\(integer)")
        XCTAssert(integer.subtract(integer) - 1 == HugeInt("-1"), "test_int_subtraction;integer=\(integer)")
        
        integer -= 1
        XCTAssert(integer == HugeInt(-1), "test_int_subtraction;integer=\(integer)")
        integer -= -1
        XCTAssert(integer == HugeInt(0), "test_int_subtraction;integer=\(integer)")
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
    
    private func test_float() {
        let float:HugeFloat = HugeFloat("3.1415926535e-10")
        XCTAssert(float.description.elementsEqual("0.00000000031415926535"), "test_float;float=\(float), description=" + float.description)
        XCTAssert(float.description_simplified.elementsEqual("3.1415926535e-10"), "test_float;float=\(float), description_simplified=" + float.description_simplified)
        
        test_float_multiplication()
    }
    private func test_float_addition() {
        let float:HugeFloat = HugeFloat(1.5)
        let result:HugeFloat = float + 3
        XCTAssert(result == HugeFloat(4.5), "test_float_addition;result=\(result)")
    }
    private func test_float_multiplication() {
        var float:HugeFloat = HugeFloat("1.7959")
        var um:Int = 2
        var result:HugeFloat = float * um
        var expected_result:HugeFloat = HugeFloat(3.5918)
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
        
        float = HugeFloat("19385436.795909235895")
        um = 9
        result = float * um
        expected_result = HugeFloat("174468931.163183123055")
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
    }
}

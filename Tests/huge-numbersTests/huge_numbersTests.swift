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
        let second_integer:HugeInt = HugeInt("-1234567891011121314151617181920")
        XCTAssert(integer != second_integer)
        XCTAssert(integer == -second_integer)
        XCTAssert(!(integer > integer))
        XCTAssert(!(integer < integer))
        XCTAssert(integer >= integer)
        XCTAssert(integer <= integer)
        
        XCTAssert(second_integer < integer)
        XCTAssert(second_integer <= integer)
        
        test_int_addition()
        test_int_multiplication()
    }
    private func test_int_addition() {
        var integer:HugeInt = HugeInt("93285729350358025806")
        let second_integer:HugeInt = HugeInt("99999999999239579")
        let result:HugeInt = integer.adding(value: second_integer)
        XCTAssert(result == HugeInt("93385729350357265385"), "test_int_addition;result=" + result.description + ";numbers=" + result.numbers.reversed().description)
    }
    private func test_int_multiplication() {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = HugeInt("-1234567891011121314151617181920")
        
        let result_multiplication:HugeInt = HugeInt("2469135782022242628303234363840")
        XCTAssert(integer * 2 == result_multiplication)
        XCTAssert(integer * -2 == -result_multiplication)
        XCTAssert(second_integer * 2 == -result_multiplication)
        XCTAssert(second_integer * -2 == result_multiplication)
    }
}

//
//  HugeRemainderTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

import XCTest
import HugeNumbers

final class HugeRemainderTests : XCTestCase {
    func test_remainder() async {
        var remainder:HugeRemainder = HugeRemainder(dividend: "25", divisor: "5").multiply_by_ten(1)
        var expected_result:HugeRemainder = HugeRemainder(dividend: "250", divisor: "5")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "25", divisor: "5").multiply_by_ten(-1)
        expected_result = HugeRemainder(dividend: "-250", divisor: "5")
        XCTAssertEqual(remainder, expected_result)
    }
    func test_remainder_addition() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder + HugeRemainder(dividend: "1", divisor: "4")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "6", divisor: "8")
        XCTAssertEqual(result, expected_result)
    }
    func test_remainder_subtraction() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder - HugeRemainder(dividend: "1", divisor: "4")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "2", divisor: "8")
        XCTAssertEqual(result, expected_result)
        
        result = HugeRemainder(dividend: "5", divisor: "15") - HugeRemainder(dividend: "10", divisor: "15")
        expected_result = HugeRemainder(dividend: "-5", divisor: "15")
        XCTAssertEqual(result, expected_result)
        
        result = HugeRemainder(dividend: "1", divisor: "4") - remainder
        expected_result = HugeRemainder(dividend: "-2", divisor: "8")
        XCTAssertEqual(result, expected_result)
        
        remainder = HugeRemainder(dividend: "1", divisor: "2")
        result = remainder - remainder
        expected_result = HugeRemainder(dividend: "0", divisor: "2")
        XCTAssertEqual(result, expected_result)
        
        remainder = HugeRemainder(dividend: "1", divisor: "5")
        result = remainder - HugeInt("2")
        expected_result = HugeRemainder(dividend: "-9", divisor: "5")
        XCTAssertEqual(result, expected_result)
    }
    func test_remainder_multiplication() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder * HugeRemainder(dividend: "5", divisor: "6")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "5", divisor: "12")
        XCTAssertEqual(result, expected_result)
        
        remainder = HugeRemainder(dividend: "5", divisor: "41")
        result = remainder * HugeRemainder(dividend: "4", divisor: "82")
        expected_result = HugeRemainder(dividend: "20", divisor: "3362")
        XCTAssertEqual(result, expected_result)
    }
    func test_remainder_division() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "60", divisor: "1")
        var result:HugeRemainder = remainder / HugeRemainder(dividend: "90", divisor: "1")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "60", divisor: "90")
        XCTAssertEqual(result, expected_result)
        
        result = remainder / HugeRemainder(dividend: "24", divisor: "50")
        expected_result = HugeRemainder(dividend: "3000", divisor: "24")
        XCTAssertEqual(result, expected_result)
    }
    func test_remainder_simplify() async {
        var remainder:HugeRemainder = HugeRemainder(dividend: "2", divisor: "4")
        await remainder.simplify_parallel()
        var expected_result:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "3", divisor: "9")
        await remainder.simplify_parallel()
        expected_result = HugeRemainder(dividend: "1", divisor: "3")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "4", divisor: "22")
        await remainder.simplify_parallel()
        expected_result = HugeRemainder(dividend: "2", divisor: "11")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "3", divisor: "10")
        await remainder.simplify_parallel()
        expected_result = remainder
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "5", divisor: "200")
        await remainder.simplify_parallel()
        expected_result = HugeRemainder(dividend: "1", divisor: "40")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "6", divisor: "36")
        await remainder.simplify_parallel()
        expected_result = HugeRemainder(dividend: "1", divisor: "6")
        XCTAssertEqual(remainder, expected_result)
        
        remainder = HugeRemainder(dividend: "11", divisor: "121")
        await remainder.simplify_parallel()
        expected_result = HugeRemainder(dividend: "1", divisor: "11")
        XCTAssertEqual(remainder, expected_result)
        
        // very resource intensive
        /*remainder = HugeRemainder(dividend: "14345645", divisor: "39488434560")
        await remainder.simplify()
        expected_result = HugeRemainder(dividend: "2869129", divisor: "7897686912")
        XCTAssertEqual(remainder, expected_result)*/
    }
}

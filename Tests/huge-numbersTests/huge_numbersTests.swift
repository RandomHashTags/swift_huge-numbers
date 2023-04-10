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
        var integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = HugeInt("-1234567891011121314151617181920")
        XCTAssert(integer != second_integer)
        XCTAssert((integer > integer) == false)
        XCTAssert((integer < integer) == false)
        XCTAssert(integer >= integer)
        XCTAssert(integer <= integer)
        XCTAssert(second_integer < integer)
        XCTAssert(second_integer <= integer)
        
        XCTAssert(integer * 2 == HugeInt("2469135782022242628303234363840"))
        XCTAssert(second_integer * 2 == HugeInt("-2469135782022242628303234363840"))
    }
}

//
//  HugeRemainderTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

#if compiler(>=6.0)
import HugeNumbers
import Testing

struct HugeRemainderTests {
    @Test
    func remainder() {
        var remainder = HugeRemainder(dividend: "25", divisor: "5").multiplyByTen(1)
        var expectedResult = HugeRemainder(dividend: "250", divisor: "5")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "25", divisor: "5").multiplyByTen(-1)
        expectedResult = HugeRemainder(dividend: "-250", divisor: "5")
        #expect(remainder == expectedResult)
    }
    
    @Test
    func remainderSimplify() async {
        var remainder:HugeRemainder = HugeRemainder(dividend: "2", divisor: "4")
        await remainder.simplify_parallel()
        var expectedResult:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "3", divisor: "9")
        await remainder.simplify_parallel()
        expectedResult = HugeRemainder(dividend: "1", divisor: "3")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "4", divisor: "22")
        await remainder.simplify_parallel()
        expectedResult = HugeRemainder(dividend: "2", divisor: "11")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "3", divisor: "10")
        await remainder.simplify_parallel()
        expectedResult = remainder
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "5", divisor: "200")
        await remainder.simplify_parallel()
        expectedResult = HugeRemainder(dividend: "1", divisor: "40")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "6", divisor: "36")
        await remainder.simplify_parallel()
        expectedResult = HugeRemainder(dividend: "1", divisor: "6")
        #expect(remainder == expectedResult)
        
        remainder = HugeRemainder(dividend: "11", divisor: "121")
        await remainder.simplify_parallel()
        expectedResult = HugeRemainder(dividend: "1", divisor: "11")
        #expect(remainder == expectedResult)
        
        // very resource intensive
        /*remainder = HugeRemainder(dividend: "14345645", divisor: "39488434560")
        await remainder.simplify()
        expectedResult = HugeRemainder(dividend: "2869129", divisor: "7897686912")
        #expect(remainder == expectedResult)*/
    }
}

// MARK: Addition
extension HugeRemainderTests {
    @Test
    func remainderAddition() {
        var remainder = HugeRemainder(dividend: "1", divisor: "2")
        var result = remainder + HugeRemainder(dividend: "1", divisor: "4")
        var expectedResult = HugeRemainder(dividend: "6", divisor: "8")
        #expect(result == expectedResult)
    }
}

// MARK: Subtraction
extension HugeRemainderTests {
    @Test
    func remainderSubtraction() {
        var remainder = HugeRemainder(dividend: "1", divisor: "2")
        var result = remainder - HugeRemainder(dividend: "1", divisor: "4")
        var expectedResult = HugeRemainder(dividend: "2", divisor: "8")
        #expect(result == expectedResult)
        
        result = HugeRemainder(dividend: "5", divisor: "15") - HugeRemainder(dividend: "10", divisor: "15")
        expectedResult = HugeRemainder(dividend: "-5", divisor: "15")
        #expect(result == expectedResult)
        
        result = HugeRemainder(dividend: "1", divisor: "4") - remainder
        expectedResult = HugeRemainder(dividend: "-2", divisor: "8")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "1", divisor: "2")
        result = remainder - remainder
        expectedResult = HugeRemainder(dividend: "0", divisor: "2")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "1", divisor: "5")
        result = remainder - HugeInt("2")
        expectedResult = HugeRemainder(dividend: "-9", divisor: "5")
        #expect(result == expectedResult)
    }
}

// MARK: Multiplication
extension HugeRemainderTests {
    @Test
    func remainderMultiplication() {
        var remainder = HugeRemainder(dividend: "1", divisor: "2")
        var result = remainder * HugeRemainder(dividend: "5", divisor: "6")
        var expectedResult = HugeRemainder(dividend: "5", divisor: "12")
        #expect(result == expectedResult)
        
        remainder = HugeRemainder(dividend: "5", divisor: "41")
        result = remainder * HugeRemainder(dividend: "4", divisor: "82")
        expectedResult = HugeRemainder(dividend: "20", divisor: "3362")
        #expect(result == expectedResult)
    }
}

// MARK: Division
extension HugeRemainderTests {
    @Test
    func remainderDivision() {
        var remainder = HugeRemainder(dividend: "60", divisor: "1")
        var result = remainder / HugeRemainder(dividend: "90", divisor: "1")
        var expectedResult = HugeRemainder(dividend: "60", divisor: "90")
        #expect(result == expectedResult)
        
        result = remainder / HugeRemainder(dividend: "24", divisor: "50")
        expectedResult = HugeRemainder(dividend: "3000", divisor: "24")
        #expect(result == expectedResult)
    }
}

#endif
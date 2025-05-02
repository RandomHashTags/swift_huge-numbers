//
//  HugeFloatTests.swift
//  
//
//  Created by Evan Anderson on 7/9/23.
//

#if compiler(>=6.0)
import HugeNumbers
import Testing

struct HugeFloatTests {
    @Test
    func float() {
        var float:HugeFloat = HugeFloat("3.1415926535e-10")
        #expect(float.descriptionLiteral.elementsEqual("0.00000000031415926535"), "float=\(float), description=\(float.description)")
        #expect(float.descriptionSimplified.elementsEqual("3.1415926535e-10"), "float=\(float), descriptionSimplified=\(float.descriptionSimplified)")
        #expect(HugeFloat("3r1/4") == HugeFloat(integer: HugeInt("3"), remainder: HugeRemainder(dividend: "1", divisor: "4")))
        float = HugeFloat("-3")
        #expect(float.description.elementsEqual("-3"), "float=\(float);float.description=\(float.description)")
        #expect(float.descriptionSimplified.elementsEqual("-3"), "float=\(float);float.descriptionSimplified=\(float.descriptionSimplified)")
        
        let five:HugeFloat = HugeFloat("5")
        #expect(!(five < five))
        #expect(!(five < -five))
        #expect(-five < five)
        
        #expect(five <= five)
        #expect(five >= five)
        #expect(-five <= five)
        #expect(!(-five >= five))
        #expect(five >= -five)
        
        float = HugeFloat(integer: "5", remainder: HugeRemainder(dividend: "5", divisor: "25")).multiplyByTen(1)
        var expectedResult:HugeFloat = HugeFloat(integer: "52", remainder: nil)
        #expect(float == expectedResult, "float=\(float);expectedResult=\(expectedResult)")
    }
    
    @Test
    func float_decimal_and_remainder_mismatch_multiplication() {
        var result = HugeFloat("42.25") * HugeFloat(integer: HugeInt.one, remainder: HugeRemainder(dividend: "1", divisor: "2")).remainderToDecimal()
        var expectedResult:HugeFloat = HugeFloat(integer: "63", remainder: HugeRemainder(dividend: "375", divisor: "1000"))

        result = HugeFloat("42.25") * HugeFloat(integer: HugeInt.zero, remainder: HugeRemainder(dividend: "1", divisor: "2")).remainderToDecimal()
        expectedResult = HugeFloat("21.125")
        #expect(result == expectedResult)
    }
}


// MARK: Addition
extension HugeFloatTests {
    @Test
    func floatAddition() {
        let float = HugeFloat("3.5")
        var result = float + 1
        var expectedResult = HugeFloat("4.5")
        #expect(result == expectedResult)
        
        result = float + HugeFloat("1.5")
        expectedResult = HugeFloat("5")
        #expect(result == expectedResult)
        
        result = float + HugeFloat("2.7")
        expectedResult = HugeFloat("6.2")
        #expect(result == expectedResult)
        
        result = float + HugeFloat("10.16")
        expectedResult = HugeFloat("13.66")
        #expect(result == expectedResult)
        
        result = float + HugeFloat("196.555")
        expectedResult = HugeFloat("200.055")
        #expect(result == expectedResult)
        
        result = HugeFloat("3") + HugeFloat("0.25")
        expectedResult = HugeFloat("3.25")
        #expect(result == expectedResult)
        
        result = HugeFloat("0") + HugeFloat("-0.25")
        expectedResult = HugeFloat("-0.25")
        #expect(result == expectedResult)
        
        result = HugeFloat("2.005") + HugeFloat("0.000000000000000000002")
        expectedResult = HugeFloat("2.005000000000000000002")
        #expect(result == expectedResult)
        
        result = HugeFloat.zero + HugeFloat("5.25")
        expectedResult = HugeFloat("5.25")
        #expect(result == expectedResult)
    }
}

// MARK: Subtraction
extension HugeFloatTests {
    @Test
    func floatSubtraction() {
        var result = HugeFloat("9.75") - HugeFloat("2")
        var expectedResult = HugeFloat("7.75")
        #expect(result == expectedResult)
        
        result = HugeFloat("9.75")
        result -= HugeFloat("2")
        #expect(result == expectedResult)
        
        result = HugeFloat("3")
        result -= HugeFloat("0.25")
        expectedResult = HugeFloat("2.75")
        #expect(result == expectedResult)
        
        result = HugeFloat("2")
        result -= HugeFloat("2.25")
        expectedResult = HugeFloat("-0.25")
        #expect(result == expectedResult)
        
        result = HugeFloat("-2")
        result -= HugeFloat("2.25")
        expectedResult = HugeFloat("-4.25")
        #expect(result == expectedResult)
        
        result = HugeFloat("3.15")
        result -= HugeFloat("0.25")
        expectedResult = HugeFloat(integer: HugeInt("2"), decimal: HugeDecimal("90", removeLeadingZeros: false))
        #expect(result == expectedResult)
        
        result = HugeFloat("0")
        result -= HugeFloat("9.80665")
        expectedResult = HugeFloat("-9.80665")
        #expect(result == expectedResult)
        
        result -= HugeFloat("9.80665")
        expectedResult = HugeFloat(integer: "-19", decimal: HugeDecimal("61330", removeLeadingZeros: false))
        #expect(result == expectedResult)
        
        result = HugeFloat("0")
        result -= HugeFloat("-2.13")
        expectedResult = HugeFloat("2.13")
        #expect(result == expectedResult)
        
        result = HugeFloat("1000000000000") - HugeFloat("4.2")
        expectedResult = HugeFloat("999999999995.8")
        #expect(result == expectedResult)
        
        result = HugeFloat("3r2/10")
        result -= HugeFloat("0r9/10")
        expectedResult = HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: "3", divisor: "10"))
        #expect(result == expectedResult)
        
        result = HugeFloat("3r2/5")
        result -= HugeFloat("0r9/10")
        expectedResult = HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: "25", divisor: "50"))
        #expect(result == expectedResult)
        
        result = HugeFloat("3")
        result -= HugeFloat("0r2/3")
        expectedResult = HugeFloat("2r1/3")
        #expect(result == expectedResult)
    }
}

// MARK: Multiplication
extension HugeFloatTests {
    @Test
    func floatMultiplication() {
        var result = HugeFloat("1.7959") * HugeFloat(integer: "2")
        var expectedResult = HugeFloat("3.5918")
        #expect(result == expectedResult)
        
        result = (HugeFloat("19385436.795909235895") * 9).remainderToDecimal()
        expectedResult = HugeFloat("174468931.163183123055")
        #expect(result == expectedResult)
        
        result = HugeFloat("5.25")
        result *= HugeInt("6")
        expectedResult = HugeFloat("31.5")
        #expect(result == expectedResult)
        
        let planck_constant = HugeFloat("0.000000000000000000000000000000000662607015")
        result = planck_constant * HugeFloat("1")
        expectedResult = planck_constant
        #expect(result == expectedResult)
        
        result = planck_constant * HugeFloat("2")
        expectedResult = HugeFloat("0.00000000000000000000000000000000132521403")
        #expect(result == expectedResult)
        
        result = HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        result *= HugeInt("5")
        expectedResult = HugeFloat(integer: HugeInt("27"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        #expect(result == expectedResult)
        
        result = HugeFloat("5")
        result *= HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        expectedResult = HugeFloat(integer: HugeInt("27"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        #expect(result == expectedResult)
        
        result = HugeFloat(integer: HugeInt("5"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("2")))
        result *= HugeFloat(integer: HugeInt("2"), remainder: HugeRemainder(dividend: HugeInt("1"), divisor: HugeInt("4")))
        expectedResult = HugeFloat(integer: HugeInt("12"), remainder: HugeRemainder(dividend: "12", divisor: "32"))
        #expect(result == expectedResult)
        
        result = HugeFloat("-5.25") * HugeFloat("2")
        expectedResult = HugeFloat("-10.50")
        #expect(result == expectedResult)
        
        result = HugeFloat("-5.25") * HugeFloat("-2")
        expectedResult = HugeFloat("10.50")
        #expect(result == expectedResult)
        
        result = HugeFloat("69").multiplyByTen(1)
        expectedResult = HugeFloat("690")
        #expect(result == expectedResult)
        
        result = HugeFloat("69").multiplyByTen(-1)
        expectedResult = HugeFloat("-690")
        #expect(result == expectedResult)

        result = HugeFloat("69").multiplyByTen(-2)
        expectedResult = HugeFloat("-6900")
        #expect(result == expectedResult)
        
        result = HugeFloat("69.42").multiplyByTen(3)
        expectedResult = HugeFloat("69420")
        #expect(result == expectedResult)
        
        result = HugeFloat("69.42").multiplyByTen(-3)
        expectedResult = HugeFloat("-69420")
        #expect(result == expectedResult)
        
        result = HugeFloat("1000").multiplyByTen(-3)
        expectedResult = HugeFloat("-1000000")
        #expect(result == expectedResult)
        
        result = HugeFloat("999999999995.8").multiplyByTen(-9)
        expectedResult = HugeFloat("-999999999995800000000")
        #expect(result == expectedResult)
        
        result = HugeFloat("999999999905.8").multiplyByTen(-9)
        expectedResult = HugeFloat("-999999999905800000000")
        #expect(result == expectedResult)
        
        result = HugeFloat("5008").multiplyByTen(-3)
        expectedResult = HugeFloat("-5008000")
        #expect(result == expectedResult)
    }
}

// MARK: Division
extension HugeFloatTests {
    @Test
    func floatDivision() {
        var result = HugeFloat("60") / 90
        var expectedResult = HugeFloat("0r60/90")
        #expect(result == expectedResult)
        
        result = HugeFloat("9.80665") / HugeFloat("2")
        expectedResult = HugeFloat("4.903325")
        #expect(result == expectedResult)
        
        result = HugeFloat("9") / HugeFloat("2.5")
        expectedResult = HugeFloat("3.6")
        #expect(result == expectedResult)
        
        result = HugeFloat("9r6/10") / HugeFloat("2r4/10")
        expectedResult = HugeFloat("4")
        #expect(result == expectedResult)
        
        result = HugeFloat("1000") / HugeFloat("2")
        expectedResult = HugeFloat("500")
        #expect(result == expectedResult)
        
        result = HugeFloat("3066") / HugeFloat("3840")
        expectedResult = HugeFloat(integer: HugeInt.zero, remainder: HugeRemainder(dividend: "3066", divisor: "3840"))
        #expect(result == expectedResult)
        
        result = HugeFloat("12345.678").divide_by(HugeFloat("54321.012"), precision: HugeInt("100"))
        expectedResult = HugeFloat("0.2272726067769135081651277041745834926639437424324863461674830358462393889127102418489552440591497080", removeTrailingZeros: false)
        #expect(result == expectedResult)
    }
}

// MARK: Move Decimal
extension HugeFloatTests {
    @Test
    func floatMoveDecimal() {
        var result = HugeFloat("69.42").move_decimal(-3)
        var expectedResult = HugeFloat("0.06942")
        #expect(result == expectedResult)
        
        result = HugeFloat("69.42").move_decimal(3)
        expectedResult = HugeFloat("69420")
        #expect(result == expectedResult)
        
        result = HugeFloat("1000").move_decimal(-3)
        expectedResult = HugeFloat("1")
        #expect(result == expectedResult)
        
        result = HugeFloat("999999999995.8").move_decimal(-9)
        expectedResult = HugeFloat("999.9999999958")
        #expect(result == expectedResult)
        
        result = HugeFloat("999999999905.8").move_decimal(-9)
        expectedResult = HugeFloat("999.9999999058")
        #expect(result == expectedResult)
        
        result = HugeFloat("5008").move_decimal(-3)
        expectedResult = HugeFloat("5.008")
        #expect(result == expectedResult)
        
        result = HugeFloat("5036").move_decimal(3)
        expectedResult = HugeFloat("5036000")
        #expect(result == expectedResult)
        
        result = HugeFloat("1234").move_decimal(-6)
        expectedResult = HugeFloat("0.001234")
        #expect(result == expectedResult)
        
        result = HugeFloat("500r1/2").move_decimal(1)
        expectedResult = HugeFloat("5005")
        #expect(result == expectedResult)
    }
}

// MARK: Rounding
extension HugeFloatTests {
    @Test
    func floatRounding() {
        var value = HugeFloat("59.3551269911")
        var result = value.rounded(1)
        var expectedResult = HugeFloat("59.3")
        #expect(result == expectedResult)
        
        result = value.rounded(2)
        expectedResult = HugeFloat("59.35")
        #expect(result == expectedResult)
        
        result = value.rounded(3)
        expectedResult = HugeFloat("59.355")
        #expect(result == expectedResult)
        
        result = value.rounded(4)
        expectedResult = HugeFloat("59.3551")
        #expect(result == expectedResult)
        
        result = value.rounded(5)
        expectedResult = HugeFloat("59.35513")
        #expect(result == expectedResult)
        
        result = value.rounded(6)
        expectedResult = HugeFloat("59.355127")
        #expect(result == expectedResult)
        
        result = value.rounded(7)
        expectedResult = HugeFloat("59.3551270")
        #expect(result == expectedResult)
        
        result = value.rounded(8)
        expectedResult = HugeFloat("59.35512699")
        #expect(result == expectedResult)
        
        value = HugeFloat("12.9999")
        result = value.rounded(1)
        expectedResult = HugeFloat("13")
        #expect(result == expectedResult)
        
        result = value.rounded(2)
        #expect(result == expectedResult)
        
        result = value.rounded(3)
        #expect(result == expectedResult)
        
        result = value.rounded(4)
        expectedResult = value
        #expect(result == expectedResult)
        
        result = value.rounded(5)
        #expect(result == expectedResult)
        
        value = HugeFloat("11")
        result = value.rounded(1)
        expectedResult = HugeFloat("11")
        #expect(result == expectedResult)
    }
}

#endif
//
//  HugeIntTests.swift
//
//
//  Created by Evan Anderson on 7/9/23.
//

#if compiler(>=6.0)

import HugeNumbers
import Testing

struct HugeIntTests {
    @Test
    func int() async {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = -integer
        #expect(integer != second_integer)
        #expect(integer == -second_integer)
        #expect(!(integer > integer))
        #expect(!(integer < integer))
        #expect(integer >= integer)
        #expect(integer <= integer)
        
        let eleven:HugeInt = HugeInt("11")
        let negative_eleven:HugeInt = HugeInt("-11")
        #expect(eleven >= 4)
        #expect(eleven >= 8)
        #expect(!(eleven >= 12))
        #expect(eleven >= eleven)
        #expect(HugeInt("111") < HugeInt("220"))
        #expect(!(HugeInt("222") < HugeInt("103")))
        
        #expect(HugeInt("5") > HugeInt("-5"))
        #expect(HugeInt("5") >= HugeInt("-5"))
        #expect(HugeInt("-5") < HugeInt("5"))
        #expect(HugeInt("-5") <= HugeInt("5"))
        
        #expect(second_integer < integer)
        #expect(second_integer <= integer)
        
        let six_factors:Set<HugeInt> = await HugeInt("6").getAllFactorsParallel()
        #expect(six_factors.count == 3, "factors=\(six_factors.description)")
        
        var result:HugeInt = eleven.multiplyByTen(1)
        var expectedResult:HugeInt = HugeInt(isNegative: false, [0, 1, 1])
        #expect(result == expectedResult)
    
        result = eleven.multiplyByTen(-1)
        expectedResult = HugeInt(isNegative: true, [0, 1, 1])
        #expect(result == expectedResult)
        
        
        result = negative_eleven.multiplyByTen(1)
        expectedResult = HugeInt(isNegative: true, [0, 1, 1])
        #expect(result == expectedResult)
    }
}

// MARK: Addition
extension HugeIntTests {
    @Test
    func intAddition() {
        var integer = HugeInt("93285729350358025806")
        let secondInteger = HugeInt("99999999999239579")
        integer += secondInteger
        #expect(integer == HugeInt("93385729350357265385"))
        integer += -1
        #expect(integer == HugeInt("93385729350357265384"))
        
        integer += 1
        #expect(integer == HugeInt("93385729350357265385"))
        #expect(integer+1 == HugeInt("93385729350357265386"))
        integer += -1
        #expect(integer == HugeInt("93385729350357265384"))
    }
}

// MARK: Subtraction
extension HugeIntTests {
    @Test
    func intSubtraction() {
        var integer = HugeInt("82372958")
        let second_integer = HugeInt("82372959")
        var result = integer - second_integer
        var expectedResult = HugeInt("-1")
        #expect(result == expectedResult)
        #expect(integer - integer - 1 == expectedResult, "result=\(result);expectedResult=\(expectedResult)")
        
        result -= 1
        expectedResult = HugeInt("-2")
        #expect(result == expectedResult)
        
        result -= -2
        expectedResult = HugeInt.zero
        #expect(result == expectedResult)
        
        result = HugeInt("10000") - HugeInt("9045")
        expectedResult = HugeInt("955")
        #expect(result == expectedResult)
        
        result = HugeInt("780637") - HugeInt("714760")
        expectedResult = HugeInt("65877")
        #expect(result == expectedResult)
        
        result = HugeInt("200200") - HugeInt("1")
        expectedResult = HugeInt("200199")
        #expect(result == expectedResult)
    }
}

// MARK: Multiplication
extension HugeIntTests {
    @Test
    func intMultiplication() {
        let integer = HugeInt("1234567891011121314151617181920")
        let secondInteger = -integer
        
        let resultMultiplication:HugeInt = HugeInt("2469135782022242628303234363840")
        #expect(integer * 2 == resultMultiplication)
        #expect(integer * -2 == -resultMultiplication)
        #expect(secondInteger * 2 == -resultMultiplication)
        #expect(secondInteger * -2 == resultMultiplication)
    }
}

// MARK: Division
extension HugeIntTests {
    @Test
    func intDivision() {
        var (quotient, remainder) = (HugeInt("518") / HugeInt("4"))
        #expect(quotient == HugeInt("129") && remainder == HugeRemainder(dividend: "2", divisor: "4"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("18") / HugeInt("9")
        #expect(quotient == HugeInt("2") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("10") / HugeInt("2")
        #expect(quotient == HugeInt("5") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("36") / HugeInt("7")
        #expect(quotient == HugeInt("5") && remainder == HugeRemainder(dividend: "1", divisor: "7"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("3460987") / HugeInt("89345")
        #expect(quotient == HugeInt("38") && remainder == HugeRemainder(dividend: "65877", divisor: "89345"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("13") / HugeInt("6")
        #expect(quotient == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("25") / HugeInt("5")
        #expect(quotient == HugeInt("5") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("448") / HugeInt("4")
        #expect(quotient == HugeInt("112") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("44") / HugeInt("4")
        #expect(quotient == HugeInt("11") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8320") / HugeInt("2")
        #expect(quotient == HugeInt("4160") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8330") / HugeInt("2")
        #expect(quotient == HugeInt("4165") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8420") / HugeInt("2")
        #expect(quotient == HugeInt("4210") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("8520") / HugeInt("2")
        #expect(quotient == HugeInt("4260") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("30") / HugeInt("15")
        #expect(quotient == HugeInt("2") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("40") / HugeInt("4")
        #expect(quotient == HugeInt("10") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("41") / HugeInt("4")
        #expect(quotient == HugeInt("10") && remainder == HugeRemainder(dividend: "1", divisor: "4"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("928359234") / HugeInt("18")
        #expect(quotient == HugeInt("51575513") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("13") / HugeInt("6")
        #expect(quotient == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("-13") / HugeInt("6")
        #expect(quotient == HugeInt("-2") && remainder == HugeRemainder(dividend: "1", divisor: "6"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("14345645") / HugeInt("2")
        #expect(quotient == HugeInt("7172822") && remainder == HugeRemainder(dividend: "1", divisor: "2"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("425") / HugeInt("25")
        #expect(quotient == HugeInt("17") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("80665") / HugeInt("2")
        #expect(quotient == HugeInt("40332") && remainder == HugeRemainder(dividend: "1", divisor: "2"), "quotient=\(quotient);remainder=\(String(describing: remainder))")
        
        (quotient, remainder) = HugeInt("1000") / HugeInt("2")
        #expect(quotient == HugeInt("500") && remainder == nil, "quotient=\(quotient);remainder=\(String(describing: remainder))")
    }
}

// MARK: Factorial
extension HugeIntTests {
    @Test
    func intFactorial() {
        var result = HugeInt("5").factorial()
        var expectedResult = HugeInt("120")
        #expect(result == expectedResult)
    }
}

// MARK: Modulo
extension HugeIntTests {
    @Test
    func intModulo() {
        var integer = HugeInt("100")
        var result = integer % HugeInt("10")
        var expectedResult = HugeInt.zero
        #expect(result == expectedResult)
        
        result = integer % HugeInt("40")
        expectedResult = HugeInt("20")
        #expect(result == expectedResult)
    }
}

// MARK: Square Root
extension HugeIntTests {
    @Test
    func intSquareRoot() {
        var integer = HugeInt("7921")
        var result = sqrt(integer)
        var expectedResult = HugeFloat("89")
        #expect(result == expectedResult)
        
        integer = HugeInt("9")
        result = sqrt(integer)
        expectedResult = HugeFloat("3")
        #expect(result == expectedResult)
        
        integer = HugeInt("64")
        result = sqrt(integer)
        expectedResult = HugeFloat("8")
        #expect(result == expectedResult)
        
        integer = HugeInt("100")
        result = sqrt(integer)
        expectedResult = HugeFloat("10")
        #expect(result == expectedResult)
        
        integer = HugeInt("10000")
        result = sqrt(integer)
        expectedResult = HugeFloat("100")
        #expect(result == expectedResult)
        
        integer = HugeInt("2025")
        result = sqrt(integer)
        expectedResult = HugeFloat("45")
        #expect(result == expectedResult)
        
        integer = HugeInt("1444")
        result = sqrt(integer)
        expectedResult = HugeFloat("38")
        #expect(result == expectedResult)
        
        integer = HugeInt("5184")
        result = sqrt(integer)
        expectedResult = HugeFloat("72")
        #expect(result == expectedResult)
        
        integer = HugeInt("8281")
        result = sqrt(integer)
        expectedResult = HugeFloat("91")
        #expect(result == expectedResult)
        
        integer = HugeInt("24336")
        result = sqrt(integer)
        expectedResult = HugeFloat("156")
        #expect(result == expectedResult)
        
        integer = HugeInt("80")
        result = sqrt(integer)
        expectedResult = HugeFloat("8")
        #expect(result == expectedResult)
        
        integer = HugeInt("0")
        result = sqrt(integer)
        expectedResult = HugeFloat("0")
        #expect(result == expectedResult)
    }
}

// MARK: Exponents
extension HugeIntTests {
    @Test
    func intToThePowerOf() {
        var result = HugeInt("2").squared()
        var expectedResult = HugeInt("4")
        #expect(result == expectedResult)
        
        result = HugeInt("3").cubed()
        expectedResult = HugeInt("27")
        #expect(result == expectedResult)
        
        result = HugeInt("5").toThePowerOf(5)
        expectedResult = HugeInt("3125")
        #expect(result == expectedResult)
    }
}

#endif
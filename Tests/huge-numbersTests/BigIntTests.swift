
import HugeNumbers
import Testing

@Suite
struct BigIntTests {
}

// MARK: addition
extension BigIntTests {
    @Test(
        arguments: [
            (BigInt(0),            BigInt(5),          BigInt(5)),
            (BigInt(-1),           BigInt(-1),         BigInt(-2)),
            (BigInt(255),          BigInt(1),          BigInt(256)),
            (BigInt(UInt64.max),   BigInt(1),          BigInt(storage: [.max, 1], sign: .plus)),
            (BigInt(UInt64.max),   BigInt(UInt64.max), BigInt(storage: [.max, .max], sign: .plus)),
            (BigInt(UInt64.max-1), BigInt(UInt64.max), BigInt(storage: [.max, .max-1], sign: .plus))
        ]
    )
    func bigIntAddition(
        initialValue: BigInt,
        addedValue: BigInt,
        expectedResult: BigInt
    ) {
        var int = initialValue
        int += addedValue

        #expect(
            int.storage == expectedResult.storage && int.sign == expectedResult.sign,
            "initialValue=\(initialValue)\naddedValue=\(addedValue)\nresult=\(int)\nexpectedResult=\(expectedResult)"
        )
    }
}

// MARK: subtraction
extension BigIntTests {
    @Test(
        arguments: [
            (BigInt(0),            BigInt(5),          BigInt(-5)),
            (BigInt(-1),           BigInt(-1),         BigInt(0)),
            (BigInt(255),          BigInt(1),          BigInt(254)),
            (BigInt(UInt64.max),   BigInt(1),          BigInt(UInt64.max-1)),
            (BigInt(UInt64.max),   BigInt(UInt64.max), BigInt(0)),
            (BigInt(UInt64.max-1), BigInt(UInt64.max), BigInt(-1))
        ]
    )
    func bigIntSubtraction(
        initialValue: BigInt,
        subtractedValue: BigInt,
        expectedResult: BigInt
    ) {
        var int = initialValue
        int -= subtractedValue

        #expect(
            int.storage == expectedResult.storage && int.sign == expectedResult.sign,
            "initialValue=\(initialValue)\nsubtractedValue=\(subtractedValue)\nresult=\(int)\nexpectedResult=\(expectedResult)"
        )
    }
}

// MARK: multiplication
extension BigIntTests {
    @Test(
        arguments: [
            (BigInt(0),            BigInt(5),  BigInt(0)),
            (BigInt(-1),           BigInt(-1), BigInt(1)),
            (BigInt(255),          BigInt(1),  BigInt(255)),
            (BigInt(UInt64.max),   BigInt(1),  BigInt(UInt64.max)),
            (BigInt(UInt64.max),   BigInt(2),  BigInt(storage: [.max, .max], sign: .plus))
        ]
    )
    func bigIntMultiplication(
        initialValue: BigInt,
        multipliedValue: BigInt,
        expectedResult: BigInt
    ) {
        var int = initialValue
        int *= multipliedValue

        #expect(
            int.storage == expectedResult.storage && int.sign == expectedResult.sign,
            "initialValue=\(initialValue)\nmultipliedValue=\(multipliedValue)\nresult=\(int)\nexpectedResult=\(expectedResult)"
        )
    }
}

/*
// MARK: string
extension BigIntTests {
    @Test(
        arguments: [
            //(BigInt(0), "0"),
            //(BigInt(256), "256"),
            //(BigInt.init(-256), "-256"),
            //(BigInt.init(UInt64.max), "18446744073709551615"),
            //(BigInt.init(storage: [.max, 1], sign: .plus), "18446744073709551616"),
            (BigInt.init(storage: [.max, .max], sign: .plus), "36893488147419103232"),
        ]
    )
    func bigIntString(
        value: BigInt,
        expectedResult: String
    ) {
        let string = "\(value)"
        #expect(string == expectedResult, "value=\(value)")
    }
}*/
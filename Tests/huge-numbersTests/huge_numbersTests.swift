//
//  huge_numbersTests.swift
//
//
//  Created by Evan Anderson on 4/10/23.
//

import XCTest
@testable import huge_numbers

final class huge_numbersTests: XCTestCase {
    func testExample() async throws {
        //try await test_benchmarks()
        test_int()
        test_float()
        test_remainder()
        test_decimal()
        test_pi()
    }
    
    private func test_benchmarks() async throws {
        guard #available(macOS 13.0, *) else { return }
        let slice:ArraySlice<UInt8> = ArraySlice.init(repeating: 1, count: 1000)
        try await benchmark_compare_is_faster(key1: "ArraySlice.map", {
            slice.map({ $0 })
        }, key2: "Array.init(ArraySlice)", code2: {
            Array(slice)
        })
    }
}

extension huge_numbersTests {
    @available(macOS 13.0, *)
    private func benchmark(key: String, _ code: @escaping () async throws -> Void, will_print: Bool = true) async throws -> (key: String, min: Int64, max: Int64, median: Int64, average: Int64, total: Int64) {
        let iteration_count:Int = 10_00
        let clock:ContinuousClock = ContinuousClock()
        let _:Duration = try await clock.measure(code)
        var timings:[Int64] = [Int64]()
        timings.reserveCapacity(iteration_count)
        for _ in 1...iteration_count {
            let result:Duration = try await clock.measure(code)
            let attoseconds:Int64 = result.components.attoseconds
            let nanoseconds:Int64 = attoseconds / 1_000_000_000
            timings.append(nanoseconds)
        }
        timings = timings.sorted(by: { $0 < $1 })
        let minimum:Int64 = timings.first!, maximum:Int64 = timings.last!
        let median:Int64 = timings[timings.count/2]
        let sum:Int64 = timings.reduce(0, +)
        let average:Int64 = Int64( Double(sum) / Double(timings.count) )
        if will_print {
            let key:String = key + (1...(80-key.count)).map({ _ in " " }).joined()
            
            let formatter:NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 20
            
            let average_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, average)
            let minimum_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, minimum)
            let maximum_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, maximum)
            let median_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, median)
            let total_time_elapsed:String = get_benchmark_formatted_string(formatter: formatter, sum)
            
            print("SwiftSovereignStates;benchmark( " + key + "| min=" + minimum_time_elapsed + " | max=" + maximum_time_elapsed + " | median=" + median_time_elapsed + " | average=" + average_time_elapsed + " | total=" + total_time_elapsed)
        }
        return (key: key, min: minimum, max: maximum, median: median, average: average, total: sum)
    }
    @available(macOS 13.0, *)
    private func benchmark_compare_is_faster(maximum_iterations: Int = 100, key1: String, _ code1: @escaping () async throws -> Void, key2: String, code2: @escaping () async throws -> Void) async throws {
        var faster_count:Int = 0, faster_average:Int64 = 0
        for _ in 1...maximum_iterations {
            let faster:(Bool, Int64) = try await benchmark_compare(key1: key1, code1, key2: key2, code2: code2, print_to_console: false)
            faster_count += faster.0 ? 1 : 0
            faster_average += faster.1
        }
        let formatter:NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 20
        let average_string:String = get_benchmark_formatted_string(formatter: formatter, faster_average / Int64(maximum_iterations))
        print("SwiftSovereignStates;benchmark_compare_is_faster;     " + key1 + " is faster " + faster_count.description + "/" + maximum_iterations.description + " on average by " + average_string)
    }
    @available(macOS 13.0, *)
    private func benchmark_compare(key1: String, _ code1: @escaping () async throws -> Void, key2: String, code2: @escaping () async throws -> Void, print_to_console: Bool = true) async throws -> (Bool, Int64) {
        async let test1 = benchmark(key: key1, code1, will_print: false)
        async let test2 = benchmark(key: key2, code2, will_print: false)
        let ((key1, min1, max1, median1, average1, total1) , (_, min2, max2, median2, average2, total2)) = try await (test1, test2)
        
        if print_to_console {
            let formatter:NumberFormatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 20
            
            let average_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(average1, average2) - min(average1, average2))
            let minimum_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(min1, min2) - min(min1, min2))
            let maximum_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(max1, max2) - min(max1, max2))
            let median_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(median1, median2) - min(median1, median2))
            let total_time_diff:String = get_benchmark_formatted_string(formatter: formatter, max(total1, total2) - min(total1, total2), separation_count: 20)
            
            let key:String = key1 + (1...(70-key1.count)).map({ _ in " " }).joined()
            var string:String = "SwiftSovereignStates;benchmark_compare( " + key + "| "
            string.append("min=" + (min1 < min2 ? "🟢" : "🔴") + "by " + minimum_time_diff)
            string.append(" | max=" + (max1 < max2 ? "🟢" : "🔴") + "by " + maximum_time_diff)
            string.append(" | median=" + (median1 < median2 ? "🟢" : "🔴") + "by " + median_time_diff)
            string.append(" | average=" + (average1 < average2 ? "🟢" : "🔴") + "by " + average_time_diff)
            string.append(" | total=" + (total1 < total2 ? "🟢" : "🔴") + "by " + total_time_diff)
            print(string)
        }
        return (average1 <= average2, average2 - average1)
    }
    private func get_benchmark_formatted_string(formatter: NumberFormatter, _ value: Any, separation_count: Int = 20) -> String {
        let string:String = formatter.string(for: value)! + "ns"
        return string + (0..<(separation_count - (string.count))).map({ _ in " " }).joined()
    }
}

extension huge_numbersTests {
    private func test_int() {
        let integer:HugeInt = HugeInt("1234567891011121314151617181920")
        let second_integer:HugeInt = -integer
        XCTAssert(integer != second_integer)
        XCTAssert(integer == -second_integer)
        XCTAssert(!(integer > integer))
        XCTAssert(!(integer < integer))
        XCTAssert(integer >= integer)
        XCTAssert(integer <= integer)
        
        let eleven:HugeInt = HugeInt("11")
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
        
        test_int_addition()
        test_int_subtraction()
        test_int_multiplication()
        test_int_division()
        test_int_percent()
    }
    private func test_int_addition() {
        var integer:HugeInt = HugeInt("93285729350358025806")
        let second_integer:HugeInt = HugeInt("99999999999239579")
        XCTAssert(integer.adding(second_integer) == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer.adding(HugeInt("-1")) == HugeInt("93385729350357265384"))
        
        integer += 1
        XCTAssert(integer == HugeInt("93385729350357265385"), "test_int_addition;integer=\(integer)")
        XCTAssert(integer+1 == HugeInt("93385729350357265386"), "test_int_addition;integer=\(integer)")
        integer += -1
        XCTAssert(integer == HugeInt("93385729350357265384"), "test_int_addition;integer=\(integer)")
    }
    private func test_int_subtraction() {
        var integer:HugeInt = HugeInt("82372958")
        let second_integer:HugeInt = HugeInt("82372959")
        var result:HugeInt = integer.subtract(second_integer)
        var expected_result:HugeInt = HugeInt("-1")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        XCTAssert(integer.subtract(integer) - 1 == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= 1
        expected_result = HugeInt("-2")
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result -= -2
        expected_result = HugeInt.zero
        XCTAssert(result == expected_result, "test_int_subtraction;result=\(result);expected_result=\(expected_result)")
        
        result = HugeInt("10000") - HugeInt("9045")
        expected_result = HugeInt("955")
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
        var integer:HugeInt = HugeInt("518")
        var number:HugeInt = HugeInt("4")
        var (result, result_remainder):(HugeInt, HugeRemainder?) = integer / number
        XCTAssert(result == HugeInt("129") && result_remainder == HugeRemainder(dividend: "2", divisor: "4"), "test_int_division;result=" + result.description + ";remainder=" + (result_remainder?.description ?? "nil"))
        
        (result, result_remainder) = HugeInt("18") / HugeInt("9")
        XCTAssert(result == HugeInt("2") && result_remainder == nil, "test_int_division;result=" + result.description + ";remainder=" + (result_remainder?.description ?? "nil"))
        
        (result, result_remainder) = HugeInt("36") / HugeInt("7")
        XCTAssert(result == HugeInt("5") && result_remainder == HugeRemainder(dividend: "1", divisor: "7"), "test_int_division;result=" + result.description + ";remainder=" + (result_remainder?.description ?? "nil"))
        
        (result, result_remainder) = HugeInt("3460987") / HugeInt("89345")
        XCTAssert(result == HugeInt("38") && result_remainder == HugeRemainder(dividend: "65877", divisor: "89345"), "test_int_division;result=" + result.description + ";remainder=" + (result_remainder?.description ?? "nil"))
        
        integer = HugeInt("13")
        let remainder:HugeRemainder? = integer /= 6
        XCTAssert(integer == HugeInt("2") && remainder == HugeRemainder(dividend: "1", divisor: "6"))
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
}

extension huge_numbersTests {
    private func test_float() {
        let float:HugeFloat = HugeFloat("3.1415926535e-10")
        XCTAssert(float.literal_description.elementsEqual("0.00000000031415926535"), "test_float;float=\(float), description=" + float.description)
        XCTAssert(float.description_simplified.elementsEqual("3.1415926535e-10"), "test_float;float=\(float), description_simplified=" + float.description_simplified)
        XCTAssert(HugeFloat("3r1/4") == HugeFloat(pre_decimal_number: HugeInt("3"), post_decimal_number: HugeInt.zero, exponent: 0, remainder: HugeRemainder(dividend: "1", divisor: "4")))
        
        test_float_addition()
        test_float_multiplication()
        test_float_division()
    }
    private func test_float_addition() {
        let float:HugeFloat = HugeFloat("3.5")
        var result:HugeFloat = float + 1
        var expected_result:HugeFloat = HugeFloat("4.5")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("1.5")
        expected_result = HugeFloat("5")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("2.7")
        expected_result = HugeFloat("6.2")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("10.16")
        expected_result = HugeFloat("13.66")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
        
        result = float + HugeFloat("196.555")
        expected_result = HugeFloat("200.055")
        XCTAssert(result == expected_result, "test_float_addition;result=\(result);expected_result=\(expected_result)")
    }
    private func test_float_multiplication() {
        var float:HugeFloat = HugeFloat("1.7959")
        var um:Int = 2
        var result:HugeFloat = float * um
        var expected_result:HugeFloat = HugeFloat("3.5918")
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
        
        
        float = HugeFloat("19385436.795909235895")
        um = 9
        result = float * um
        expected_result = HugeFloat("174468931.163183123055")
        XCTAssert(result == expected_result, "test_float_multiplication;result=\(result);expected_result=\(expected_result)")
    }
    private func test_float_division() {
        var float:HugeFloat = HugeFloat("60")
        var result:HugeFloat = float / 90
        var expected_result:HugeFloat = HugeFloat("0r2/3")
        XCTAssert(result == expected_result, "test_float_division;result=\(result.description);expected_result=\(expected_result.description)")
    }
}

extension huge_numbersTests {
    private func test_remainder() {
        test_remainder_addition()
        test_remainder_subtraction()
        test_remainder_multiplication()
    }
    private func test_remainder_addition() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder + HugeRemainder(dividend: "1", divisor: "4")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "6", divisor: "8")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
    }
    private func test_remainder_subtraction() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder - HugeRemainder(dividend: "1", divisor: "4")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "2", divisor: "8")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
        
        result = HugeRemainder(dividend: "5", divisor: "15") - HugeRemainder(dividend: "10", divisor: "15")
        expected_result = HugeRemainder(dividend: "-5", divisor: "15")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
        
        result = HugeRemainder(dividend: "1", divisor: "4") - remainder
        expected_result = HugeRemainder(dividend: "-2", divisor: "8")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "2")
        result = remainder - remainder
        expected_result = HugeRemainder(dividend: "0", divisor: "2")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "5")
        result = remainder - HugeInt("2")
        expected_result = HugeRemainder(dividend: "-9", divisor: "5")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
    }
    private func test_remainder_multiplication() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeRemainder = remainder * HugeRemainder(dividend: "5", divisor: "6")
        var expected_result:HugeRemainder = HugeRemainder(dividend: "5", divisor: "12")
        XCTAssert(result == expected_result, "test_remainder;result=\(result);expected_result=\(expected_result)")
    }
}

extension huge_numbersTests {
    private func test_decimal() {
        var remainder:HugeRemainder = HugeRemainder(dividend: "1", divisor: "2")
        var result:HugeDecimal = remainder.to_decimal()
        var expected_result:HugeDecimal = HugeDecimal("5")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "4")
        result = remainder.to_decimal()
        expected_result = HugeDecimal("25")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "10")
        result = remainder.to_decimal()
        expected_result = HugeDecimal("1")
        XCTAssert(result == expected_result, "test_decimal;result=\(result);expected_result=\(expected_result)")
        
        remainder = HugeRemainder(dividend: "1", divisor: "1005")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt.zero, repeating_numbers: [8, 9, 3, 0, 2, 9, 5, 1, 8, 6, 3, 6, 2, 7, 4, 5, 0, 9, 8, 1, 2, 6, 5, 7, 8, 4, 2, 0, 5, 9, 9, 0, 0])
        XCTAssert(result == expected_result, "test_decimal;result_precision=\(result);expected_result=\(expected_result)")
        XCTAssert(result.description.elementsEqual(expected_result.description), "test_decimal;result.description=" + result.description + ";expected_result.description=" + expected_result.description)
        
        remainder = HugeRemainder(dividend: "1", divisor: "1010")
        result = remainder.to_decimal()
        expected_result = HugeDecimal(value: HugeInt.zero, repeating_numbers: [9, 9, 0, 0])
        XCTAssert(result == expected_result, "test_decimal;result_precision=\(result);expected_result=\(expected_result)")
        XCTAssert(result.description.elementsEqual(expected_result.description), "test_decimal;result.description=" + result.description + ";expected_result.description=" + expected_result.description)
    }
}

extension huge_numbersTests {
    private func test_pi() {
        let pi:HugeFloat = HugeFloat.pi(precision: HugeInt("5"))
        print(pi.description)
    }
}

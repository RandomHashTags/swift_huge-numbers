//
//  HugeRemainder.swift
//  
//
//  Created by Evan Anderson on 4/11/23.
//

import Foundation

public struct HugeRemainder : Hashable, Comparable {
    public private(set) var dividend:HugeInt
    public private(set) var divisor:HugeInt
    
    public init(dividend: HugeInt, divisor: HugeInt) {
        self.dividend = dividend
        self.divisor = divisor
    }
    public init(dividend: String, divisor: String) {
        self.init(dividend: HugeInt(dividend), divisor: HugeInt(divisor))
    }
    
    public var description : String {
        return dividend.description + "/" + divisor.description
    }
}

/*
 Comparable
 */
public extension HugeRemainder {
    static func < (lhs: HugeRemainder, rhs: HugeRemainder) -> Bool { // TODO: fix
        return false
    }
}
public extension HugeRemainder {
    static func == (left: HugeRemainder, right: HugeRemainder) -> Bool {
        return left.dividend == right.dividend && left.divisor == right.divisor
    }
}

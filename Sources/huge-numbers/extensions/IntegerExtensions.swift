//
//  IntegerExtensions.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

extension Int8 {
    @inlinable
    var repeatingSymbol : Character {
        return "\(String.init(describing: self))\u{0305}".first ?? "?"
    }
}

extension BinaryInteger {
    @inlinable
    public func toBinary() -> [Bool] {
        return String.init(self, radix: 2).map({ $0 == "1" })
    }
}

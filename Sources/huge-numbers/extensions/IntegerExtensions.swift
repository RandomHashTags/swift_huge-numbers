//
//  IntegerExtensions.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

internal extension Int8 {
    var repeating_symbol : Character {
        return "\(String(describing: self))\u{0305}".first!
    }
}

public extension BinaryInteger {
    func to_binary() -> [Bool] {
        return String.init(self, radix: 2).map({ $0 == "1" ? true : false })
    }
}

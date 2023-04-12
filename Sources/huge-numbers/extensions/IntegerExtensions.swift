//
//  IntegerExtensions.swift
//  
//
//  Created by Evan Anderson on 4/12/23.
//

import Foundation

internal extension UInt8 {
    var repeating_symbol : Character {
        return "\(String(describing: self))\u{0305}".first!
    }
}

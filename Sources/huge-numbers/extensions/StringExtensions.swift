//
//  StringExtensions.swift
//  
//
//  Created by Evan Anderson on 4/10/23.
//

import Foundation

internal extension StringProtocol where Self : RangeReplaceableCollection {
    mutating func remove_leading_zeros() {
        while first == "0" {
            removeFirst()
        }
    }
    mutating func remove_trailing_zeros() {
        while last == "0" {
            removeLast()
        }
    }
}

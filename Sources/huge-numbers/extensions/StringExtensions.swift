//
//  StringExtensions.swift
//  
//
//  Created by Evan Anderson on 4/10/23.
//

extension StringProtocol where Self: RangeReplaceableCollection {
    @inlinable
    mutating func removeLeadingZeros() {
        var removed = 0
        var index = startIndex
        while index < endIndex, self[index] == "0" {
            removed += 1
            formIndex(after: &index)
        }
        removeFirst(removed)
    }
    @inlinable
    mutating func removeTrailingZeros() {
        while last == "0" {
            removeLast()
        }
    }
}

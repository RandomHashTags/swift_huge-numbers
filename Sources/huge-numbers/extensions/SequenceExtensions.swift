//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

extension Array {
    @inlinable
    func get(_ index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}

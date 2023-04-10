//
//  SequenceExtensions.swift
//
//
//  Created by Evan Anderson on 4/8/23.
//

import Foundation

internal extension Array {
    func get(_ index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}

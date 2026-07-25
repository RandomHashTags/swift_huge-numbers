
extension BigInt {
    public static func + (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy.add(amount: rhs)
        return copy
    }

    public static func += (lhs: inout Self, rhs: Self) {
        lhs.add(amount: rhs)
    }
}

extension BigInt {
    mutating func add(amount: Self) {
        guard sign == amount.sign else {
            _subtract(amount: amount)
            return
        }
        _add(amount: amount)
    }

    mutating func _add(amount: Self) {
        let addedWords = amount.storage.count - storage.count
        if addedWords > 0 {
            for _ in 0..<addedWords {
                storage.append(0)
            }
        }
        for i in amount.storage.indices {
            let previousValue = storage[i]
            let addedValue = amount.storage[i]
            let (result, overflow) = previousValue.addingReportingOverflow(addedValue)
            if overflow {
                let difference = UInt64.max &- previousValue
                storage.append(addedValue &- difference)
                storage[i] = .max
            } else {
                storage[i] = result
            }
        }
    }
}
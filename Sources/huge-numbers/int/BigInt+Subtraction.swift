
extension BigInt {
    public static func - (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy.subtract(amount: rhs)
        return copy
    }

    public static func -= (lhs: inout Self, rhs: Self) {
        lhs.subtract(amount: rhs)
    }
}

extension BigInt {
    mutating func subtract(amount: Self) {
        guard sign == amount.sign else {
            _add(amount: amount)
            return
        }
        _subtract(amount: amount)
    }

    mutating func _subtract(amount: Self) {
        let addedWords = storage.count - amount.storage.count
        if addedWords > 0 {
            storage.append(addingCapacity: addedWords, initializingWith: {
                for _ in 0..<addedWords {
                    $0.append(0)
                }
            })
            sign = .minus
        }
        for i in amount.storage.indices {
            let previousValue = storage[i]
            let subtractedValue = amount.storage[i]
            let (result, overflow) = previousValue.subtractingReportingOverflow(subtractedValue)
            if overflow {
                let difference = subtractedValue &- previousValue
                storage[i] = difference
                if i == 0 {
                    sign = difference > 0 ? .minus : .plus
                }
            } else {
                storage[i] = result
                if i == 0 {
                    sign = result == 0 ? .plus : sign
                }
            }
        }
    }
}
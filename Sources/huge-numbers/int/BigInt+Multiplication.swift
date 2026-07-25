
extension BigInt {
    public static func * (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy.multiply(amount: rhs)
        return copy
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.multiply(amount: rhs)
    }
}

extension BigInt {
    mutating func multiply(amount: Self) {
        if storage[0] == 0 || amount.storage[0] == 0 {
            storage = [0]
            sign = .plus
            return
        }
        if storage[0] == 1 || amount.storage[0] == 1 {
            storage = storage[0] == 1 ? amount.storage : storage
            sign = sign == amount.sign ? .plus : .minus
            return
        }
        _multiply(amount: amount)
    }

    mutating func _multiply(amount: Self) {
        /*let addedWords = max(storage.count, amount.storage.count)-1
        if addedWords > 0 {
            for _ in 0..<addedWords {
                storage.append(.max)
            }
        }*/
        for i in amount.storage.indices {
            let previousValue = storage[i]
            let multiplyValue = amount.storage[i]
            let (result, overflow) = previousValue.multipliedReportingOverflow(by: multiplyValue)
            if overflow {
                storage[i] = .max
            } else {
                storage[i] = result
            }
        }
        sign = sign == amount.sign ? sign : .minus
    }
}
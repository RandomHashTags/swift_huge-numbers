
extension BigFraction {
    public static func * (lhs: Self, rhs: Self) -> Self {
        var copy = lhs
        copy.multiply(amount: rhs)
        return copy
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs.multiply(amount: rhs)
    }
}

extension BigFraction {
    mutating func multiply(amount: Self) {
        numerator *= amount.numerator
        denominator *= amount.denominator
    }
}
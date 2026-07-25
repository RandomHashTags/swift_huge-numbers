
extension BigInt: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.sign == rhs.sign && lhs.storage == rhs.storage
    }
}
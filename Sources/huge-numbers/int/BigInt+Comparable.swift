
extension BigInt: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        guard lhs.sign == rhs.sign else {
            return lhs.sign == .minus
        }
        guard lhs.storage.count == rhs.storage.count else {
            return lhs.storage.count < rhs.storage.count
        }
        return lhs.storage.withUnsafeBufferPointer { l in
            return rhs.storage.withUnsafeBufferPointer { r in
                return l[l.count-1] < r[r.count-1]
            }
        }
    }

    public static func <= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.sign == rhs.sign else {
            return lhs.sign == .minus
        }
        guard lhs.storage.count == rhs.storage.count else {
            return lhs.storage.count <= rhs.storage.count
        }
        return lhs.storage.withUnsafeBufferPointer { l in
            return rhs.storage.withUnsafeBufferPointer { r in
                return l[l.count-1] <= r[r.count-1]
            }
        }
    }
}
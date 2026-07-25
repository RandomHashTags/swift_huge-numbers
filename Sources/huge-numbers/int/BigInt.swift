
public struct BigInt: Sendable {

    package var storage:ContiguousArray<UInt64>
    public package(set) var sign:Sign

    package init(
        storage: ContiguousArray<UInt64>,
        sign: Sign
    ) {
        self.storage = storage
        self.sign = sign
    }
}

// MARK: init
extension BigInt {
    public init() {
        storage = .init()
        sign = .plus
    }

    public init(_ value: UInt64) {
        storage = [UInt64(truncatingIfNeeded: value)]
        sign = .plus
    }

    public init(_ value: Int) {
        if value >= 0 {
            storage = [UInt64(truncatingIfNeeded: value)]
            sign = .plus
        } else {
            storage = [UInt64(truncatingIfNeeded: -value)]
            sign = .minus
        }
    }
}

// MARK: is positive
extension BigInt {
    /// - Complexity: O(1).
    public var isPositive: Bool {
        sign == .plus
    }

    /// - Complexity: O(1).
    public var isNegative: Bool {
        sign == .minus
    }
}

// MARK: is even
extension BigInt {
    /// - Complexity: O(*n*).
    public var isEven: Bool {
        for i in storage.indices {
            if storage[i] & 1 == 1 {
                return false
            }
        }
        return true
    }

    /// - Complexity: O(*n*).
    public var isOdd: Bool {
        !isEven
    }
}

// MARK: Sign
public enum Sign: Sendable {
    case plus
    case minus
}

/*
extension BigInt: CustomStringConvertible {
    public var description: String {
        guard storage.count != 1 else {
            return isNegative ? "-\(storage[0])" : "\(storage[0])"
        }
        let base2String = String(storage[0])
        let halfIndex = base2String.index(base2String.startIndex, offsetBy: base2String.utf8Span.count / 2)

        let leftHalf = base2String[base2String.startIndex..<halfIndex]
        var leftNumber = UInt64.init(leftHalf)!

        let rightHalf = base2String[halfIndex..<base2String.endIndex]
        var rightNumber = UInt64.init(rightHalf)!

        let rightLeadingBitCount = rightNumber.leadingZeroBitCount

        print("leftNumber=\(leftNumber);rightNumber=\(rightNumber)")

        rightNumber += storage[1]

        return (isNegative ? "-\(leftNumber)\(rightNumber)" : "\(leftNumber)\(rightNumber)")
    }
}*/
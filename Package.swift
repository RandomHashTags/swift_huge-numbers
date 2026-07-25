// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "huge-numbers",
    products: [
        .library(
            name: "HugeNumbers",
            targets: ["HugeNumbers"]),
    ],
    targets: [
        .target(
            name: "HugeNumbers",
            dependencies: [],
            path: "./Sources/huge-numbers"
        ),
        .testTarget(
            name: "huge-numbersTests",
            dependencies: ["HugeNumbers"]),
    ]
)

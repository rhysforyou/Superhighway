// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Porygon",
    platforms: [.iOS("13.0"), .watchOS("6.0"), .tvOS("13.0"), .macOS("10.15")],
    products: [
        .library(
            name: "Porygon",
            targets: ["Porygon"]),
    ],
    targets: [
        .target(
            name: "Porygon",
            dependencies: []),
        .testTarget(
            name: "PorygonTests",
            dependencies: ["Porygon"]),
    ]
)

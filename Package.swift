// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Superhighway",
    platforms: [.iOS("13.0"), .watchOS("6.0"), .tvOS("13.0"), .macOS("10.15")],
    products: [
        .library(
            name: "Superhighway",
            targets: ["Superhighway"]),
    ],
    targets: [
        .target(
            name: "Superhighway",
            dependencies: []),
        .testTarget(
            name: "SuperhighwayTests",
            dependencies: ["Superhighway"]),
    ]
)

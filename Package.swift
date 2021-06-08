// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Superhighway",
    platforms: [.iOS(.v13), .watchOS(.v6), .tvOS(.v13), .macOS(.v10_15)],
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
    ],
    swiftLanguageVersions: [.v5]
)

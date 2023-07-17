// swift-tools-version:5.5

import PackageDescription

var package = Package(
  name: "Superhighway",
  platforms: [.iOS(.v15), .watchOS(.v8), .tvOS(.v15), .macOS(.v12)],
  products: [
    .library(
      name: "Superhighway",
      targets: ["Superhighway"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-http-types.git", from: "0.1.0")
  ],
  targets: [
    .target(
      name: "Superhighway",
      dependencies: []
    ),
    .target(
      name: "HTTPTypesSuperhighway",
      dependencies: [
        .product(name: "HTTPTypes", package: "swift-http-types"),
        .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
        "Superhighway"
      ]
    ),
    .testTarget(
      name: "SuperhighwayTests",
      dependencies: ["Superhighway"]
    )
  ],
  swiftLanguageVersions: [.v5]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
  .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.2.0")
)
#endif

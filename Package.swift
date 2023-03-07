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
  targets: [
    .target(
      name: "Superhighway",
      dependencies: []
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
  .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main")
)
#endif

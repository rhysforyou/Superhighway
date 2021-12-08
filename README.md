# Superhighway

[![Build & Test Swift Package](https://github.com/rhysforyou/Superhighway/actions/workflows/swift-package.yml/badge.svg?branch=main)](https://github.com/rhysforyou/Superhighway/actions/workflows/swift-package.yml)
![Swift Package Manager Recommended](https://img.shields.io/badge/SPM-recommended-blue?style=flat-square)
![Supports macOS, iOS, tvOS, watchOS, and Linux](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-blue?style=flat-square)
[![Licensed under the Unlicense](https://img.shields.io/github/license/rhysforyou/Superhighway?color=blue&style=flat-square)](LICENSE)

Superhighway is a networking library heavily inspired by [tiny-networking](https://github.com/objcio/tiny-networking). It defines an `Endpoint` type which encapsulates the relationship between a `URLRequest` and the `Decodable` entity it represents.

## A Simple Example

```swift
struct Repository: Decodable {
    let id: Int64
    let name: String
}

func getRepository(author: String, name: String) -> Endpoint<Repository> {
    return Endpoint(json: .get, url: URL(string: "https://api.github.com/repos/\(author)/\(name)")!)
}

let endpoint = getRepository(author: "rhysforyou", name: "Superhighway")
```

This simply gives us the description of an endpoint, to actually load it, we can pass it to a URLSession:

```swift
do {
    let (repository, _) = try await URLSession.default.data(for: endpoint)
    print("Repository: \(repository)")
} catch {
    print("Error: \(error)")
}
```

If the subscriber is cancelled or deallocated before it finishes, any networking operations will be halted.

## Installing

The recommended way to use Superhighway is through the Swift Package manager. For Xcode projects, simply add this repository to the project's Swift packages list. For projects using a `Package.swift` file, add the following:

```swift
// swift-tools-version:5.5
import PackageDescription

let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/rhysforyou/Superhighway.git", "0.5.0"..<"0.6.0")
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: ["Superhighway"])
    ]
)
```

Other package managers such as CocoaPods and Carthage are officially unsupported, but this entire library is encapsulated in a single `Endpoint.swift` file which can be copied into an existing project and used as-is.

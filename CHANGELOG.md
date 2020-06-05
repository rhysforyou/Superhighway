# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [v0.3.0] - 2020-06-05

- Overhauled Combine integration. `EndpointPublisher` now vends its own `Subscription` type, instead of simply acting as a wrapper for an upstream data task publisher.

## [v0.2.0] - 2020-01-27

### Added

- Add support for Linux
- Add `map` and `flatMap` methods to `Endpoint`

### Changed

- The `URLSessionDataTask` provided by `URLSession`'s `endpointTask` method is is no longer started automatically
- The return value of `endpointTask` is no longer marked as discardable

## [v0.1.0] - 2019-10-11

Initial release of the library

[unreleased]: https://github.com/rhysforyou/Porygon/compare/0.3.0...HEAD
[v0.3.0]: https://github.com/rhysforyou/Porygon/compare/0.2.0...0.3.0
[v0.2.0]: https://github.com/rhysforyou/Porygon/compare/0.1.0...0.2.0
[v0.1.0]: https://github.com/rhysforyou/Porygon/releases/tag/0.1.0

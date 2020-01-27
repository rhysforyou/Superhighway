# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Add support for Linux
- Add `map` and `flatMap` methods to `Endpoint`

### Changed

- The `URLSessionDataTask` provided by `URLSession`'s `endpointTask` method is is no longer started automatically
- The return value of `endpointTask` is no longer marked as discardable

## [v0.1.0] - 2015-10-06

Initial release of the library

[unreleased]: https://github.com/rhysforyou/Porygon/compare/0.1.0...HEAD
[v0.1.0]: https://github.com/rhysforyou/Porygon/releases/tag/0.1.0

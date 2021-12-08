# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.5.0] - 2021-12-08

- Endpoints now use a throwing closure for their `parse` property, instead of one which returns a `Result`
- Added an async `URLSession.data(for:)` method which takes an endpoint and returns a tuple of `(Response, URLResponse)`
- Response mapping methods have been removed  

## [v0.4.0] - 2020-06-15

- Project renamed from Porygon to Superhighway
- Support for arbitrary MIME types for `Accept` and `Content-Type` headers using `ContentType.custom`
- Support using a custom `JSONEncoder` when making requests with a JSON body

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

[v0.4.0]: https://github.com/rhysforyou/Superhighway/compare/0.3.0...0.4.0
[v0.3.0]: https://github.com/rhysforyou/Superhighway/compare/0.2.0...0.3.0
[v0.2.0]: https://github.com/rhysforyou/Superhighway/compare/0.1.0...0.2.0
[v0.1.0]: https://github.com/rhysforyou/Superhighway/releases/tag/0.1.0

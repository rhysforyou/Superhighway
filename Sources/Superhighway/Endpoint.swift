import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Content type used in `Accept` and `Content-Type` HTTP headers
public enum ContentType {
  case text, json, xml
  case custom(String)

  var mimeType: String {
    switch self {
    case .text:
      return "text/plain"
    case .json:
      return "application/json"
    case .xml:
      return "application/xml"
    case .custom(let mimeType):
      return mimeType
    }
  }
}

/// A HTTP Method
public enum HTTPMethod: String {
  /// HTTP `GET`
  case get = "GET"

  /// HTTP `POST`
  case post = "POST"

  /// HTTP `PUT`
  case put = "PUT"

  /// HTTP `PATCH`
  case patch = "PATCH"

  /// HTTP `DELETE`
  case delete = "DELETE"
}

/// Validates that a status code is in the 2XX range, indicating success
public func expected200to300(_ code: Int) -> Bool {
  (200..<300).contains(code)
}

/// Couples a HTTP request together with the logic required to validate and parse its response into a useful
/// value.
///
/// An endpoint describes how to construct a HTTP request, and how to turn the corresponding HTTP
/// response into a useful value. It also provides the ability to validate a HTTP response.
///
/// For the common use case of fetching some JSON from an API and decoding it into some `Decodable`
/// type, it provides convenience methods that do a lot of the heavy lifting for you:
///
/// ```swift
/// struct Person: Decodable {
///   let id: UUID
///   let givenName: String
///   let familyName: String
/// }
///
///
/// let endpoint = Endpoint(
///   decoding: [Person].self,
///   method: .get,
///   url: URL(string: "https://example.com/api/people")!
/// )
///
/// let (people, _) = try await URLSession.shared.response(for: endpoint)
/// ```
public struct Endpoint<Response> {
  /// The underlying `URLRequest` for this endpoint
  public let request: URLRequest

  /// Closure responsible for translating a URL response into the endpoint's `Response` type
  let parse: (Data?, URLResponse?) throws -> Response

  /// This is used to check the status code of a response.
  let expectedStatusCode: (Int) -> Bool

  /// Create a new Endpoint.
  ///
  /// - Parameters:
  ///   - method: the HTTP method
  ///   - url: the endpoint's URL
  ///   - accept: the content type for the `Accept` header
  ///   - contentType: the content type for the `Content-Type` header
  ///   - body: the body of the request.
  ///   - headers: additional headers for the request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails.
  ///   - timeOutInterval: the timeout interval for his request
  ///   - query: query parameters to append to the url
  ///   - parse: this converts a response into an `A`.
  public init(
    _ method: HTTPMethod,
    url: URL,
    accept: ContentType? = nil,
    contentType: ContentType? = nil,
    body: Data? = nil,
    headers: [String: String] = [:],
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    timeOutInterval: TimeInterval = 10,
    query: [String: String] = [:],
    parse: @escaping (Data?, URLResponse?) throws -> Response
  ) {
    var requestURL: URL
    if query.isEmpty {
      requestURL = url
    } else {
      var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
      components.queryItems = components.queryItems ?? []
      components.queryItems!.append(
        contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) }
      )
      requestURL = components.url!
    }
    var request = URLRequest(url: requestURL)
    if let accept {
      request.setValue(accept.mimeType, forHTTPHeaderField: "Accept")
    }
    if let contentType {
      request.setValue(contentType.mimeType, forHTTPHeaderField: "Content-Type")
    }
    for (key, value) in headers {
      request.setValue(value, forHTTPHeaderField: key)
    }
    request.timeoutInterval = timeOutInterval
    request.httpMethod = method.rawValue

    // body *needs* to be the last property that we set, because of this bug: https://bugs.swift.org/browse/SR-6687
    request.httpBody = body

    self.request = request
    self.expectedStatusCode = expectedStatusCode
    self.parse = parse
  }

  /// Creates a new Endpoint from a request
  ///
  /// - Parameters:
  ///   - request: the URL request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails.
  ///   - parse: this converts a response into an `A`.
  public init(
    request: URLRequest,
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    parse: @escaping (Data?, URLResponse?) throws -> Response
  ) {
    self.request = request
    self.expectedStatusCode = expectedStatusCode
    self.parse = parse
  }
}

// MARK: - CustomStringConvertible

extension Endpoint: CustomStringConvertible {
  public var description: String {
    let data = request.httpBody ?? Data()
    return [
      request.httpMethod ?? "GET",
      request.url?.absoluteString ?? "<no url>",
      String(data: data, encoding: .utf8)
    ].compactMap { $0 }.joined(separator: " ")
  }
}

// MARK: - where A == ()

public extension Endpoint where Response == () {
  /// Creates a new endpoint without a parse function.
  ///
  /// - Parameters:
  ///   - method: the HTTP method
  ///   - url: the endpoint's URL
  ///   - accept: the content type for the `Accept` header
  ///   - headers: additional headers for the request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails.
  ///   - query: query parameters to append to the url
  init(
    _ method: HTTPMethod,
    url: URL,
    accept: ContentType? = nil,
    headers: [String: String] = [:],
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    query: [String: String] = [:]
  ) {
    self.init(
      method,
      url: url,
      accept: accept,
      headers: headers,
      expectedStatusCode: expectedStatusCode,
      query: query,
      parse: { _, _ in () }
    )
  }

  /// Creates a new endpoint without a parse function.
  ///
  /// - Parameters:
  ///   - responseType: the type representing the response
  ///   - json: the HTTP method
  ///   - url: the endpoint's URL
  ///   - accept: the content type for the `Accept` header
  ///   - body: the body of the request. This gets encoded using a default `JSONEncoder` instance.
  ///   - headers: additional headers for the request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails.
  ///   - query: query parameters to append to the url
  init(
    decoding responseType: Response.Type,
    method: HTTPMethod,
    url: URL,
    accept: ContentType? = .json,
    body: some Encodable,
    headers: [String: String] = [:],
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    query: [String: String] = [:],
    encoder: JSONEncoder = JSONEncoder()
  ) {
    let body = try! encoder.encode(body)
    self.init(
      method,
      url: url,
      accept: accept,
      contentType: .json,
      body: body,
      headers: headers,
      expectedStatusCode: expectedStatusCode,
      query: query,
      parse: { _, _ in () }
    )
  }
}

// MARK: - where A: Decodable

public extension Endpoint where Response: Decodable {
  /// Creates a new endpoint representing a value to be decoded from a JSON response.
  ///
  /// - Parameters:
  ///   - responseType: the type representing the response
  ///   - method: the HTTP method
  ///   - url: the endpoint's URL
  ///   - accept: the content type for the `Accept` header
  ///   - headers: additional headers for the request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails.
  ///   - query: query parameters to append to the url
  ///   - decoder: the decoder that's used for decoding the response body
  init(
    decoding responseType: Response.Type,
    method: HTTPMethod,
    url: URL,
    accept: ContentType = .json,
    headers: [String: String] = [:],
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    query: [String: String] = [:],
    decoder: JSONDecoder = JSONDecoder()
  ) {
    self.init(
      method,
      url: url,
      accept: accept,
      body: nil,
      headers: headers,
      expectedStatusCode: expectedStatusCode,
      query: query
    ) { data, _ in
      guard let dat = data else { throw NoDataError() }
      return try decoder.decode(Response.self, from: dat)
    }
  }

  /// Creates a new endpoint representing a value to be decoded from a JSON response.
  ///
  /// - Parameters:
  ///   - responseType: the type representing the response
  ///   - method: the HTTP method
  ///   - url: the endpoint's URL
  ///   - accept: the content type for the `Accept` header
  ///   - body: the body of the request
  ///   - headers: additional headers for the request
  ///   - expectedStatusCode: the status code that's expected. If this returns false for a given
  ///     status code, parsing fails
  ///   - query: query parameters to append to the url
  ///   - decoder: the decoder that's used for decoding the response body
  ///   - encoder: The encoder used to encode the request body
  init(
    decoding responseType: Response.Type,
    method: HTTPMethod,
    url: URL,
    accept: ContentType = .json,
    body: (some Encodable)? = nil,
    headers: [String: String] = [:],
    expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
    query: [String: String] = [:],
    decoder: JSONDecoder = JSONDecoder(),
    encoder: JSONEncoder = JSONEncoder()
  ) {
    let bodyData = body.map { try! encoder.encode($0) }
    self.init(
      method,
      url: url,
      accept: accept,
      contentType: .json,
      body: bodyData,
      headers: headers,
      expectedStatusCode: expectedStatusCode,
      query: query
    ) { data, _ in
      guard let dat = data else { throw NoDataError() }
      return try decoder.decode(Response.self, from: dat)
    }
  }
}

/// Signals that a response's data was unexpectedly nil.
public struct NoDataError: Error {
  public init() {}
}

/// An unknown error
public struct UnknownError: Error {
  public init() {}
}

/// Signals that a response's status code was wrong.
public struct WrongStatusCodeError: Error {
  public let statusCode: Int
  public let response: HTTPURLResponse?

  public init(statusCode: Int, response: HTTPURLResponse?) {
    self.statusCode = statusCode
    self.response = response
  }
}

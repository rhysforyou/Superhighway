import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Content type used in `Accept` and `Content-Type` HTTP headers
public enum ContentType: String {
    case json = "application/json"
    case xml = "application/xml"
}

/// The HTTP Method
public enum HTTPMethod: String {
    /// `GET`
    case get = "GET"

    /// `POST`
    case post = "POST"

    /// `PUT`
    case put = "PUT"

    /// `PATCH`
    case patch = "PATCH"

    /// `DELETE`
    case delete = "DELETE"
}

public func expected200to300(_ code: Int) -> Bool {
    return (200..<300).contains(code)
}

/// This describes an endpoint returning `A` values. It contains both a `URLRequest` and a way to parse the response.
public struct Endpoint<Response> {

    /// The request for this endpoint
    let request: URLRequest

    /// This is used to (try to) parse a response into an `A`.
    let parse: (Data?, URLResponse?) -> Result<Response, Error>

    /// This is used to check the status code of a response.
    fileprivate let expectedStatusCode: (Int) -> Bool

    /// Create a new Endpoint.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - contentType: the content type for the `Content-Type` header
    ///   - body: the body of the request.
    ///   - headers: additional headers for the request
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
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
        parse: @escaping (Data?, URLResponse?) -> Result<Response, Error>
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
        if let accept = accept {
            request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
        }
        if let contentType = contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
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
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - parse: this converts a response into an `A`.
    public init(
        request: URLRequest,
        expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
        parse: @escaping (Data?, URLResponse?) -> Result<Response, Error>
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
            String(data: data, encoding: .utf8),
        ].compactMap({ $0 }).joined(separator: " ")
    }
}

// MARK: - where A == ()
extension Endpoint where Response == () {
    /// Creates a new endpoint without a parse function.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - headers: additional headers for the request
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    public init(
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
            parse: { _, _ in
                .success(())
            }
        )
    }

    /// Creates a new endpoint without a parse function.
    ///
    /// - Parameters:
    ///   - json: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - body: the body of the request. This gets encoded using a default `JSONEncoder` instance.
    ///   - headers: additional headers for the request
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    public init<B: Encodable>(
        json method: HTTPMethod,
        url: URL,
        accept: ContentType? = .json,
        body: B,
        headers: [String: String] = [:],
        expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
        query: [String: String] = [:]
    ) {
        let body = try! JSONEncoder().encode(body)
        self.init(
            method,
            url: url,
            accept: accept,
            contentType: .json,
            body: body,
            headers: headers,
            expectedStatusCode: expectedStatusCode,
            query: query,
            parse: { _, _ in
                .success(())
            }
        )
    }
}

// MARK: - where A: Decodable
extension Endpoint where Response: Decodable {
    /// Creates a new endpoint.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - headers: additional headers for the request
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    ///   - decoder: the decoder that's used for decoding `A`s.
    public init(
        json method: HTTPMethod,
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
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(Response.self, from: dat)
            }
        }
    }

    /// Creates a new endpoint.
    ///
    /// - Parameters:
    ///   - method: the HTTP method
    ///   - url: the endpoint's URL
    ///   - accept: the content type for the `Accept` header
    ///   - body: the body of the request. This is encoded using a default encoder.
    ///   - headers: additional headers for the request
    ///   - expectedStatusCode: the status code that's expected. If this returns false for a given status code, parsing fails.
    ///   - query: query parameters to append to the url
    ///   - decoder: the decoder that's used for decoding `A`s.
    public init<B: Encodable>(
        json method: HTTPMethod,
        url: URL,
        accept: ContentType = .json,
        body: B? = nil,
        headers: [String: String] = [:],
        expectedStatusCode: @escaping (Int) -> Bool = expected200to300,
        query: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) {
        let b = body.map { try! JSONEncoder().encode($0) }
        self.init(
            method,
            url: url,
            accept: accept,
            contentType: .json,
            body: b,
            headers: headers,
            expectedStatusCode: expectedStatusCode,
            query: query
        ) { data, _ in
            return Result {
                guard let dat = data else { throw NoDataError() }
                return try decoder.decode(Response.self, from: dat)
            }
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

extension URLSession {
    /// Loads an endpoint by creating (and directly resuming) a data task.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint.
    ///   - onComplete: The completion handler.
    /// - Returns: The data task.
    public func endpointTask<A>(
        _ endpoint: Endpoint<A>,
        onComplete: @escaping (Result<A, Error>) -> Void
    ) -> URLSessionDataTask {
        let r = endpoint.request
        let task = dataTask(
            with: r,
            completionHandler: { data, response, error in
                if let error = error {
                    onComplete(.failure(error))
                    return
                }

                guard let urlResponse = response as? HTTPURLResponse else {
                    onComplete(.failure(UnknownError()))
                    return
                }

                guard endpoint.expectedStatusCode(urlResponse.statusCode) else {
                    onComplete(
                        .failure(
                            WrongStatusCodeError(
                                statusCode: urlResponse.statusCode,
                                response: urlResponse
                            )
                        )
                    )
                    return
                }

                onComplete(endpoint.parse(data, response))
            }
        )
        return task
    }
}

// MARK: - Transforming Responses

public extension Endpoint {
    /// Create a new endpoint which maps the source endpoint's response after parsing it
    ///
    /// - Parameter transform: A closure that transforms a successfully parsed response
    func map<T>(_ transform: @escaping (Response) -> T) -> Endpoint<T> {
        return Endpoint<T>(request: request, expectedStatusCode: expectedStatusCode) {
            [parse] (data, response) -> Result<T, Error> in
            let initialResult = parse(data, response)
            return initialResult.map(transform)
        }
    }

    /// Create a new endpoint which flat maps the source endpoint's response after parsing it
    ///
    /// - Parameter transform: A closure that transforms a successfully parsed response
    func flatMap<T>(_ transform: @escaping (Response) -> Result<T, Error>) -> Endpoint<T> {
        return Endpoint<T>(request: request, expectedStatusCode: expectedStatusCode) {
            [parse] (data, response) -> Result<T, Error> in
            let initialResult = parse(data, response)
            return initialResult.flatMap(transform)
        }
    }
}

// MARK: - Combine Support

#if canImport(Combine)
import Combine

extension URLSession {
    /// A publisher that delivers the results of loading an endpoint.
    public final class EndpointPublisher<Response>: Combine.Publisher {
        public typealias Output = Response
        public typealias Failure = Error

        private let upstream: AnyPublisher<Response, Error>

        public init(endpoint: Endpoint<Response>, session: URLSession = .shared) {
            self.upstream = session.dataTaskPublisher(for: endpoint.request)
                .tryMap { data, response -> Response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw UnknownError()
                    }

                    guard endpoint.expectedStatusCode(httpResponse.statusCode) else {
                        throw WrongStatusCodeError(
                            statusCode: httpResponse.statusCode,
                            response: httpResponse
                        )
                    }

                    return try endpoint.parse(data, httpResponse).get()
                }
                .eraseToAnyPublisher()
        }

        public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream.receive(subscriber: subscriber)
        }
    }

    public func endpointPublisher<Response>(_ endpoint: Endpoint<Response>)
        -> EndpointPublisher<Response>
    {
        return EndpointPublisher(endpoint: endpoint, session: self)
    }
}
#endif

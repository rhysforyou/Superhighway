//
//  File.swift
//  
//
//  Created by Rhys Powell on 8/6/21.
//

import Foundation

extension URLSession {
    /// Loads an endpoint by creating (and directly resuming) a data task.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint
    ///   - onComplete: The completion handler
    /// - Returns: The data task
    public func endpointTask<Response>(
        _ endpoint: Endpoint<Response>,
        onComplete: @escaping (Result<Response, Error>) -> Void
    ) -> URLSessionDataTask {
        let request = endpoint.request
        let task = dataTask(
            with: request,
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

                onComplete(Result.init { try endpoint.parse(data, response) })
            }
        )
        return task
    }

    public func data<Response>(for endpoint: Endpoint<Response>) async throws -> (Response, URLResponse) {
        let request = endpoint.request
        let (data, urlResponse) = try await data(for: request)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw UnknownError()
        }

        guard endpoint.expectedStatusCode(httpResponse.statusCode) else {
            throw WrongStatusCodeError(statusCode: httpResponse.statusCode, response: httpResponse)
        }

        let response = try endpoint.parse(data, urlResponse)

        return (response, urlResponse)
    }
}

// MARK: - Combine Support

#if canImport(Combine)
import Combine

extension URLSession {
    /// A publisher that delivers the results of requesting and parsing an endpoint.
    ///
    /// Upon being subscribed to, this publisher will perform its underlying HTTP request and send the parsed response to its subscriber.
    public final class EndpointPublisher<Response>: Combine.Publisher {
        public typealias Output = Response
        public typealias Failure = Error

        private let endpoint: Endpoint<Response>
        private let session: URLSession

        public init(endpoint: Endpoint<Response>, session: URLSession = .shared) {
            self.endpoint = endpoint
            self.session = session
        }

        public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = Subscription(
                subscriber: subscriber, endpoint: endpoint, session: session)
            subscriber.receive(subscription: subscription)
        }

        private final class Subscription<Response, Subscriber: Combine.Subscriber>: Combine
                .Subscription
        where Subscriber.Input == Response, Subscriber.Failure == Failure {
            private var subscriber: Subscriber?
            private var endpoint: Endpoint<Response>
            private var session: URLSession

            private var task: URLSessionDataTask?

            init(subscriber: Subscriber, endpoint: Endpoint<Response>, session: URLSession) {
                self.subscriber = subscriber
                self.endpoint = endpoint
                self.session = session
            }

            func request(_ demand: Subscribers.Demand) {
                guard demand > 0 else { return }

                let task = session.endpointTask(endpoint) { [subscriber] result in
                    switch result {
                    case .success(let response):
                        _ = subscriber?.receive(response)
                        subscriber?.receive(completion: .finished)
                    case .failure(let error):
                        subscriber?.receive(completion: .failure(error))
                    }
                }

                self.task = task

                task.resume()
            }

            func cancel() {
                task?.cancel()
                subscriber = nil
                task = nil
            }
        }
    }

    /// Creates a Combine `Publisher` representing the `Endpoint`
    ///
    /// - Parameter endpoint: the endpoint from which to creaste a publisher
    /// - Returns: an endpoint publisher
    public func endpointPublisher<Response>(_ endpoint: Endpoint<Response>) -> EndpointPublisher<Response> {
        return EndpointPublisher(endpoint: endpoint, session: self)
    }
}

#endif

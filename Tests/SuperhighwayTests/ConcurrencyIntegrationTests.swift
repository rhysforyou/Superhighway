//
//  ConcurrencyIntegrationTests.swift
//  
//
//  Created by Rhys Powell on 8/9/2022.
//

import XCTest

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import Superhighway

final class ConcurrencyIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        guard URLProtocol.registerClass(HTTPStubURLProtocol.self) else {
            XCTFail("Couldn't register stub URL protocol")
            return
        }
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(HTTPStubURLProtocol.self)
    }

    func testDataTaskAsync() async throws {
        let url = URL(string: "http://www.example.com/example.json")!

        HTTPStubURLProtocol.urls[url] = StubbedResponse(
            response: HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: exampleJSON.data(using: .utf8)!
        )

        let endpoint = Endpoint(decoding: [Person].self, method: .get, url: url)

        let (person, _) = try await URLSession.shared.response(for: endpoint)
        XCTAssertEqual([Person(name: "Alice"), Person(name: "Bob")], person)
    }
}

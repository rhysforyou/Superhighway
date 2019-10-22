#if os(macOS)
import Foundation
import XCTest

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import Porygon

final class CombineIntegrationTasks: XCTestCase {
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
        subscriber = nil
    }

    private var subscriber: Any?

    func testEndpointPublisher() throws {
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

        let endpoint = Endpoint<[Person]>(json: .get, url: url)
        let expectation = self.expectation(description: "Stubbed network call")

        subscriber = URLSession.shared.endpointPublisher(endpoint).sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail(String(describing: error))
                case .finished:
                    expectation.fulfill()
                }
            },
            receiveValue: { payload in
                XCTAssertEqual([Person(name: "Alice"), Person(name: "Bob")], payload)
            }
        )

        wait(for: [expectation], timeout: 1)
    }
}
#endif

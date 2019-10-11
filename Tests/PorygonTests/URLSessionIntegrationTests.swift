import XCTest

@testable import Porygon

final class URLSessionIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(HTTPStubURLProtocol.self)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(HTTPStubURLProtocol.self)
        subscriber = nil
    }

    private var subscriber: Any?

    func testDataTaskRequest() throws {
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

    static var allTests = [
        ("testDataTaskRequest", testDataTaskRequest),
    ]
}

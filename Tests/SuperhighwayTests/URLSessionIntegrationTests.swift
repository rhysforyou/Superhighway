import Foundation
import XCTest

@testable import Superhighway

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class URLSessionIntegrationTests: XCTestCase {
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
        task = nil
    }

    var task: URLSessionDataTask?

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

        let endpoint = Endpoint(decoding: [Person].self, method: .get, url: url)
        let expectation = self.expectation(description: "Stubbed network call")

        task = URLSession.shared.endpointTask(endpoint) { result in
            switch result {
            case .failure(let error):
                XCTFail(String(describing: error))
            case .success(let people):
                XCTAssertEqual([Person(name: "Alice"), Person(name: "Bob")], people)
                expectation.fulfill()
            }
        }

        task!.resume()

        wait(for: [expectation], timeout: 1)
    }

    static var allTests = [
        ("testDataTaskRequest", testDataTaskRequest)
    ]
}

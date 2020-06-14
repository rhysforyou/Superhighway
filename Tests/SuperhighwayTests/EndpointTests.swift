import Foundation
import XCTest

@testable import Superhighway

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class EndpointTests: XCTestCase {
    func testUrlWithoutParams() {
        let url = URL(string: "http://www.example.com/example.json")!
        let endpoint = Endpoint<[String]>(json: .get, url: url)
        XCTAssertEqual(url, endpoint.request.url)
    }

    func testUrlWithParams() {
        let url = URL(string: "http://www.example.com/example.json")!
        let endpoint = Endpoint<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(
            URL(string: "http://www.example.com/example.json?foo=bar%20bar")!,
            endpoint.request.url
        )
    }

    func testUrlAdditionalParams() {
        let url = URL(string: "http://www.example.com/example.json?abc=def")!
        let endpoint = Endpoint<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(
            URL(string: "http://www.example.com/example.json?abc=def&foo=bar%20bar")!,
            endpoint.request.url
        )
    }

    func testResponseMapping() {
        struct Person: Decodable {
            let firstName: String
            let lastName: String
        }

        let jsonData = """
            {
                "firstName": "John",
                "lastName": "Appleseed"
            }
            """.data(using: .utf8)

        let url = URL(string: "http://www.example.com/example.json?abc=def")!
        let endpoint = Endpoint<Person>(json: .get, url: url, query: ["foo": "bar bar"])
        let mappedEndpoint = endpoint.map { "\($0.firstName) \($0.lastName)" }
        XCTAssertEqual(
            try? mappedEndpoint.parse(jsonData, nil).get(),
            .some("John Appleseed"))
    }

    static var allTests = [
        ("testUrlWithoutParams", testUrlWithoutParams),
        ("testUrlWithParams", testUrlWithParams),
        ("testUrlAdditionalParams", testUrlAdditionalParams),
        ("testResponseMapping", testResponseMapping),
    ]
}

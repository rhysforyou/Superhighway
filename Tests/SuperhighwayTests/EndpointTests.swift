import Foundation
import XCTest

@testable import Superhighway

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class EndpointTests: XCTestCase {
  func testUrlWithoutParams() {
    let url = URL(string: "http://www.example.com/example.json")!
    let endpoint = Endpoint(decoding: [String].self, method: .get, url: url)
    XCTAssertEqual(url, endpoint.request.url)
  }

  func testUrlWithParams() {
    let url = URL(string: "http://www.example.com/example.json")!
    let endpoint = Endpoint(decoding: [String].self, method: .get, url: url, query: ["foo": "bar bar"])
    XCTAssertEqual(
      URL(string: "http://www.example.com/example.json?foo=bar%20bar")!,
      endpoint.request.url
    )
  }

  func testUrlAdditionalParams() {
    let url = URL(string: "http://www.example.com/example.json?abc=def")!
    let endpoint = Endpoint(decoding: [String].self, method: .get, url: url, query: ["foo": "bar bar"])
    XCTAssertEqual(
      URL(string: "http://www.example.com/example.json?abc=def&foo=bar%20bar")!,
      endpoint.request.url
    )
  }
}

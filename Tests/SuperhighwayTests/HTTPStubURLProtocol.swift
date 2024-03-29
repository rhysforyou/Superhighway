import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct StubbedResponse {
  let response: HTTPURLResponse
  let data: Data
}

class HTTPStubURLProtocol: URLProtocol {
  static var urls = [URL: StubbedResponse]()

  override class func canInit(with request: URLRequest) -> Bool {
    guard let url = request.url else { return false }
    return urls.keys.contains(url)
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool {
    false
  }

  override func startLoading() {
    guard let client, let url = request.url, let stub = HTTPStubURLProtocol.urls[url]
    else {
      fatalError()
    }

    client.urlProtocol(self, didReceive: stub.response, cacheStoragePolicy: .notAllowed)
    client.urlProtocol(self, didLoad: stub.data)
    client.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

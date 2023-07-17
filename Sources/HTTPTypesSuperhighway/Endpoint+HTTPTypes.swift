import Foundation
import HTTPTypes
import HTTPTypesFoundation
import Superhighway

extension Endpoint {
  init?(request: HTTPRequest, parse: @escaping (Data?, URLResponse?) throws -> Response) {
    guard let urlRequest = URLRequest(httpRequest: request) else { return nil }
    self.init(request: urlRequest, parse: parse)
  }
}

extension Endpoint where Response: Decodable {
  init?(decoding responseType: Response.Type, request: HTTPRequest, decoder: JSONDecoder = JSONDecoder()) {
    guard let urlRequest = URLRequest(httpRequest: request) else { return nil }
        
    self.init(request: urlRequest) { data, _ in
      guard let data else { throw NoDataError() }
      return try decoder.decode(Response.self, from: data)
    }
  }
}

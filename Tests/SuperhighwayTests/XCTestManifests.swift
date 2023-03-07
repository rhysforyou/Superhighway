import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  [
    testCase(EndpointTests.allTests),
    testCase(URLSessionIntegrationTests.allTests)
  ]
}
#endif

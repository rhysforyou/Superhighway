import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(EndpointTests.allTests),
        testCase(URLSessionIntegrationTests.allTests),
    ]
}
#endif

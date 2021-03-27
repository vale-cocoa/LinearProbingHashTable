import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(LinearProbingHashTableTests.allTests),
    ]
}
#endif

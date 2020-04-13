
import XCTest

extension XCTestCase {
    /// Creates an XCTestExpectation and waits for `block` to call `fulfill()`.
    ///
    /// Example usage:
    ///
    /// ```
    /// waitForExpectation { expectation in
    ///     doSomethingInTheBackground {
    ///         expectation.fulfill()
    ///     }
    /// }
    /// ```
    ///
    func waitForExpectation(description: String? = nil,
                            timeout: TimeInterval = Constants.expectationTimeout,
                            _ block: (XCTestExpectation) -> ()) {
        let exp = expectation(description: description ?? "")
        block(exp)
        wait(for: [exp], timeout: timeout)
    }
}

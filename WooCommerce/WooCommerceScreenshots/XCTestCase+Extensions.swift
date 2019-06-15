import XCTest

struct UITestHelpers {

    public static func waitForElementToExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        let timeoutValue = timeout ?? 30
        guard element.waitForExistence(timeout: timeoutValue) else {
            XCTFail("Failed to find \(element) after \(timeoutValue) seconds.")
            return
        }
    }

    public static func waitForElementToNotExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        let notExistsPredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                    object: element)

        let timeoutValue = timeout ?? 30
        guard XCTWaiter().wait(for: [expectation], timeout: timeoutValue) == .completed else {
            XCTFail("\(element) still exists after \(timeoutValue) seconds.")
            return
        }
    }

    public static func elementIsFullyVisibleOnScreen(element: XCUIElement, offsetSize: CGSize = .zero) -> Bool {
        guard element.exists && !element.frame.isEmpty && element.isHittable else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(element.frame)
    }

    /// Scroll an element into view within another element.
    /// scrollView can be a UIScrollView, or anything that subclasses it like UITableView
    ///
    /// TODO: The implementation of this could use work:
    /// - What happens if the element is above the current scroll view position?
    /// - What happens if it's a really long scroll view?
    public static func scrollElementIntoView(element: XCUIElement, within scrollView: XCUIElement, offsetBy xoffset: CGFloat = 0, threshold: Int = 1000) {

        var iteration = 0

        while !elementIsFullyVisibleOnScreen(element: element) && iteration < threshold {
            scrollDown(in: scrollView, by: 100)
            iteration += 1
        }


        if !elementIsFullyVisibleOnScreen(element: element, offsetSize: CGSize(width: 0, height: xoffset)) {
            XCTFail("Unable to scroll element into view")
        }
    }

    public static func scrollElementIntoViewHorizontally(element: XCUIElement, within scrollView: XCUIElement, threshold: Int = 1000) {

        var iteration = 0

        while !elementIsFullyVisibleOnScreen(element: element) && iteration < threshold {
            scrollRight(in: scrollView, by: 100)
            iteration += 1
        }
        
        if !elementIsFullyVisibleOnScreen(element: element, offsetSize: .zero) {
            XCTFail("Unable to scroll element into view")
        }
    }

    private static var screenBottom: XCUICoordinate {
        return XCUIApplication().windows
            .firstMatch
            .coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 1))
    }

    static internal func scrollDown(in view: XCUIElement, by amount: CGFloat) {
        view.scroll(byDeltaX: 0, deltaY: amount)
    }

    static internal func scrollRight(in view: XCUIElement, by amount: CGFloat) {
        view.scroll(byDeltaX: amount * -1, deltaY: 0)
    }
}

extension XCTestCase {

    public func waitForElementToExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        UITestHelpers.waitForElementToExist(element: element, timeout: timeout)
    }

    public func waitForElementToNotExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        UITestHelpers.waitForElementToNotExist(element: element, timeout: timeout)
    }
}

extension XCUIElement {

    func scroll(byDeltaX deltaX: CGFloat, deltaY: CGFloat) {
        let startCoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: self.frame.maxX, dy: 0))
        let destination = startCoordinate.withOffset(CGVector(dx: deltaX, dy: deltaY * -1))

        startCoordinate.press(forDuration: 0.01, thenDragTo: destination)
    }
}

extension XCUIElementQuery {
    
    var lastMatch: XCUIElement? {
        return self.allElementsBoundByIndex.last
    }
}

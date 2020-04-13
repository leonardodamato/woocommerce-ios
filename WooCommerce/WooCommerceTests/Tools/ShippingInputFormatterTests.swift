import XCTest

@testable import WooCommerce

final class ShippingInputFormatterTests: XCTestCase {
    private let formatter = ShippingInputFormatter()

    // MARK: test cases for `isValid(input:)`

    func testEmptyInputIsValid() {
        let input = ""
        XCTAssertTrue(formatter.isValid(input: input))
    }

    func testAlphanumericInputIsNotValid() {
        let input = "678two"
        XCTAssertFalse(formatter.isValid(input: input))
    }

    func testDecimalInputIsValid() {
        let input = "9990.52"
        XCTAssertTrue(formatter.isValid(input: input))
    }

    func testTrailingPointInputIsValid() {
        let input = "9990."
        XCTAssertTrue(formatter.isValid(input: input))
    }

    func testLeadingPointInputIsValid() {
        let input = "."
        XCTAssertTrue(formatter.isValid(input: input))
    }

    func testNumberAndDashesIsValid() {
        let input = "-707--87.2122"
        XCTAssertTrue(formatter.isValid(input: input))
    }

    // MARK: test cases for `format(input:)`

    func testFormattingEmptyInput() {
        let input = ""
        XCTAssertEqual(formatter.format(input: input), "")
    }

    func testFormattingInputWithLeadingZeros() {
        let input = "00123.91"
        XCTAssertEqual(formatter.format(input: input), "123.91")
    }

    func testFormattingInputWithMultipleDecimalSeparator() {
        let input = "00123.91.232.32"
        XCTAssertEqual(formatter.format(input: input), "12391232.32")
    }

    func testFormattingInputWithLeadingZerosFollowedByDecimalPoint() {
        let input = "000.91"
        XCTAssertEqual(formatter.format(input: input), "0.91")
    }

    func testFormattingInputWithEndingDecimalSeparator() {
        let input = "239."
        XCTAssertEqual(formatter.format(input: input), "239.")
    }

    func testFormattingDecimalInput() {
        let input = "0.314"
        XCTAssertEqual(formatter.format(input: input), "0.314")
    }

    func testFormattingIntegerInput() {
        let input = "314200"
        XCTAssertEqual(formatter.format(input: input), "314200")
    }
}

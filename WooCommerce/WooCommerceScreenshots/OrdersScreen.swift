import Foundation
import XCTest

struct OrdersScreen {

    private let app = XCUIApplication()

    @discardableResult
    func start() -> OrdersScreen {
        UITestHelpers.waitForElementToExist(element: app.tabBars.firstMatch)
        app.tabBars.firstMatch.children(matching: .button).allElementsBoundByIndex[1].tap()

        return self
    }

    @discardableResult
    func startSearching() -> OrdersScreen {
        app.buttons["start-searching-button"].tap()
        return self
    }

    @discardableResult
    func stopSearching() -> OrdersScreen {

        guard isSearching else {
            return self
        }

        app.buttons.firstMatch.tap()
        return self
    }

    @discardableResult
    func startFiltering() -> OrdersScreen {
        app.buttons["start-filtering-orders"].tap()
        return self
    }

    @discardableResult
    func stopFiltering() -> OrdersScreen {

        guard app.sheets.firstMatch.exists else {
            return self
        }

        app.sheets.firstMatch
            .buttons.firstMatch
            .tap()

        return self
    }

    private var isSearching: Bool {
        return app.searchFields.firstMatch.exists
    }
}

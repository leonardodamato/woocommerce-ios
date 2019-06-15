import Foundation
import XCTest

struct NotificationsScreen {

    private let app = XCUIApplication()

    @discardableResult
    func start() -> NotificationsScreen {
        UITestHelpers.waitForElementToExist(element: app.tabBars.firstMatch)
        app.tabBars.firstMatch.children(matching: .button).allElementsBoundByIndex[2].tap()

        return self
    }

    @discardableResult
    func switchToOnlyShowingOrders() -> NotificationsScreen {

        app.buttons["filter-notifications-button"].tap()

        app.sheets.firstMatch
            .buttons.allElementsBoundByIndex[1]
            .tap()

        return self
    }

    @discardableResult
    func switchToOnlyShowingReviews() -> NotificationsScreen {

        app.buttons["filter-notifications-button"].tap()

        app.sheets.firstMatch
            .buttons.allElementsBoundByIndex[2]
            .tap()

        return self
    }

    @discardableResult
    func switchToOnlyShowingAll() -> NotificationsScreen {

        app.buttons["filter-notifications-button"].tap()

        app.sheets.firstMatch
            .buttons.allElementsBoundByIndex[0]
            .tap()

        return self
    }
}



import Foundation
import XCTest

struct DashboardScreen {

    private let app = XCUIApplication()

    @discardableResult
    func start() -> DashboardScreen {
        UITestHelpers.waitForElementToExist(element: app.tabBars.firstMatch)
        app.tabBars.firstMatch.children(matching: .button).allElementsBoundByIndex[0].tap()

        return self
    }

    @discardableResult
    func switchTopPerformersToYearView() -> DashboardScreen {

        UITestHelpers.scrollDown(in: app.scrollViews.firstMatch, by: 200)

        let cell = app.cells["year"]
        let collectionView = app.collectionViews["top-performers-tab-picker-bar"]

        UITestHelpers.scrollElementIntoViewHorizontally(element: cell, within: collectionView)
        cell.tap()

        return self
    }

    @discardableResult
    func scrollTopPerformersTableToBottom() -> DashboardScreen {
        let table = app.tables["top-performer-table-year"]
        let lastCell = table.cells
            .allElementsBoundByIndex
            .last!

        UITestHelpers.scrollElementIntoView(element: lastCell, within: app.scrollViews.firstMatch)

        return self
    }
}


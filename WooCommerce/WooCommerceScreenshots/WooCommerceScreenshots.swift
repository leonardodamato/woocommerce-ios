import XCTest

class WooCommerceScreenshots: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        setupSnapshot(app)
        app.launchArguments.append("--UITests")
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    private let username = "nuttystephen.bem8kzmg@mailosaur.io"
    private let password = "0c62e592-4ae2-415e-8e86-0404eabc82da"
    
    private func switchToOrders() {
        waitForElementToExist(element: app.tabBars.firstMatch)
        app.tabBars.firstMatch.children(matching: .button).allElementsBoundByIndex[1].tap()
    }

    func testScreenshots() {

        LogoutFlow().run()
        LoginFlow().run(username: username, password: password)

        let ordersScreen = OrdersScreen().start()
            .startSearching()

        snapshot("order-searching")
        ordersScreen.stopSearching()

        ordersScreen.startFiltering()
        snapshot("order-filtering")
        ordersScreen.stopFiltering()

        screenshotLastOrder()
        screenshotOrder(atIndex: 1)
        screenshotOrder(atIndex: 2)
        screenshotOrder(atIndex: 3)
        screenshotOrder(atIndex: 0)

        DashboardScreen().start()
            .switchTopPerformersToYearView()
            .scrollTopPerformersTableToBottom()

        snapshot("07-stats")

        let notificationsScreen = NotificationsScreen().start()
        snapshot("03-notifications")

        notificationsScreen.switchToOnlyShowingOrders()
        snapshot("notifications-orders")

        notificationsScreen.switchToOnlyShowingReviews()
        snapshot("notifications-reviews")

        if let productReviewCell = app.tables.firstMatch.cells.lastMatch {
            productReviewCell.tap()
            snapshot("03-product-review")
        }
    }

    private func screenshotLastOrder() {
        self.switchToOrders()
        snapshot("01-orders-list")
        app.cells.lastMatch?.tap()
        snapshot("02-single-order")

        let table = app.tables["order-details-table"]
        let lastCell = table.cells
            .allElementsBoundByIndex
            .last!

        UITestHelpers.scrollElementIntoView(element: lastCell, within: table)
        snapshot("02b-order-details")
    }

    private func screenshotOrder(atIndex index: Int) {
        self.switchToOrders()
        app.cells.allElementsBoundByIndex[index].tap()
        snapshot("single-order-\(index)")

        let table = app.tables["order-details-table"]
        let lastCell = table.cells
            .allElementsBoundByIndex
            .last!

        UITestHelpers.scrollElementIntoView(element: lastCell, within: table)
        snapshot("order-details-\(index)")
    }
}

class TestingFlow {
    internal let app = XCUIApplication()

    internal func run() {
        assertionFailure("You must override the `run` method of a testing flow")
    }
}

class LoginFlow: TestingFlow {

    var isDisplayingLoginEpilogue: Bool {
        return app.buttons["pick-store-button"].exists
    }

    func run(username: String, password: String) {

        /// If a test fails during login, it may leave the device stuck at the login epilogue.
        /// If that's happened, just tap confirm and continue the test run.
        guard !isDisplayingLoginEpilogue else {
            confirmLoginEpilogue()
            return
        }

        tapLoginWithJetpack()
        enterUsernameAndContinue(username: username)
        tapEnterPasswordButton()
        enterPasswordAndContinue(password: password)
        confirmLoginEpilogue()
    }

    private func tapLoginWithJetpack() {
        let loginWithJetpackButton = app.buttons["login-with-jetpack-button"]
        UITestHelpers.waitForElementToExist(element: loginWithJetpackButton)
        loginWithJetpackButton.tap()
    }

    private func enterUsernameAndContinue(username: String) {

        let loginEmailAddressTextField = app.textFields["Login Email Address"]

        UITestHelpers.waitForElementToExist(element: loginEmailAddressTextField)

        loginEmailAddressTextField.tap()
        loginEmailAddressTextField.typeText(username)

        app.buttons["Login Email Next Button"].tap()
    }

    private func tapEnterPasswordButton() {
        let usePasswordButton = app.buttons["Use Password"]
        UITestHelpers.waitForElementToExist(element: usePasswordButton)
        usePasswordButton.tap()
    }

    private func enterPasswordAndContinue(password: String) {
        let passwordTextField = app.secureTextFields["Password"]
        UITestHelpers.waitForElementToExist(element: passwordTextField)
        passwordTextField.tap()
        passwordTextField.typeText(password)

        app.buttons["Password Next Button"].tap()
    }

    private func confirmLoginEpilogue() {
        let confirmButton = app.buttons["pick-store-button"]
        UITestHelpers.waitForElementToExist(element: confirmButton)
        confirmButton.tap()
    }
}

class LogoutFlow: TestingFlow {

    private var isCurrentlyLoggedIn: Bool {
        UITestHelpers.waitForElementToExist(element: app.windows.firstMatch)
        return app.tabBars.firstMatch.exists
    }

    override func run() {
        guard isCurrentlyLoggedIn else { return }
        switchToDashboardTab()
        tapSettingsButton()
        tapLogoutCell()
        confirmLogout()

        if isCurrentlyLoggedIn {
            tapLogoutCell()
            confirmLogout(tryOtherButton: true)
        }
    }

    private func switchToDashboardTab() {
        app.tabBars.firstMatch
            .children(matching: .button)
            .firstMatch
            .tap()
    }

    private func tapSettingsButton() {
        app.navigationBars.firstMatch
            .children(matching: .button)
            .firstMatch
            .tap()
    }

    private func tapLogoutCell() {
        let logoutButton = app.tables.cells["logout-button"]
        UITestHelpers.scrollElementIntoView(element: logoutButton, within: app.tables.firstMatch)
        logoutButton.tap()
    }

    private func confirmLogout(tryOtherButton: Bool = false) {

        if tryOtherButton {
            app.alerts.buttons.lastMatch?.tap()
        }
        else {
            app.alerts.buttons.firstMatch.tap()
        }
    }
}

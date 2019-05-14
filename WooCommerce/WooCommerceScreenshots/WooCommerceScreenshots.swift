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

    private func switchToNotifications() {
        waitForElementToExist(element: app.tabBars.firstMatch)
        app.tabBars.firstMatch.children(matching: .button).allElementsBoundByIndex[2].tap()
    }

    func testScreenshots() {

        LogoutFlow().run()
        LoginFlow().run(username: username, password: password)

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

        switchToNotifications()
        snapshot("03-notifications")
        
        if let productReviewCell = app.tables.firstMatch.cells.lastMatch {
            productReviewCell.tap()
            snapshot("03-product-review")
        }
    }
}

class NotificationsActions {

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
        app.tables.cells["logout-button"].tap()
    }

    private func confirmLogout() {
        app.alerts.buttons.allElementsBoundByIndex.last?.tap()
    }
}

import XCTest
@testable import Yosemite
@testable import Networking
@testable import Storage


/// ProductStore Unit Tests with different sort orders
///
final class ProductStore_ProductsSortOrderTests: XCTestCase {

    /// Mockup Dispatcher!
    ///
    private var dispatcher: Dispatcher!

    /// Mockup Storage: InMemory
    ///
    private var storageManager: MockupStorageManager!

    /// Mockup Network: Allows us to inject predefined responses!
    ///
    private var network: MockupNetwork!

    /// Testing SiteID
    ///
    private let sampleSiteID: Int64 = 123

    /// Testing Page Number
    ///
    private let defaultPageNumber = 1

    /// Testing Page Size
    ///
    private let defaultPageSize = 75

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        dispatcher = Dispatcher()
        storageManager = MockupStorageManager()
        network = MockupNetwork()
    }

    // MARK: - ProductAction.synchronizeProducts

    func testSynchronizingProductsWithAscendingNameSortOrder() {
        let expectation = self.expectation(description: "Retrieve product list")
        let productStore = ProductStore(dispatcher: dispatcher, storageManager: storageManager, network: network)

        let action = ProductAction.synchronizeProducts(siteID: sampleSiteID,
                                                       pageNumber: defaultPageNumber,
                                                       pageSize: defaultPageSize,
                                                       sortOrder: .nameAscending) { [weak self] error in
                                                        guard let self = self else {
                                                            XCTFail()
                                                            return
                                                        }
                                                        self.assertSortOrderParamValues(orderByValue: "title", orderValue: "asc")

                                                        expectation.fulfill()
        }

        productStore.onAction(action)
        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func testSynchronizingProductsWithDescendingNameSortOrder() {
        let expectation = self.expectation(description: "Retrieve product list")
        let productStore = ProductStore(dispatcher: dispatcher, storageManager: storageManager, network: network)

        let action = ProductAction.synchronizeProducts(siteID: sampleSiteID,
                                                       pageNumber: defaultPageNumber,
                                                       pageSize: defaultPageSize,
                                                       sortOrder: .nameDescending) { [weak self] error in
                                                        guard let self = self else {
                                                            XCTFail()
                                                            return
                                                        }
                                                        self.assertSortOrderParamValues(orderByValue: "title", orderValue: "desc")

                                                        expectation.fulfill()
        }

        productStore.onAction(action)
        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func testSynchronizingProductsWithAscendingDateSortOrder() {
        let expectation = self.expectation(description: "Retrieve product list")
        let productStore = ProductStore(dispatcher: dispatcher, storageManager: storageManager, network: network)

        let action = ProductAction.synchronizeProducts(siteID: sampleSiteID,
                                                       pageNumber: defaultPageNumber,
                                                       pageSize: defaultPageSize,
                                                       sortOrder: .dateAscending) { [weak self] error in
                                                        guard let self = self else {
                                                            XCTFail()
                                                            return
                                                        }
                                                        self.assertSortOrderParamValues(orderByValue: "date", orderValue: "asc")

                                                        expectation.fulfill()
        }

        productStore.onAction(action)
        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }

    func testSynchronizingProductsWithDescendingDateSortOrder() {
        let expectation = self.expectation(description: "Retrieve product list")
        let productStore = ProductStore(dispatcher: dispatcher, storageManager: storageManager, network: network)

        let action = ProductAction.synchronizeProducts(siteID: sampleSiteID,
                                                       pageNumber: defaultPageNumber,
                                                       pageSize: defaultPageSize,
                                                       sortOrder: .dateDescending) { [weak self] error in
                                                        guard let self = self else {
                                                            XCTFail()
                                                            return
                                                        }
                                                        self.assertSortOrderParamValues(orderByValue: "date", orderValue: "desc")

                                                        expectation.fulfill()
        }

        productStore.onAction(action)
        wait(for: [expectation], timeout: Constants.expectationTimeout)
    }
}

private extension ProductStore_ProductsSortOrderTests {
    func assertSortOrderParamValues(orderByValue: String, orderValue: String) {
        guard let request = network.requestsForResponseData.first,
            let urlRequest = try? request.asURLRequest(),
            let url = urlRequest.url,
            self.network.requestsForResponseData.count == 1 else {
                XCTFail()
                return
        }
        guard let urlComponents = URLComponents(string: url.absoluteString) else {
            XCTFail()
            return
        }
        let parameters = urlComponents.queryItems

        guard let path = parameters?.first(where: { $0.name == "path" })?.value else {
            XCTFail()
            return
        }

        let pathComponents = path.components(separatedBy: "&")

        let expectedOrderbyParam = "orderby=\(orderByValue)"
        XCTAssertTrue(pathComponents.contains(expectedOrderbyParam), "Expected to have param: \(expectedOrderbyParam)")

        let expectedOrderParam = "order=\(orderValue)"
        XCTAssertTrue(pathComponents.contains(expectedOrderParam), "Expected to have param: \(expectedOrderParam)")
    }
}

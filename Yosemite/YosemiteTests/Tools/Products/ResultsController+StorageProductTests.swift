import XCTest
import Storage
import CoreData
@testable import Yosemite

final class ResultsController_StorageProductTests: XCTestCase {
    /// InMemory Storage!
    ///
    private var storageManager: MockupStorageManager!

    private let sampleSiteID: Int64 = 134

    private lazy var sampleProductsPredicate = NSPredicate(format: "siteID == %lld", sampleSiteID)

    // MARK: - Overridden Methods

    override func setUp() {
        super.setUp()
        storageManager = MockupStorageManager()
    }

    // MARK: tests for `init` with a `ProductsSortOrder` param

    func testProductResultsControllerInitWithAscendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "Zap")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerInitWithDescendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "zap!")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerInitWithAscendingDateSortOrder() {
        // Arrange
        // Friday, March 27, 2020 9:47:09 AM GMT
        let earlierDate = Date(timeIntervalSince1970: 1585302429)
        // Saturday, June 27, 2020 9:47:09 AM GMT
        let laterDate = Date(timeIntervalSince1970: 1593251229)

        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateCreated: laterDate, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateCreated: earlierDate, name: "zap!")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .dateAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerInitWithDescendingDateSortOrder() {
        // Arrange
        // Friday, March 27, 2020 9:47:09 AM GMT
        let earlierDate = Date(timeIntervalSince1970: 1585302429)
        // Saturday, June 27, 2020 9:47:09 AM GMT
        let laterDate = Date(timeIntervalSince1970: 1593251229)

        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateCreated: earlierDate, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateCreated: laterDate, name: "zap!")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        // Act
        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .dateDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    // MARK: tests for `updateSortOrder` with a `ProductsSortOrder` param

    func testProductResultsControllerUpdateWithAscendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "woo")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.nameAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerUpdateWithDescendingNameSortOrder() {
        // Arrange
        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, name: "Zap")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.nameDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product1, product2])
    }

    func testProductResultsControllerUpdateWithAscendingDateSortOrder() {
        // Arrange
        // Friday, March 27, 2020 9:47:09 AM GMT
        let earlierDate = Date(timeIntervalSince1970: 1585302429)
        // Saturday, June 27, 2020 9:47:09 AM GMT
        let laterDate = Date(timeIntervalSince1970: 1593251229)

        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateCreated: laterDate, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product1)


        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateCreated: earlierDate, name: "woo")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameDescending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.dateAscending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }

    func testProductResultsControllerUpdateWithDescendingDateSortOrder() {
        // Arrange
        // Friday, March 27, 2020 9:47:09 AM GMT
        let earlierDate = Date(timeIntervalSince1970: 1585302429)
        // Saturday, June 27, 2020 9:47:09 AM GMT
        let laterDate = Date(timeIntervalSince1970: 1593251229)

        let product1 = MockProduct().product(siteID: sampleSiteID, productID: 1, dateCreated: earlierDate, name: "Zap")
        storageManager.insertSampleProduct(readOnlyProduct: product1)

        let product2 = MockProduct().product(siteID: sampleSiteID, productID: 2, dateCreated: laterDate, name: "fun house")
        storageManager.insertSampleProduct(readOnlyProduct: product2)

        let resultsController = ResultsController<StorageProduct>(storageManager: storageManager,
                                                                  matching: sampleProductsPredicate,
                                                                  sortOrder: .nameAscending)
        try? resultsController.performFetch()

        // Act
        resultsController.updateSortOrder(.dateDescending)
        try? resultsController.performFetch()

        // Assert
        XCTAssertEqual(resultsController.fetchedObjects.count, 2)
        XCTAssertEqual(resultsController.fetchedObjects, [product2, product1])
    }
}

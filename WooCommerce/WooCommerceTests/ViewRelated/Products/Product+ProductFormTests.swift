import XCTest

@testable import WooCommerce
import Yosemite

class Product_ProductFormTests: XCTestCase {

    private let sampleSiteID: Int64 = 109

    func testTrimmedFullDescriptionWithLeadingNewLinesAndHTMLTags() {
        let description = "\n\n\n  <p>This is the party room!</p>\n"
        let product = sampleProduct(description: description)
        let expectedDescription = "This is the party room!"
        XCTAssertEqual(product.trimmedFullDescription, expectedDescription)
    }

    func testTrimmedBriefDescriptionWithLeadingNewLinesAndHTMLTags() {
        let description = "\n\n\n  <p>This is the party room!</p>\n"
        let product = sampleProduct(briefDescription: description)
        let expectedDescription = "This is the party room!"
        XCTAssertEqual(product.trimmedBriefDescription, expectedDescription)
    }

    func testNoCategoryDescriptionOutputsNilDescription() {
        let product = sampleProduct(categories: [])
        XCTAssertNil(product.categoriesDescription())
    }

    func testSingleCategoryDescriptionOutputsSingleCategory() {
        let category = sampleCategory(name: "Pants")
        let product = sampleProduct(categories: [category])
        let expectedDescription = "Pants"
        XCTAssertEqual(product.categoriesDescription(), expectedDescription)
    }

    func testMutipleCategoriesDescriptionOutputsFormattedList() {
        let categories = ["Pants", "Dress", "Shoes"].map { sampleCategory(name: $0) }
        let product = sampleProduct(categories: categories)
        let expectedDescription: String = {
            if #available(iOS 13.0, *) {
                return "Pants, Dress, and Shoes"
            } else {
                return "Pants, Dress, Shoes"
            }
        }()
        let usLocale = Locale(identifier: "en_US")
        XCTAssertEqual(product.categoriesDescription(using: usLocale), expectedDescription)
    }
}

private extension Product_ProductFormTests {

    func sampleCategory(name: String = "") -> ProductCategory {
        return ProductCategory(categoryID: Int64.random(in: 0 ..< Int64.max),
                               siteID: sampleSiteID,
                               parentID: 0,
                               name: name,
                               slug: "")
    }

    func sampleProduct(description: String? = "", briefDescription: String? = "", categories: [ProductCategory] = []) -> Product {
        return Product(siteID: sampleSiteID,
                       productID: 177,
                       name: "Book the Green Room",
                       slug: "book-the-green-room",
                       permalink: "https://example.com/product/book-the-green-room/",
                       dateCreated: Date(),
                       dateModified: Date(),
                       dateOnSaleStart: date(with: "2019-10-15T21:30:00"),
                       dateOnSaleEnd: date(with: "2019-10-27T21:29:59"),
                       productTypeKey: "booking",
                       statusKey: "publish",
                       featured: false,
                       catalogVisibilityKey: "visible",
                       fullDescription: description,
                       briefDescription: briefDescription,
                       sku: "",
                       price: "0",
                       regularPrice: "",
                       salePrice: "",
                       onSale: false,
                       purchasable: true,
                       totalSales: 0,
                       virtual: true,
                       downloadable: false,
                       downloads: [],
                       downloadLimit: -1,
                       downloadExpiry: -1,
                       externalURL: "http://somewhere.com",
                       taxStatusKey: "taxable",
                       taxClass: "",
                       manageStock: false,
                       stockQuantity: nil,
                       stockStatusKey: "instock",
                       backordersKey: "no",
                       backordersAllowed: false,
                       backordered: false,
                       soldIndividually: true,
                       weight: "213",
                       dimensions: ProductDimensions(length: "", width: "", height: ""),
                       shippingRequired: false,
                       shippingTaxable: false,
                       shippingClass: "",
                       shippingClassID: 0,
                       productShippingClass: nil,
                       reviewsAllowed: true,
                       averageRating: "4.30",
                       ratingCount: 23,
                       relatedIDs: [31, 22, 369, 414, 56],
                       upsellIDs: [99, 1234566],
                       crossSellIDs: [1234, 234234, 3],
                       parentID: 0,
                       purchaseNote: "Thank you!",
                       categories: categories,
                       tags: [],
                       images: [],
                       attributes: [],
                       defaultAttributes: [],
                       variations: [192, 194, 193],
                       groupedProducts: [],
                       menuOrder: 0)
    }

    private func date(with dateString: String) -> Date {
        guard let date = DateFormatter.Defaults.dateTimeFormatter.date(from: dateString) else {
            return Date()
        }
        return date
    }
}

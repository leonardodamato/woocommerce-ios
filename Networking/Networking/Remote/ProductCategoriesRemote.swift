import Foundation

/// Product Categories: Remote Endpoints
///
public final class ProductCategoriesRemote: Remote {

    // MARK: - Product Categories

    /// Retrieves all of the `ProducCategory` available. We rely on the endpoint
    /// defaults for `context`, ` sorting` and `orderby`: `date_gmt` and `asc`
    ///
    /// - Parameters:
    ///     - siteID: Site for which we'll fetch remote products categories.
    ///     - pageNumber: Number of page that should be retrieved.
    ///     - pageSize: Number of categories to be retrieved per page.
    ///     - completion: Closure to be executed upon completion.
    ///
    public func loadAllProductCategories(for siteID: Int64,
                                         pageNumber: Int = Default.pageNumber,
                                         pageSize: Int = Default.pageSize,
                                         completion: @escaping ([ProductCategory]?, Error?) -> Void) {
        let parameters = [
            ParameterKey.page: String(pageNumber),
            ParameterKey.perPage: String(pageSize)
        ]

        let path = Path.categories
        let request = JetpackRequest(wooApiVersion: .mark3, method: .get, siteID: siteID, path: path, parameters: parameters)
        let mapper = ProductCategoryListMapper(siteID: siteID)

        enqueue(request, mapper: mapper, completion: completion)
    }
}


// MARK: - Constants
//
public extension ProductCategoriesRemote {
    enum Default {
        public static let pageSize: Int = 25
        public static let pageNumber: Int = 1
    }

    private enum Path {
        static let categories = "products/categories"
    }

    private enum ParameterKey {
        static let page: String = "page"
        static let perPage: String = "per_page"
    }
}

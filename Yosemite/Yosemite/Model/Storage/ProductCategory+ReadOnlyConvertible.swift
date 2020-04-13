import Foundation
import Storage


// MARK: - Storage.ProductCategory: ReadOnlyConvertible
//
extension Storage.ProductCategory: ReadOnlyConvertible {

    /// Updates the Storage.ProductCategory with the ReadOnly.
    ///
    public func update(with category: Yosemite.ProductCategory) {
        categoryID = category.categoryID
        siteID = category.siteID
        parentID = category.parentID
        name = category.name
        slug = category.slug
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> Yosemite.ProductCategory {
        return ProductCategory(categoryID: categoryID,
                               siteID: siteID,
                               parentID: parentID,
                               name: name,
                               slug: slug)
    }
}

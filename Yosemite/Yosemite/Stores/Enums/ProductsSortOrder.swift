import Networking

/// How products are sorted in a product list.
///
public enum ProductsSortOrder {
    // From the newest to the oldest
    case dateDescending
    // From the oldest to the newest
    case dateAscending
    // Product name from Z to A
    case nameDescending
    // Product name from A to Z
    case nameAscending
}

// MARK: ProductsRemote
//
extension ProductsSortOrder {
    var remoteOrderKey: ProductsRemote.OrderKey {
        switch self {
        case .dateAscending, .dateDescending:
            return .date
        case .nameAscending, .nameDescending:
            return .name
        }
    }

    var remoteOrder: ProductsRemote.Order {
        switch self {
        case .dateAscending, .nameAscending:
            return .ascending
        case .dateDescending, .nameDescending:
            return .descending
        }
    }
}

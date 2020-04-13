@testable import WooCommerce

struct MockFeatureFlagService: FeatureFlagService {
    private let isProductListFeatureOn: Bool
    private let isEditProductsRelease2On: Bool
    private let isEditProductsRelease3On: Bool

    init(isProductListFeatureOn: Bool = true,
         isEditProductsRelease2On: Bool = false,
         isEditProductsRelease3On: Bool = false) {
        self.isProductListFeatureOn = isProductListFeatureOn
        self.isEditProductsRelease2On = isEditProductsRelease2On
        self.isEditProductsRelease3On = isEditProductsRelease3On
    }

    func isFeatureFlagEnabled(_ featureFlag: FeatureFlag) -> Bool {
        switch featureFlag {
        case .productList:
            return isProductListFeatureOn
        case .editProductsRelease2:
            return isEditProductsRelease2On
        case .editProductsRelease3:
            return isEditProductsRelease3On
        default:
            return false
        }
    }
}

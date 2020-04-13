import UIKit
import Yosemite

/// The Product form contains 2 sections: primary fields, and details.
struct DefaultProductFormTableViewModel: ProductFormTableViewModel {

    private(set) var sections: [ProductFormSection] = []
    private let currency: String
    private let currencyFormatter: CurrencyFormatter

    // Timezone of the website
    //
    var siteTimezone: TimeZone = TimeZone.siteTimezone

    private let isEditProductsRelease2Enabled: Bool
    private let isEditProductsRelease3Enabled: Bool

    init(product: Product,
         currency: String,
         currencyFormatter: CurrencyFormatter = CurrencyFormatter(),
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService) {
        self.currency = currency
        self.currencyFormatter = currencyFormatter
        self.isEditProductsRelease2Enabled = featureFlagService.isFeatureFlagEnabled(.editProductsRelease2)
        self.isEditProductsRelease3Enabled = featureFlagService.isFeatureFlagEnabled(.editProductsRelease3)
        configureSections(product: product)
    }
}

private extension DefaultProductFormTableViewModel {
    mutating func configureSections(product: Product) {
        sections = [.primaryFields(rows: primaryFieldRows(product: product)),
                    .settings(rows: settingsRows(product: product))]
    }

    func primaryFieldRows(product: Product) -> [ProductFormSection.PrimaryFieldRow] {
        guard isEditProductsRelease2Enabled || product.images.isEmpty == false else {
            return [
                .name(name: product.name),
                .description(description: product.trimmedFullDescription)
            ]
        }

        return [
            .images(product: product),
            .name(name: product.name),
            .description(description: product.trimmedFullDescription)
        ]
    }

    func settingsRows(product: Product) -> [ProductFormSection.SettingsRow] {
        let shouldShowShippingSettingsRow = product.downloadable == false && product.virtual == false
        let shouldShowBriefDescriptionRow = isEditProductsRelease2Enabled
        let shouldShowCategoriesRow = isEditProductsRelease3Enabled

        let rows: [ProductFormSection.SettingsRow?] = [
            .price(viewModel: priceSettingsRow(product: product)),
            shouldShowShippingSettingsRow ? .shipping(viewModel: shippingSettingsRow(product: product)): nil,
            .inventory(viewModel: inventorySettingsRow(product: product)),
            shouldShowCategoriesRow ? .categories(viewModel: categoriesRow(product: product)): nil,
            shouldShowBriefDescriptionRow ? .briefDescription(viewModel: briefDescriptionRow(product: product)): nil
        ]

        return rows.compactMap { $0 }
    }
}

private extension DefaultProductFormTableViewModel {
    func priceSettingsRow(product: Product) -> ProductFormSection.SettingsRow.ViewModel {
        let icon = UIImage.priceImage
        let title = Constants.priceSettingsTitle

        var priceDetails = [String]()

        // Regular price and sale price are both available only when a sale price is set.
        if let regularPrice = product.regularPrice, regularPrice.isNotEmpty {
            let formattedRegularPrice = currencyFormatter.formatAmount(regularPrice, with: currency) ?? ""
            priceDetails.append(String.localizedStringWithFormat(Constants.regularPriceFormat, formattedRegularPrice))

            if let salePrice = product.salePrice, salePrice.isNotEmpty {
                let formattedSalePrice = currencyFormatter.formatAmount(salePrice, with: currency) ?? ""
                priceDetails.append(String.localizedStringWithFormat(Constants.salePriceFormat, formattedSalePrice))
            }

            if let dateOnSaleStart = product.dateOnSaleStart, let dateOnSaleEnd = product.dateOnSaleEnd {
                let dateIntervalFormatter = DateIntervalFormatter.mediumLengthLocalizedDateIntervalFormatter
                dateIntervalFormatter.timeZone = siteTimezone
                let formattedTimeRange = dateIntervalFormatter.string(from: dateOnSaleStart, to: dateOnSaleEnd)
                priceDetails.append(String.localizedStringWithFormat(Constants.saleDatesFormat, formattedTimeRange))
            }
            else if let dateOnSaleStart = product.dateOnSaleStart, product.dateOnSaleEnd == nil {
                let dateFormatter = DateFormatter.mediumLengthLocalizedDateFormatter
                dateFormatter.timeZone = siteTimezone
                let formattedDate = dateFormatter.string(from: dateOnSaleStart)
                priceDetails.append(String.localizedStringWithFormat(Constants.saleDateFormatFrom, formattedDate))
            }
            else if let dateOnSaleEnd = product.dateOnSaleEnd, product.dateOnSaleStart == nil {
                let dateFormatter = DateFormatter.mediumLengthLocalizedDateFormatter
                dateFormatter.timeZone = siteTimezone
                let formattedDate = dateFormatter.string(from: dateOnSaleEnd)
                priceDetails.append(String.localizedStringWithFormat(Constants.saleDateFormatTo, formattedDate))
            }
        } else if product.price.isEmpty == false {
            let formattedPrice = currencyFormatter.formatAmount(product.regularPrice ?? product.price, with: currency) ?? ""
            priceDetails.append(String.localizedStringWithFormat(Constants.regularPriceFormat, formattedPrice))
        }

        let details = priceDetails.isEmpty ? nil: priceDetails.joined(separator: "\n")
        return ProductFormSection.SettingsRow.ViewModel(icon: icon,
                                                        title: title,
                                                        details: details)
    }

    func inventorySettingsRow(product: Product) -> ProductFormSection.SettingsRow.ViewModel {
        let icon = UIImage.inventoryImage
        let title = Constants.inventorySettingsTitle

        var inventoryDetails = [String]()

        if let sku = product.sku, !sku.isEmpty {
            inventoryDetails.append(String.localizedStringWithFormat(Constants.skuFormat, sku))
        }

        if let stockQuantity = product.stockQuantity {
            inventoryDetails.append(String.localizedStringWithFormat(Constants.stockQuantityFormat, stockQuantity))
        } else {
            let stockStatus = product.productStockStatus
            inventoryDetails.append(String.localizedStringWithFormat(Constants.stockStatusFormat, stockStatus.description))
        }

        let details = inventoryDetails.isEmpty ? nil: inventoryDetails.joined(separator: "\n")

        return ProductFormSection.SettingsRow.ViewModel(icon: icon,
                                                        title: title,
                                                        details: details)
    }

    func shippingSettingsRow(product: Product) -> ProductFormSection.SettingsRow.ViewModel {
        let icon = UIImage.shippingImage
        let title = Constants.shippingSettingsTitle

        var shippingDetails = [String]()

        // Weight[unit]
        if let weight = product.weight, let weightUnit = ServiceLocator.shippingSettingsService.weightUnit, !weight.isEmpty {
            shippingDetails.append(String.localizedStringWithFormat(Constants.weightFormat,
                                                                    weight, weightUnit))
        }

        // L x W x H[unit]
        let length = product.dimensions.length
        let width = product.dimensions.width
        let height = product.dimensions.height
        let dimensions = [length, width, height].filter({ !$0.isEmpty })
        if let dimensionUnit = ServiceLocator.shippingSettingsService.dimensionUnit,
            !dimensions.isEmpty {
            switch dimensions.count {
            case 1:
                let dimension = dimensions[0]
                shippingDetails.append(String.localizedStringWithFormat(Constants.oneDimensionFormat,
                                                                        dimension, dimensionUnit))
            case 2:
                let firstDimension = dimensions[0]
                let secondDimension = dimensions[1]
                shippingDetails.append(String.localizedStringWithFormat(Constants.twoDimensionsFormat,
                                                                        firstDimension, secondDimension, dimensionUnit))
            case 3:
                let firstDimension = dimensions[0]
                let secondDimension = dimensions[1]
                let thirdDimension = dimensions[2]
                shippingDetails.append(String.localizedStringWithFormat(Constants.fullDimensionsFormat,
                                                                        firstDimension, secondDimension, thirdDimension, dimensionUnit))
            default:
                break
            }
        }

        let details: String? = shippingDetails.isEmpty ? nil: shippingDetails.joined(separator: "\n")
        return ProductFormSection.SettingsRow.ViewModel(icon: icon,
                                                        title: title,
                                                        details: details)
    }

    func categoriesRow(product: Product) -> ProductFormSection.SettingsRow.ViewModel {
        let icon = UIImage.categoriesIcon
        let title = Constants.categoriesTitle
        let details = product.categoriesDescription() ?? Constants.categoriesPlaceholder
        return ProductFormSection.SettingsRow.ViewModel(icon: icon, title: title, details: details)
    }

    func briefDescriptionRow(product: Product) -> ProductFormSection.SettingsRow.ViewModel {
        let icon = UIImage.briefDescriptionImage
        let title = Constants.briefDescriptionTitle
        let details = product.trimmedBriefDescription?.isNotEmpty == true ? product.trimmedBriefDescription: Constants.briefDescriptionPlaceholder

        return ProductFormSection.SettingsRow.ViewModel(icon: icon,
                                                        title: title,
                                                        details: details)
    }
}

private extension DefaultProductFormTableViewModel {
    enum Constants {
        static let priceSettingsTitle = NSLocalizedString("Price",
                                                          comment: "Title of the Price Settings row on Product main screen")
        static let inventorySettingsTitle = NSLocalizedString("Inventory",
                                                              comment: "Title of the Inventory Settings row on Product main screen")
        static let shippingSettingsTitle = NSLocalizedString("Shipping",
                                                             comment: "Title of the Shipping Settings row on Product main screen")
        static let categoriesTitle = NSLocalizedString("Categories",
                                                       comment: "Title of the Categories row on Product main screen")
        static let briefDescriptionTitle = NSLocalizedString("Short description",
                                                             comment: "Title of the Short Description row on Product main screen")

        // Price
        static let regularPriceFormat = NSLocalizedString("Regular price: %@",
                                                          comment: "Format of the regular price on the Price Settings row")
        static let salePriceFormat = NSLocalizedString("Sale price: %@",
                                                       comment: "Format of the sale price on the Price Settings row")
        static let saleDatesFormat = NSLocalizedString("Sale dates: %@",
                                                       comment: "Format of the sale period on the Price Settings row")
        static let saleDateFormatFrom = NSLocalizedString("Sale dates: From %@",
                                                    comment: "Format of the sale period on the Price Settings row from a certain date")
        static let saleDateFormatTo = NSLocalizedString("Sale dates: Until %@",
                                                    comment: "Format of the sale period on the Price Settings row until a certain date")

        // Inventory
        static let skuFormat = NSLocalizedString("SKU: %@",
                                                 comment: "Format of the SKU on the Inventory Settings row")
        static let stockQuantityFormat = NSLocalizedString("Quantity: %ld",
                                                           comment: "Format of the stock quantity on the Inventory Settings row")
        static let stockStatusFormat = NSLocalizedString("Stock status: %@",
                                                         comment: "Format of the stock status on the Inventory Settings row")

        // Shipping
        static let weightFormat = NSLocalizedString("Weight: %1$@%2$@",
                                                    comment: "Format of the weight on the Shipping Settings row - weight[unit]")
        static let oneDimensionFormat = NSLocalizedString("Dimensions: %1$@%2$@",
                                                          comment: "Format of one dimension on the Shipping Settings row - dimension[unit]")
        static let twoDimensionsFormat = NSLocalizedString("Dimensions: %1$@ x %2$@%3$@",
                                                           comment: "Format of 2 dimensions on the Shipping Settings row - dimension x dimension[unit]")
        static let fullDimensionsFormat = NSLocalizedString("Dimensions: %1$@ x %2$@ x %3$@%4$@",
                                                            comment: "Format of all 3 dimensions on the Shipping Settings row - L x W x H[unit]")

        // Short description
        static let briefDescriptionPlaceholder = NSLocalizedString("A brief excerpt about the product",
                                                                   comment: "Placeholder of the Product Short Description row on Product main screen")

        // Categories
        static let categoriesPlaceholder = NSLocalizedString("Uncategorized",
                                                                   comment: "Placeholder of the Product Categories row on Product main screen")
    }
}

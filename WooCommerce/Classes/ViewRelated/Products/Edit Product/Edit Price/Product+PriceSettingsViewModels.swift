import Yosemite

extension Product {

    // Regex that match all the occurrences of the thousand separators.
    // All the points or comma (but not the last `.` or `,`)
    //
    private static let regexThousandSeparators = "(?:[.,](?=.*[.,])|)+"

    private static let placeholder = "0"

    static func createRegularPriceViewModel(regularPrice: String?,
                                            using currencySettings: CurrencySettings,
                                            onInputChange: @escaping (_ input: String?) -> Void) -> UnitInputViewModel {
        let title = NSLocalizedString("Price", comment: "Title of the cell in Product Price Settings > Price")

        let currencyFormatter = CurrencyFormatter()
        let currencyCode = CurrencySettings.shared.currencyCode
        let unit = CurrencySettings.shared.symbol(from: currencyCode)
        var value = currencyFormatter.formatAmount(regularPrice ?? "", with: unit) ?? ""
        value = value
            .replacingOccurrences(of: unit, with: "")
            .replacingOccurrences(of: regexThousandSeparators, with: "$1", options: .regularExpression)
        return UnitInputViewModel(title: title,
                                  unit: unit,
                                  value: value,
                                  placeholder: placeholder,
                                  unitPosition: currencySettings.currencyUnitPosition,
                                  keyboardType: .decimalPad,
                                  inputFormatter: PriceInputFormatter(),
                                  onInputChange: onInputChange)
    }

    static func createSalePriceViewModel(salePrice: String?,
                                         using currencySettings: CurrencySettings,
                                         onInputChange: @escaping (_ input: String?) -> Void) -> UnitInputViewModel {
        let title = NSLocalizedString("Sale price", comment: "Title of the cell in Product Price Settings > Sale price")

        let currencyFormatter = CurrencyFormatter()
        let currencyCode = CurrencySettings.shared.currencyCode
        let unit = CurrencySettings.shared.symbol(from: currencyCode)
        var value = currencyFormatter.formatAmount(salePrice ?? "", with: unit) ?? ""
        value = value
            .replacingOccurrences(of: unit, with: "")
            .replacingOccurrences(of: regexThousandSeparators, with: "$1", options: .regularExpression)
        return UnitInputViewModel(title: title,
                                  unit: unit,
                                  value: value,
                                  placeholder: placeholder,
                                  unitPosition: currencySettings.currencyUnitPosition,
                                  keyboardType: .decimalPad,
                                  inputFormatter: PriceInputFormatter(),
                                  onInputChange: onInputChange)
    }
}

private extension CurrencySettings {
    var currencyUnitPosition: UnitInputViewModel.UnitPosition {
        switch currencyPosition {
        case .left:
            return .beforeInputWithoutSpace
        case .leftSpace:
            return .beforeInput
        case .right:
            return .afterInputWithoutSpace
        case .rightSpace:
            return .afterInput
        }
    }
}

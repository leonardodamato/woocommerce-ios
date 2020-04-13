import Foundation
import Yosemite


// MARK: - Manual currency formatting
//
public class CurrencyFormatter {
    private let currencySettings: CurrencySettings

    init(currencySettings: CurrencySettings = CurrencySettings.shared) {
        self.currencySettings = currencySettings
    }

    /// Returns a decimal value from a given string.
    /// - Parameters:
    ///   - stringValue: the string received from the API
    ///
    func convertToDecimal(from stringValue: String) -> NSDecimalNumber? {

        // NSDecimalNumber use by default the local decimal separator to evaluate a decimal amount.
        // We substitute the current decimal separator with the locale decimal separator.
        let localeDecimalSeparator = Locale.current.decimalSeparator ?? currencySettings.decimalSeparator
        var newStringValue = stringValue.replacingOccurrences(of: ",", with: localeDecimalSeparator)
        newStringValue = newStringValue.replacingOccurrences(of: ".", with: localeDecimalSeparator)

        // Removes the currency symbol, if any.
        let currencyCode = currencySettings.currencyCode
        let unit = currencySettings.symbol(from: currencyCode)
        newStringValue = newStringValue.replacingOccurrences(of: unit, with: "")

        let decimalValue = NSDecimalNumber(string: newStringValue, locale: Locale.current)

        guard decimalValue != NSDecimalNumber.notANumber else {
            DDLogError("Error: string input is not a number: \(stringValue)")
            return nil
        }

        return decimalValue
    }

    /// Returns a formatted string for the amount. Does not contain currency symbol.
    /// - Parameters:
    ///     - decimal: a valid NSDecimalNumber, preferably converted using `convertToDecimal()`
    ///     - decimalSeparator: a string representing the user's preferred decimal symbol
    ///     - decimalPosition: an int for positioning the decimal symbol
    ///     - thousandSeparator: a string representing the user's preferred thousand symbol*
    ///       *Assumes thousands grouped by 3, because a user can't indicate a preference and it's a majority default.
    ///       Note this assumption will be wrong for India.
    ///
    func localize(_ decimalAmount: NSDecimalNumber,
                  with decimalSeparator: String? = ".",
                  in decimalPosition: Int = 2,
                  including thousandSeparator: String? = ",") -> String? {

        // If the decimal amount is negative, change it to a positive.
        // We'll add our own custom negative sign in `formatAmount(with:)`
        let absoluteAmount = decimalAmount.isNegative() ? decimalAmount.multiplying(by: -1) : decimalAmount

        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.groupingSeparator = thousandSeparator
        numberFormatter.decimalSeparator = decimalSeparator
        numberFormatter.groupingSize = 3
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .decimal
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.minimumFractionDigits = decimalPosition
        numberFormatter.maximumFractionDigits = decimalPosition

        return numberFormatter.string(from: absoluteAmount)
    }

    /// Returns a string that displays the amount using all of the specified currency settings
    /// - Parameters:
    ///     - amount: a formatted string, preferably converted using `localize(_:in:with:including:)`.
    ///     - position: the currency position enum, either right, left, right_space, or left_space.
    ///     - symbol: the currency symbol as a string, to be used with the amount.
    ///
    func formatCurrency(using stringValue: String, at position: CurrencySettings.CurrencyPosition, with symbol: String, isNegative: Bool) -> String {
        let space = "\u{00a0}" // unicode equivalent of &nbsp;
        let negative = isNegative ? "-" : ""

        // We're relying on the phone's Locale to assist with language direction
        let current = Locale.current as NSLocale
        let languageCode = current.object(forKey: NSLocale.Key.languageCode) as? String

        // Remove all occurences of the minus sign from the string amount.
        // We want to position the minus sign manually.
        let amount = stringValue.replacingOccurrences(of: "-", with: "")

        // Detect the language direction
        var languageDirection: Locale.LanguageDirection = .unknown
        if let language = languageCode {
            languageDirection = Locale.characterDirection(forLanguage: language)
        }

        // For left-to-right languages, such as English
        guard languageDirection == .rightToLeft else {
            switch position {
            case .left:
                return negative + symbol + amount
            case .right:
                return negative + amount + symbol
            case .leftSpace:
                return negative + symbol + space + amount
            case .rightSpace:
                return negative + amount + space + symbol
            }
        }

        // For right-to-left languages, such as Arabic
        switch position {
        case .left:
            return amount + negative + symbol
        case .right:
            return symbol + negative + amount
        case .leftSpace:
            return amount + negative + space + symbol
        case .rightSpace:
            return symbol + space + negative + amount
        }
    }

    /// Applies currency option settings to the amount (as String) for the given currency.
    ///
    /// - Parameters:
    ///     - amount: a raw string representation of the amount, from the API, with no formatting applied. e.g. "19.87"
    ///     - currency: a 3-letter country code for currencies that are supported in the API. e.g. "USD"
    ///
    func formatAmount(_ stringAmount: String, with currency: String = CurrencySettings.shared.currencyCode.rawValue) -> String? {
        guard let decimalAmount = convertToDecimal(from: stringAmount) else {
            return nil
        }

        return formatAmount(decimalAmount, with: currency)
    }


    /// Formats the provided `amount` param into a human readable value and applies the currency option
    /// settings for the given currency.
    ///
    /// - Parameters:
    ///   - amount: a raw string representation of the amount, from the API, with no formatting applied. e.g. "19.87"
    ///   - currency: a 3-letter country code for currencies that are supported in the API. e.g. "USD"
    ///   - roundSmallNumbers: if `true`, small numbers are rounded, if `false`, no rounding occurs (defaults to true)
    /// - Returns: a formatted amount string
    ///
    /// For our purposes here, a "small number" is anything in-between -1000 and 1000 (exclusive).
    ///
    /// - Note: This func leverages the formatter from our `NSDecimalNumber` extension.
    ///         See: `NSDecimalNumber+Helpers.swift` for more details.
    ///
    /// Examples with currency code of "USD" (`roundSmallNumbers` is set to `true`):
    ///  - 0 becomes "$0"
    ///  - 198.44 becomes "$198"
    ///  - 198.88 becomes "$198"
    ///  - 999 becomes "$999"
    ///  - 1000 becomes "$1.0k"
    ///  - 5800199.56 becomes "$5.8m"
    ///
    /// Examples with currency code of "USD" (`roundSmallNumbers` is set to `false`):
    ///  - 0 becomes "$0.00"
    ///  - 198.44 becomes "$198.44"
    ///  - 198.88 becomes "$198.88"
    ///  - 999 becomes "$999.00"
    ///  - 1000 becomes "$1.0k"
    ///  - 5800199.56 becomes "$5.8m"
    ///
    func formatHumanReadableAmount(_ stringAmount: String,
                                   with currency: String = CurrencySettings.shared.currencyCode.rawValue,
                                   roundSmallNumbers: Bool = true) -> String? {
        guard let amount = convertToDecimal(from: stringAmount) else {
            return nil
        }

        let humanReadableAmount = amount.humanReadableString(roundSmallNumbers: roundSmallNumbers)
        if humanReadableAmount == amount.stringValue, roundSmallNumbers == false {
            // The human readable version of amount is the same as the converted param value which means this is a "small"
            // number — format it normally *without* rounding.
            return formatAmount(amount, with: currency)
        }

        // If we are here, the human readable version of the amount param is a "large" number *OR* a small number but rounding has been requested,
        // so let's just put the currency symbol on the correct side of the string with proper spacing (based on the site settings).
        let code = CurrencySettings.CurrencyCode(rawValue: currency) ?? currencySettings.currencyCode
        let symbol = currencySettings.symbol(from: code)
        let position = currencySettings.currencyPosition
        let isNegative = amount.isNegative()

        return formatCurrency(using: humanReadableAmount,
                              at: position,
                              with: symbol,
                              isNegative: isNegative)
    }

    /// Applies currency option settings to the amount for the given currency.
    /// - Parameters:
    ///     - amount: a NSDecimalNumber representation of the amount, from the API, with no formatting applied. e.g. "19.87"
    ///     - currency: a 3-letter country code for currencies that are supported in the API. e.g. "USD"
    ///
    func formatAmount(_ decimalAmount: NSDecimalNumber, with currency: String = CurrencySettings.shared.currencyCode.rawValue) -> String? {
        // Get the currency code
        let code = CurrencySettings.CurrencyCode(rawValue: currency) ?? currencySettings.currencyCode
        // Grab the read-only currency options. These are set by the user in Site > Settings.
        let symbol = currencySettings.symbol(from: code)
        let separator = currencySettings.decimalSeparator
        let numberOfDecimals = currencySettings.numberOfDecimals
        let position = currencySettings.currencyPosition
        let thousandSeparator = currencySettings.thousandSeparator

        // Put all the pieces of user preferences on currency formatting together
        // and spit out a string that has the formatted amount.
        let localized = localize(decimalAmount,
                                 with: separator,
                                 in: numberOfDecimals,
                                 including: thousandSeparator)

        guard let localizedAmount = localized else {
            return nil
        }

        // Now take the formatted amount and piece it together with
        // the currency symbol, negative sign, and any requisite spaces.
        let formattedAmount = formatCurrency(using: localizedAmount,
                                             at: position,
                                             with: symbol,
                                             isNegative: decimalAmount.isNegative())

        return formattedAmount
    }
}

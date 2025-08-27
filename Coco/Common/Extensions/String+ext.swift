import Foundation

public extension String {
    func formatToIndonesianCurrency() -> String {
        var cleanedInput = self.replacingOccurrences(of: "Rp ", with: "")

        // Remove ".0" from the end if it exists
        if cleanedInput.hasSuffix(".0") {
            cleanedInput = String(cleanedInput.dropLast(2))
        }

        // Replace comma with dot for Double conversion if it's a decimal separator
        cleanedInput = cleanedInput.replacingOccurrences(of: ",", with: ".")

        if let number = Double(cleanedInput) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "Rp "
            formatter.currencyGroupingSeparator = "."
            formatter.currencyDecimalSeparator = ","
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0

            if let formattedString = formatter.string(from: NSNumber(value: number)) {
                return formattedString
            }
        }
        // Fallback if conversion fails
        return "Rp \(self)"
    }
}

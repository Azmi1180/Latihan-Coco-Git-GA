import Foundation

public extension String {
    func formatToIndonesianCurrency() -> String {
        // Hilangkan "Rp", spasi, dan karakter selain angka/titik/koma
        var cleanedInput = self.replacingOccurrences(of: "Rp", with: "")
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: CharacterSet(charactersIn: "0123456789.,").inverted)
            .joined()

        // Ubah koma jadi titik (biar konsisten untuk Double conversion)
        cleanedInput = cleanedInput.replacingOccurrences(of: ",", with: ".")

        // Hilangkan ".0" di akhir
        if cleanedInput.hasSuffix(".0") {
            cleanedInput = String(cleanedInput.dropLast(2))
        }

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
        // Fallback jika gagal konversi
        return "Rp \(self)"
    }
    static func formatToIndonesianCurrency(price: String) -> String {
        return price.formatToIndonesianCurrency()
    }
}

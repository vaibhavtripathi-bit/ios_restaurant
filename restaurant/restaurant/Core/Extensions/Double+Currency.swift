import Foundation

extension Double {
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    var asCompactCurrency: String {
        String(format: "$%.2f", self)
    }
}

extension Int {
    var asMinutes: String {
        if self < 60 {
            return "\(self) min"
        } else {
            let hours = self / 60
            let mins = self % 60
            if mins == 0 {
                return "\(hours) hr"
            }
            return "\(hours) hr \(mins) min"
        }
    }
}

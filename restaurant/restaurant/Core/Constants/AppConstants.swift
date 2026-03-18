import Foundation

enum AppConstants {
    static let appName = "La Bella Italia"
    static let appTagline = "Authentic Italian Cuisine"
    
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
    
    enum Layout {
        static let defaultPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let largeCornerRadius: CGFloat = 16
        static let cardShadowRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 50
        static let iconSize: CGFloat = 24
        static let smallIconSize: CGFloat = 16
        static let largeIconSize: CGFloat = 32
    }
    
    enum Cart {
        static let maxQuantity = 99
        static let minQuantity = 1
    }
    
    enum Reservation {
        static let maxPartySize = 20
        static let minPartySize = 1
        static let maxAdvanceBookingDays = 30
    }
}

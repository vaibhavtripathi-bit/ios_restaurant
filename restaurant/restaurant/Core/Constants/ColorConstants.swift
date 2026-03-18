import SwiftUI

extension Color {
    static let appPrimary = Color("Primary")
    static let appSecondary = Color("Secondary")
    static let appBackground = Color("Background")
    static let appSurface = Color("Surface")
    static let appTextPrimary = Color("TextPrimary")
    static let appTextSecondary = Color("TextSecondary")
    static let appSuccess = Color("Success")
    static let appError = Color("Error")
}

enum AppColors {
    static let primary = Color(hex: "E85D04")
    static let secondary = Color(hex: "F48C06")
    static let accent = Color(hex: "DC2F02")
    static let background = Color(hex: "FFFFFF")
    static let surface = Color(hex: "F8F9FA")
    static let surfaceSecondary = Color(hex: "E9ECEF")
    static let textPrimary = Color(hex: "212529")
    static let textSecondary = Color(hex: "6C757D")
    static let textTertiary = Color(hex: "ADB5BD")
    static let success = Color(hex: "28A745")
    static let warning = Color(hex: "FFC107")
    static let error = Color(hex: "DC3545")
    static let info = Color(hex: "17A2B8")
    
    static let gradientPrimary = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientBackground = LinearGradient(
        colors: [background, surface],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

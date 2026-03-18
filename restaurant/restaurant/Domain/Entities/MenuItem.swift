import Foundation

struct MenuItem: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String?
    let categoryId: String
    let isVegetarian: Bool
    let isVegan: Bool
    let isGlutenFree: Bool
    let spicyLevel: SpicyLevel
    let calories: Int?
    let preparationTime: Int
    let ingredients: [String]
    let allergens: [String]
    
    enum SpicyLevel: Int, CaseIterable {
        case none = 0
        case mild = 1
        case medium = 2
        case hot = 3
        
        var displayName: String {
            switch self {
            case .none: return "Not Spicy"
            case .mild: return "Mild"
            case .medium: return "Medium"
            case .hot: return "Hot"
            }
        }
        
        var icon: String {
            switch self {
            case .none: return ""
            case .mild: return "🌶️"
            case .medium: return "🌶️🌶️"
            case .hot: return "🌶️🌶️🌶️"
            }
        }
    }
}

extension MenuItem {
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    var dietaryBadges: [String] {
        var badges: [String] = []
        if isVegetarian { badges.append("Vegetarian") }
        if isVegan { badges.append("Vegan") }
        if isGlutenFree { badges.append("Gluten-Free") }
        return badges
    }
}

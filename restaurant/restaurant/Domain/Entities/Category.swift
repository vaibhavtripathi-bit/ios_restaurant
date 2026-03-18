import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let imageURL: String?
    let itemCount: Int
    let displayOrder: Int
}

extension Category {
    var iconName: String {
        switch name.lowercased() {
        case "appetizers", "starters":
            return "leaf.fill"
        case "mains", "entrees", "main courses":
            return "fork.knife"
        case "desserts", "sweets":
            return "birthday.cake.fill"
        case "drinks", "beverages":
            return "cup.and.saucer.fill"
        case "salads":
            return "carrot.fill"
        case "soups":
            return "takeoutbag.and.cup.and.straw.fill"
        case "pizzas", "pizza":
            return "circle.grid.2x2.fill"
        case "pasta":
            return "fork.knife.circle.fill"
        default:
            return "menucard.fill"
        }
    }
}

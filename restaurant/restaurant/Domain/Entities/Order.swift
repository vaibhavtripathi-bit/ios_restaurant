import Foundation

struct Order: Identifiable, Equatable {
    let id: String
    let items: [CartItem]
    let subtotal: Double
    let tax: Double
    let discount: Double
    let total: Double
    let status: OrderStatus
    let orderType: OrderType
    let createdAt: Date
    let estimatedReadyTime: Date?
    let specialInstructions: String?
    
    enum OrderStatus: String, CaseIterable {
        case pending = "pending"
        case confirmed = "confirmed"
        case preparing = "preparing"
        case ready = "ready"
        case delivered = "delivered"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .confirmed: return "Confirmed"
            case .preparing: return "Preparing"
            case .ready: return "Ready"
            case .delivered: return "Delivered"
            case .cancelled: return "Cancelled"
            }
        }
        
        var iconName: String {
            switch self {
            case .pending: return "clock"
            case .confirmed: return "checkmark.circle"
            case .preparing: return "flame"
            case .ready: return "bell"
            case .delivered: return "checkmark.seal.fill"
            case .cancelled: return "xmark.circle"
            }
        }
        
        var isActive: Bool {
            switch self {
            case .pending, .confirmed, .preparing, .ready:
                return true
            case .delivered, .cancelled:
                return false
            }
        }
    }
    
    enum OrderType: String, CaseIterable {
        case pickup = "pickup"
        case delivery = "delivery"
        case dineIn = "dine_in"
        
        var displayName: String {
            switch self {
            case .pickup: return "Pickup"
            case .delivery: return "Delivery"
            case .dineIn: return "Dine In"
            }
        }
        
        var iconName: String {
            switch self {
            case .pickup: return "bag"
            case .delivery: return "car"
            case .dineIn: return "fork.knife"
            }
        }
    }
}

extension Order {
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var formattedEstimatedTime: String? {
        guard let estimatedReadyTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: estimatedReadyTime)
    }
}

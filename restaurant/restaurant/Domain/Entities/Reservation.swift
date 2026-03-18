import Foundation

struct Reservation: Identifiable, Equatable {
    let id: String
    let date: Date
    let time: String
    let partySize: Int
    let customerName: String
    let customerPhone: String
    let customerEmail: String?
    let specialRequests: String?
    let status: ReservationStatus
    let confirmationCode: String
    let createdAt: Date
    
    enum ReservationStatus: String, CaseIterable {
        case pending = "pending"
        case confirmed = "confirmed"
        case seated = "seated"
        case completed = "completed"
        case cancelled = "cancelled"
        case noShow = "no_show"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .confirmed: return "Confirmed"
            case .seated: return "Seated"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            case .noShow: return "No Show"
            }
        }
        
        var iconName: String {
            switch self {
            case .pending: return "clock"
            case .confirmed: return "checkmark.circle"
            case .seated: return "chair.lounge"
            case .completed: return "checkmark.seal.fill"
            case .cancelled: return "xmark.circle"
            case .noShow: return "person.slash"
            }
        }
    }
}

extension Reservation {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    var formattedDateTime: String {
        "\(formattedDate) at \(time)"
    }
    
    var partySizeText: String {
        partySize == 1 ? "1 Guest" : "\(partySize) Guests"
    }
}

struct TimeSlot: Identifiable, Equatable {
    let id: String
    let time: String
    let isAvailable: Bool
    
    init(time: String, isAvailable: Bool) {
        self.id = time
        self.time = time
        self.isAvailable = isAvailable
    }
}

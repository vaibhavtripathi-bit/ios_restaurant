import Foundation
import CoreLocation

struct Restaurant: Equatable {
    let name: String
    let description: String
    let address: String
    let phone: String
    let email: String
    let website: String?
    let coordinate: CLLocationCoordinate2D
    let hours: [DayHours]
    let features: [String]
    let socialMedia: SocialMedia?
    
    struct DayHours: Equatable, Identifiable {
        let id: String
        let day: Weekday
        let openTime: String
        let closeTime: String
        let isClosed: Bool
        
        init(day: Weekday, openTime: String, closeTime: String, isClosed: Bool = false) {
            self.id = day.rawValue
            self.day = day
            self.openTime = openTime
            self.closeTime = closeTime
            self.isClosed = isClosed
        }
        
        var displayHours: String {
            isClosed ? "Closed" : "\(openTime) - \(closeTime)"
        }
    }
    
    enum Weekday: String, CaseIterable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
        
        var shortName: String {
            String(rawValue.prefix(3))
        }
    }
    
    struct SocialMedia: Equatable {
        let instagram: String?
        let facebook: String?
        let twitter: String?
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.name == rhs.name &&
        lhs.address == rhs.address &&
        lhs.phone == rhs.phone
    }
}

extension Restaurant {
    var isCurrentlyOpen: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekdayIndex = calendar.component(.weekday, from: now)
        
        let weekdayMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        
        guard let currentWeekday = weekdayMap[weekdayIndex],
              let todayHours = hours.first(where: { $0.day == currentWeekday }),
              !todayHours.isClosed else {
            return false
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let openTime = formatter.date(from: todayHours.openTime),
              let closeTime = formatter.date(from: todayHours.closeTime) else {
            return false
        }
        
        let currentTimeString = formatter.string(from: now)
        guard let currentTime = formatter.date(from: currentTimeString) else {
            return false
        }
        
        return currentTime >= openTime && currentTime <= closeTime
    }
    
    var todayHours: DayHours? {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: Date())
        
        let weekdayMap: [Int: Weekday] = [
            1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
            5: .thursday, 6: .friday, 7: .saturday
        ]
        
        guard let currentWeekday = weekdayMap[weekdayIndex] else { return nil }
        return hours.first(where: { $0.day == currentWeekday })
    }
}

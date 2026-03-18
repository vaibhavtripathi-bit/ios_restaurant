import Foundation

struct User: Identifiable, Equatable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?
    var profileImageURL: String?
    let createdAt: Date
    var favoriteItemIds: [String]
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.first.map(String.init) ?? ""
        let lastInitial = lastName.first.map(String.init) ?? ""
        return "\(firstInitial)\(lastInitial)"
    }
}

extension User {
    static var guest: User {
        User(
            id: "guest",
            firstName: "Guest",
            lastName: "User",
            email: "",
            phone: nil,
            profileImageURL: nil,
            createdAt: Date(),
            favoriteItemIds: []
        )
    }
    
    var isGuest: Bool {
        id == "guest"
    }
}

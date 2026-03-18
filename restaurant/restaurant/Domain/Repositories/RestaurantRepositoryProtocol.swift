import Foundation

protocol RestaurantRepositoryProtocol: Sendable {
    func getRestaurantInfo() async throws -> Restaurant
}

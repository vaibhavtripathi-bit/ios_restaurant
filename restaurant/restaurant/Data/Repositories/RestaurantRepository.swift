import Foundation

final class RestaurantRepository: RestaurantRepositoryProtocol, @unchecked Sendable {
    private let dataSource: MockDataSource
    
    init(dataSource: MockDataSource = .shared) {
        self.dataSource = dataSource
    }
    
    func getRestaurantInfo() async throws -> Restaurant {
        try await Task.sleep(nanoseconds: 200_000_000)
        return dataSource.restaurant
    }
}

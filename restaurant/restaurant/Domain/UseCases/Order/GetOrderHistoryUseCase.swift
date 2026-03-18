import Foundation

protocol GetOrderHistoryUseCaseProtocol: Sendable {
    func execute() async throws -> [Order]
}

final class GetOrderHistoryUseCase: GetOrderHistoryUseCaseProtocol, Sendable {
    private let repository: OrderRepositoryProtocol
    
    init(repository: OrderRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Order] {
        try await repository.getOrderHistory()
    }
}

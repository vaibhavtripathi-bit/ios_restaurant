import Foundation

protocol CancelOrderUseCaseProtocol: Sendable {
    func execute(orderId: String) async throws -> Order
}

final class CancelOrderUseCase: CancelOrderUseCaseProtocol, Sendable {
    private let repository: OrderRepositoryProtocol
    
    init(repository: OrderRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(orderId: String) async throws -> Order {
        try await repository.cancelOrder(id: orderId)
    }
}

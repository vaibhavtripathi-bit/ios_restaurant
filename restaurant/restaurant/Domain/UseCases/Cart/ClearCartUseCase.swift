import Foundation

protocol ClearCartUseCaseProtocol: Sendable {
    func execute() async throws -> Cart
}

final class ClearCartUseCase: ClearCartUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> Cart {
        try await repository.clearCart()
    }
}

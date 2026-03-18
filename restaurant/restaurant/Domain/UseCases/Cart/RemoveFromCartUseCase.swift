import Foundation

protocol RemoveFromCartUseCaseProtocol: Sendable {
    func execute(cartItemId: String) async throws -> Cart
}

final class RemoveFromCartUseCase: RemoveFromCartUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(cartItemId: String) async throws -> Cart {
        try await repository.removeFromCart(cartItemId: cartItemId)
    }
}

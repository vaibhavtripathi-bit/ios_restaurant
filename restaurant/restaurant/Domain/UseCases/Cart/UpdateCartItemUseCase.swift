import Foundation

protocol UpdateCartItemUseCaseProtocol: Sendable {
    func execute(cartItemId: String, quantity: Int) async throws -> Cart
}

final class UpdateCartItemUseCase: UpdateCartItemUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(cartItemId: String, quantity: Int) async throws -> Cart {
        try await repository.updateCartItemQuantity(cartItemId: cartItemId, quantity: quantity)
    }
}

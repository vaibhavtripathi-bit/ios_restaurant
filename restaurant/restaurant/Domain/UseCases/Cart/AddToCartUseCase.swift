import Foundation

protocol AddToCartUseCaseProtocol: Sendable {
    func execute(item: MenuItem, quantity: Int, specialInstructions: String?) async throws -> Cart
}

final class AddToCartUseCase: AddToCartUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(item: MenuItem, quantity: Int = 1, specialInstructions: String? = nil) async throws -> Cart {
        guard quantity > 0 else {
            throw CartError.invalidQuantity
        }
        return try await repository.addToCart(item: item, quantity: quantity, specialInstructions: specialInstructions)
    }
}

enum CartError: LocalizedError {
    case invalidQuantity
    case itemNotFound
    case promoCodeInvalid
    
    var errorDescription: String? {
        switch self {
        case .invalidQuantity:
            return "Quantity must be greater than 0"
        case .itemNotFound:
            return "Item not found in cart"
        case .promoCodeInvalid:
            return "Invalid promo code"
        }
    }
}

import Foundation

protocol PlaceOrderUseCaseProtocol: Sendable {
    func execute(cart: Cart, orderType: Order.OrderType, specialInstructions: String?) async throws -> Order
}

final class PlaceOrderUseCase: PlaceOrderUseCaseProtocol, Sendable {
    private let orderRepository: OrderRepositoryProtocol
    private let cartRepository: CartRepositoryProtocol
    
    init(orderRepository: OrderRepositoryProtocol, cartRepository: CartRepositoryProtocol) {
        self.orderRepository = orderRepository
        self.cartRepository = cartRepository
    }
    
    func execute(cart: Cart, orderType: Order.OrderType, specialInstructions: String? = nil) async throws -> Order {
        guard !cart.isEmpty else {
            throw OrderError.emptyCart
        }
        
        let order = try await orderRepository.placeOrder(
            cart: cart,
            orderType: orderType,
            specialInstructions: specialInstructions
        )
        
        _ = try await cartRepository.clearCart()
        
        return order
    }
}

enum OrderError: LocalizedError {
    case emptyCart
    case orderNotFound
    case cannotCancel
    
    var errorDescription: String? {
        switch self {
        case .emptyCart:
            return "Cannot place order with empty cart"
        case .orderNotFound:
            return "Order not found"
        case .cannotCancel:
            return "This order cannot be cancelled"
        }
    }
}

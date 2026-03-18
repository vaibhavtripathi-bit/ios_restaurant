import Foundation

protocol CartRepositoryProtocol: Sendable {
    func getCart() async throws -> Cart
    func addToCart(item: MenuItem, quantity: Int, specialInstructions: String?) async throws -> Cart
    func updateCartItemQuantity(cartItemId: String, quantity: Int) async throws -> Cart
    func removeFromCart(cartItemId: String) async throws -> Cart
    func clearCart() async throws -> Cart
    func applyPromoCode(_ code: String) async throws -> Cart
}

import Foundation

actor CartRepository: CartRepositoryProtocol {
    private var cart: Cart = Cart()

    private let validPromoCodes: [String: Double] = [
        "WELCOME10": 0.10,
        "SAVE20": 0.20,
        "FREESHIP": 5.00
    ]

    func getCart() async throws -> Cart {
        return cart
    }

    func addToCart(item: MenuItem, quantity: Int, specialInstructions: String?) async throws -> Cart {
        var updated = cart
        updated.addItem(item, quantity: quantity, specialInstructions: specialInstructions)
        cart = updated
        return cart
    }

    func updateCartItemQuantity(cartItemId: String, quantity: Int) async throws -> Cart {
        var updated = cart
        updated.updateQuantity(id: cartItemId, quantity: quantity)
        cart = updated
        return cart
    }

    func removeFromCart(cartItemId: String) async throws -> Cart {
        var updated = cart
        updated.removeItem(id: cartItemId)
        cart = updated
        return cart
    }

    func clearCart() async throws -> Cart {
        var updated = cart
        updated.clear()
        cart = updated
        return cart
    }

    func applyPromoCode(_ code: String) async throws -> Cart {
        guard let discountRate = validPromoCodes[code] else {
            throw CartError.promoCodeInvalid
        }
        var updated = cart
        updated.promoCode = code
        updated.promoDiscount = discountRate < 1 ? updated.subtotal * discountRate : discountRate
        cart = updated
        return cart
    }
}

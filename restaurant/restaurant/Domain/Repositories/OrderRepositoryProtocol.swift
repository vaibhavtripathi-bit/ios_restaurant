import Foundation

protocol OrderRepositoryProtocol: Sendable {
    func placeOrder(cart: Cart, orderType: Order.OrderType, specialInstructions: String?) async throws -> Order
    func getOrder(id: String) async throws -> Order
    func getOrderHistory() async throws -> [Order]
    func cancelOrder(id: String) async throws -> Order
}

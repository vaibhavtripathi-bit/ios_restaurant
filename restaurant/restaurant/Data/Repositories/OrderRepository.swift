import Foundation

actor OrderRepository: OrderRepositoryProtocol {
    private var orders: [Order] = []
    
    func placeOrder(cart: Cart, orderType: Order.OrderType, specialInstructions: String?) async throws -> Order {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let order = Order(
            id: UUID().uuidString,
            items: cart.items,
            subtotal: cart.subtotal,
            tax: cart.tax,
            discount: cart.promoDiscount,
            total: cart.total,
            status: .confirmed,
            orderType: orderType,
            createdAt: Date(),
            estimatedReadyTime: Calendar.current.date(byAdding: .minute, value: 25, to: Date()),
            specialInstructions: specialInstructions
        )
        
        orders.insert(order, at: 0)
        return order
    }
    
    func getOrder(id: String) async throws -> Order {
        guard let order = orders.first(where: { $0.id == id }) else {
            throw OrderError.orderNotFound
        }
        return order
    }
    
    func getOrderHistory() async throws -> [Order] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return orders
    }
    
    func cancelOrder(id: String) async throws -> Order {
        guard let index = orders.firstIndex(where: { $0.id == id }) else {
            throw OrderError.orderNotFound
        }
        
        let order = orders[index]
        guard order.status.isActive else {
            throw OrderError.cannotCancel
        }
        
        let cancelledOrder = Order(
            id: order.id,
            items: order.items,
            subtotal: order.subtotal,
            tax: order.tax,
            discount: order.discount,
            total: order.total,
            status: .cancelled,
            orderType: order.orderType,
            createdAt: order.createdAt,
            estimatedReadyTime: nil,
            specialInstructions: order.specialInstructions
        )
        
        orders[index] = cancelledOrder
        return cancelledOrder
    }
}

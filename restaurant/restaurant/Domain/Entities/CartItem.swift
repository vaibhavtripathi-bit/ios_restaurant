import Foundation

struct CartItem: Identifiable, Equatable {
    let id: String
    let menuItem: MenuItem
    var quantity: Int
    var specialInstructions: String?
    
    init(id: String = UUID().uuidString, menuItem: MenuItem, quantity: Int = 1, specialInstructions: String? = nil) {
        self.id = id
        self.menuItem = menuItem
        self.quantity = quantity
        self.specialInstructions = specialInstructions
    }
}

extension CartItem {
    var totalPrice: Double {
        Double(quantity) * menuItem.price
    }
    
    var formattedTotalPrice: String {
        String(format: "$%.2f", totalPrice)
    }
}

struct Cart: Equatable {
    var items: [CartItem]
    var promoCode: String?
    var promoDiscount: Double
    
    init(items: [CartItem] = [], promoCode: String? = nil, promoDiscount: Double = 0) {
        self.items = items
        self.promoCode = promoCode
        self.promoDiscount = promoDiscount
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var taxRate: Double { 0.09 }
    
    var tax: Double {
        (subtotal - promoDiscount) * taxRate
    }
    
    var total: Double {
        subtotal - promoDiscount + tax
    }
    
    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
    
    var formattedTax: String {
        String(format: "$%.2f", tax)
    }
    
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
    
    var formattedDiscount: String {
        String(format: "-$%.2f", promoDiscount)
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    mutating func addItem(_ menuItem: MenuItem, quantity: Int = 1, specialInstructions: String? = nil) {
        if let index = items.firstIndex(where: { $0.menuItem.id == menuItem.id && $0.specialInstructions == specialInstructions }) {
            items[index].quantity += quantity
        } else {
            let cartItem = CartItem(menuItem: menuItem, quantity: quantity, specialInstructions: specialInstructions)
            items.append(cartItem)
        }
    }
    
    mutating func removeItem(id: String) {
        items.removeAll { $0.id == id }
    }
    
    mutating func updateQuantity(id: String, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
    }
    
    mutating func clear() {
        items.removeAll()
        promoCode = nil
        promoDiscount = 0
    }
}

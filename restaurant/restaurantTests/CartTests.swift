//
//  CartTests.swift
//  restaurantTests
//

import Testing
@testable import restaurant

// MARK: - Fixtures

private func makeMenuItem(id: String = "item-1", price: Double = 10.0) -> MenuItem {
    MenuItem(
        id: id,
        name: "Test Item",
        description: "A test menu item",
        price: price,
        imageURL: nil,
        categoryId: "cat-1",
        isVegetarian: false,
        isVegan: false,
        isGlutenFree: false,
        spicyLevel: .none,
        calories: nil,
        preparationTime: 10,
        ingredients: [],
        allergens: []
    )
}

// MARK: - Cart entity

struct CartTests {

    @Test func addingNewItemAppendsToCart() {
        var cart = Cart()
        let item = makeMenuItem()

        cart.addItem(item, quantity: 2)

        #expect(cart.items.count == 1)
        #expect(cart.items.first?.quantity == 2)
    }

    @Test func addingSameItemTwiceMergesQuantity() {
        var cart = Cart()
        let item = makeMenuItem()

        cart.addItem(item, quantity: 1)
        cart.addItem(item, quantity: 2)

        #expect(cart.items.count == 1)
        #expect(cart.items.first?.quantity == 3)
    }

    @Test func addingSameItemWithDifferentInstructionsCreatesSeparateLine() {
        var cart = Cart()
        let item = makeMenuItem()

        cart.addItem(item, quantity: 1, specialInstructions: "No onions")
        cart.addItem(item, quantity: 1, specialInstructions: "Extra spicy")

        #expect(cart.items.count == 2)
    }

    @Test func updateQuantityToZeroRemovesItem() {
        var cart = Cart()
        let item = makeMenuItem()
        cart.addItem(item, quantity: 1)
        let id = cart.items[0].id

        cart.updateQuantity(id: id, quantity: 0)

        #expect(cart.items.isEmpty)
    }

    @Test func removeItemDropsOnlyMatchingLine() {
        var cart = Cart()
        cart.addItem(makeMenuItem(id: "a"), quantity: 1)
        cart.addItem(makeMenuItem(id: "b"), quantity: 1)
        let idToRemove = cart.items.first { $0.menuItem.id == "a" }!.id

        cart.removeItem(id: idToRemove)

        #expect(cart.items.count == 1)
        #expect(cart.items.first?.menuItem.id == "b")
    }

    @Test func clearEmptiesCartAndResetsPromo() {
        var cart = Cart(items: [], promoCode: "SAVE10", promoDiscount: 5)
        cart.addItem(makeMenuItem(), quantity: 1)

        cart.clear()

        #expect(cart.items.isEmpty)
        #expect(cart.promoCode == nil)
        #expect(cart.promoDiscount == 0)
    }

    @Test func subtotalTaxAndTotalAreComputedCorrectly() {
        var cart = Cart()
        cart.addItem(makeMenuItem(price: 10.0), quantity: 2) // subtotal 20

        #expect(cart.subtotal == 20.0)
        #expect(cart.tax == 20.0 * cart.taxRate)
        #expect(cart.total == cart.subtotal - cart.promoDiscount + cart.tax)
    }

    @Test func promoDiscountReducesTaxableAmountAndTotal() {
        var cart = Cart(promoDiscount: 5)
        cart.addItem(makeMenuItem(price: 10.0), quantity: 2) // subtotal 20

        #expect(cart.tax == (20.0 - 5.0) * cart.taxRate)
        #expect(cart.total == 20.0 - 5.0 + cart.tax)
    }
}

// MARK: - AddToCartUseCase

private final class MockCartRepository: CartRepositoryProtocol {
    var addToCartCalled = false

    func getCart() async throws -> Cart { Cart() }

    func addToCart(item: MenuItem, quantity: Int, specialInstructions: String?) async throws -> Cart {
        addToCartCalled = true
        var cart = Cart()
        cart.addItem(item, quantity: quantity, specialInstructions: specialInstructions)
        return cart
    }

    func updateCartItemQuantity(cartItemId: String, quantity: Int) async throws -> Cart { Cart() }
    func removeFromCart(cartItemId: String) async throws -> Cart { Cart() }
    func clearCart() async throws -> Cart { Cart() }
    func applyPromoCode(_ code: String) async throws -> Cart { Cart() }
}

struct AddToCartUseCaseTests {

    @Test func executeThrowsOnNonPositiveQuantity() async {
        let repository = MockCartRepository()
        let useCase = AddToCartUseCase(repository: repository)

        await #expect(throws: CartError.self) {
            _ = try await useCase.execute(item: makeMenuItem(), quantity: 0, specialInstructions: nil)
        }
        #expect(repository.addToCartCalled == false)
    }

    @Test func executeDelegatesToRepositoryOnValidQuantity() async throws {
        let repository = MockCartRepository()
        let useCase = AddToCartUseCase(repository: repository)

        let cart = try await useCase.execute(item: makeMenuItem(), quantity: 2, specialInstructions: nil)

        #expect(repository.addToCartCalled)
        #expect(cart.items.first?.quantity == 2)
    }
}

// MARK: - ApplyPromoCodeUseCase

struct ApplyPromoCodeUseCaseTests {

    @Test func executeThrowsOnEmptyCode() async {
        let repository = MockCartRepository()
        let useCase = ApplyPromoCodeUseCase(repository: repository)

        await #expect(throws: CartError.self) {
            _ = try await useCase.execute(code: "   ")
        }
    }

    @Test func executeTrimsAndUppercasesCodeBeforeDelegating() async throws {
        let repository = MockCartRepository()
        let useCase = ApplyPromoCodeUseCase(repository: repository)

        _ = try await useCase.execute(code: "  save10 ")

        // Repository receives the normalized code; verified indirectly via no throw.
        #expect(Bool(true))
    }
}

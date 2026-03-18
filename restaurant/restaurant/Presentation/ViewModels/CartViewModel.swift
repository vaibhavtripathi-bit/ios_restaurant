import Combine
import Foundation

final class CartViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var cart: Cart = Cart()
    @Published private(set) var isLoading = false
    @Published private(set) var isPlacingOrder = false
    @Published private(set) var error: String?
    @Published private(set) var lastPlacedOrder: Order?
    @Published var promoCodeInput: String = ""
    @Published var specialInstructions: String = ""
    @Published var selectedOrderType: Order.OrderType = .pickup
    @Published var showingCheckout = false
    @Published var showingOrderConfirmation = false

    // MARK: - Dependencies

    private let getCartUseCase: GetCartUseCaseProtocol
    private let addToCartUseCase: AddToCartUseCaseProtocol
    private let updateCartItemUseCase: UpdateCartItemUseCaseProtocol
    private let removeFromCartUseCase: RemoveFromCartUseCaseProtocol
    private let clearCartUseCase: ClearCartUseCaseProtocol
    private let applyPromoCodeUseCase: ApplyPromoCodeUseCaseProtocol
    private let placeOrderUseCase: PlaceOrderUseCaseProtocol

    init(
        getCartUseCase: GetCartUseCaseProtocol,
        addToCartUseCase: AddToCartUseCaseProtocol,
        updateCartItemUseCase: UpdateCartItemUseCaseProtocol,
        removeFromCartUseCase: RemoveFromCartUseCaseProtocol,
        clearCartUseCase: ClearCartUseCaseProtocol,
        applyPromoCodeUseCase: ApplyPromoCodeUseCaseProtocol,
        placeOrderUseCase: PlaceOrderUseCaseProtocol
    ) {
        self.getCartUseCase = getCartUseCase
        self.addToCartUseCase = addToCartUseCase
        self.updateCartItemUseCase = updateCartItemUseCase
        self.removeFromCartUseCase = removeFromCartUseCase
        self.clearCartUseCase = clearCartUseCase
        self.applyPromoCodeUseCase = applyPromoCodeUseCase
        self.placeOrderUseCase = placeOrderUseCase
    }

    // MARK: - Computed Properties

    var isEmpty: Bool { cart.isEmpty }
    var itemCount: Int { cart.itemCount }
    var hasPromoCode: Bool { cart.promoCode != nil }

    // MARK: - Actions

    @MainActor
    func loadCart() async {
        do {
            cart = try await getCartUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func addToCart(_ item: MenuItem, quantity: Int = 1, specialInstructions: String? = nil) async {
        isLoading = true
        error = nil

        do {
            cart = try await addToCartUseCase.execute(item: item, quantity: quantity, specialInstructions: specialInstructions)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func updateQuantity(cartItemId: String, quantity: Int) async {
        do {
            cart = try await updateCartItemUseCase.execute(cartItemId: cartItemId, quantity: quantity)
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func removeItem(cartItemId: String) async {
        do {
            cart = try await removeFromCartUseCase.execute(cartItemId: cartItemId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func clearCart() async {
        do {
            cart = try await clearCartUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    func applyPromoCode() async {
        guard !promoCodeInput.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            cart = try await applyPromoCodeUseCase.execute(code: promoCodeInput)
            promoCodeInput = ""
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func placeOrder() async {
        guard !cart.isEmpty else { error = "Cart is empty"; return }

        isPlacingOrder = true
        error = nil

        do {
            let order = try await placeOrderUseCase.execute(
                cart: cart,
                orderType: selectedOrderType,
                specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
            )
            lastPlacedOrder = order
            cart = Cart()
            specialInstructions = ""
            showingCheckout = false
            showingOrderConfirmation = true
        } catch {
            self.error = error.localizedDescription
        }

        isPlacingOrder = false
    }

    func clearError() { error = nil }

    func dismissOrderConfirmation() {
        showingOrderConfirmation = false
        lastPlacedOrder = nil
    }
}

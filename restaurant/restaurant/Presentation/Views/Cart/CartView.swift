import SwiftUI

struct CartView: View {
    @State var viewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if viewModel.isEmpty {
                    emptyCart
                } else {
                    cartContent
                }
            }
            .navigationTitle("Your Cart")
            .toolbar {
                if !viewModel.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            Task {
                                await viewModel.clearCart()
                            }
                        }
                        .foregroundColor(AppColors.error)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCheckout) {
                CheckoutView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingOrderConfirmation) {
                if let order = viewModel.lastPlacedOrder {
                    OrderConfirmationView(order: order) {
                        viewModel.dismissOrderConfirmation()
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.error ?? "")
            }
        }
        .task {
            await viewModel.loadCart()
        }
    }
    
    private var emptyCart: some View {
        EmptyStateView(
            icon: "cart",
            title: "Your Cart is Empty",
            message: "Browse our delicious menu and add items to your cart."
        )
    }
    
    private var cartContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.cart.items) { item in
                        CartItemRow(
                            cartItem: item,
                            onQuantityChanged: { newQuantity in
                                Task {
                                    await viewModel.updateQuantity(cartItemId: item.id, quantity: newQuantity)
                                }
                            },
                            onRemove: {
                                Task {
                                    await viewModel.removeItem(cartItemId: item.id)
                                }
                            }
                        )
                    }
                    
                    promoCodeSection
                }
                .padding()
            }
            
            checkoutSection
        }
    }
    
    private var promoCodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Promo Code")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if viewModel.hasPromoCode {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text(viewModel.cart.promoCode ?? "")
                        .fontWeight(.medium)
                    Text("applied")
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(viewModel.cart.formattedDiscount)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.success)
                }
                .padding()
                .background(AppColors.success.opacity(0.1))
                .cornerRadius(AppConstants.Layout.cornerRadius)
            } else {
                HStack {
                    TextField("Enter promo code", text: $viewModel.promoCodeInput)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                    
                    SmallButton(title: "Apply", style: .primary) {
                        Task {
                            await viewModel.applyPromoCode()
                        }
                    }
                    .disabled(viewModel.promoCodeInput.isEmpty)
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(AppConstants.Layout.cornerRadius)
            }
        }
        .padding(.top, 8)
    }
    
    private var checkoutSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 12) {
                PriceSummaryRow(label: "Subtotal", value: viewModel.cart.formattedSubtotal)
                
                if viewModel.hasPromoCode {
                    PriceSummaryRow(label: "Discount", value: viewModel.cart.formattedDiscount, isDiscount: true)
                }
                
                PriceSummaryRow(label: "Tax", value: viewModel.cart.formattedTax)
                
                Divider()
                
                PriceSummaryRow(label: "Total", value: viewModel.cart.formattedTotal, isTotal: true)
                
                PrimaryButton(title: "Proceed to Checkout", icon: "creditcard") {
                    viewModel.showingCheckout = true
                }
            }
            .padding()
            .background(AppColors.background)
        }
    }
}

#Preview {
    CartView(viewModel: CartViewModel(
        getCartUseCase: GetCartUseCase(repository: CartRepository()),
        addToCartUseCase: AddToCartUseCase(repository: CartRepository()),
        updateCartItemUseCase: UpdateCartItemUseCase(repository: CartRepository()),
        removeFromCartUseCase: RemoveFromCartUseCase(repository: CartRepository()),
        clearCartUseCase: ClearCartUseCase(repository: CartRepository()),
        applyPromoCodeUseCase: ApplyPromoCodeUseCase(repository: CartRepository()),
        placeOrderUseCase: PlaceOrderUseCase(orderRepository: OrderRepository(), cartRepository: CartRepository())
    ))
}

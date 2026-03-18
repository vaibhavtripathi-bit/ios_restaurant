import SwiftUI

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    orderTypeSection
                    orderSummarySection
                    specialInstructionsSection
                    priceSummarySection
                }
                .padding()
            }
            .safeAreaInset(edge: .bottom) {
                placeOrderButton
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .overlay {
                LoadingOverlay(isLoading: viewModel.isPlacingOrder, message: "Placing order...")
            }
        }
    }
    
    private var orderTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Type")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(Order.OrderType.allCases, id: \.self) { type in
                    OrderTypeButton(
                        type: type,
                        isSelected: viewModel.selectedOrderType == type
                    ) {
                        viewModel.selectedOrderType = type
                    }
                }
            }
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(viewModel.cart.items) { item in
                    HStack {
                        Text("\(item.quantity)x")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 30, alignment: .leading)
                        
                        Text(item.menuItem.name)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(item.formattedTotalPrice)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
    
    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Instructions")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            TextField("Any special requests for your order?", text: $viewModel.specialInstructions, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(AppConstants.Layout.cornerRadius)
                .lineLimit(3...5)
        }
    }
    
    private var priceSummarySection: some View {
        VStack(spacing: 12) {
            PriceSummaryRow(label: "Subtotal", value: viewModel.cart.formattedSubtotal)
            
            if viewModel.hasPromoCode {
                PriceSummaryRow(label: "Discount", value: viewModel.cart.formattedDiscount, isDiscount: true)
            }
            
            PriceSummaryRow(label: "Tax (9%)", value: viewModel.cart.formattedTax)
            
            Divider()
            
            PriceSummaryRow(label: "Total", value: viewModel.cart.formattedTotal, isTotal: true)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
    
    private var placeOrderButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            PrimaryButton(
                title: "Place Order - \(viewModel.cart.formattedTotal)",
                icon: "checkmark.circle",
                isLoading: viewModel.isPlacingOrder
            ) {
                Task {
                    await viewModel.placeOrder()
                }
            }
            .padding()
            .background(AppColors.background)
        }
    }
}

struct OrderTypeButton: View {
    let type: Order.OrderType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.title2)
                Text(type.displayName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? AppColors.primary : AppColors.surface)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .stroke(isSelected ? Color.clear : AppColors.surfaceSecondary, lineWidth: 1)
            )
        }
    }
}

struct OrderConfirmationView: View {
    let order: Order
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppColors.success)
            
            VStack(spacing: 8) {
                Text("Order Confirmed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Your order has been placed successfully")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            VStack(spacing: 16) {
                infoRow(label: "Order Number", value: String(order.id.prefix(8)).uppercased())
                infoRow(label: "Order Type", value: order.orderType.displayName)
                if let estimatedTime = order.formattedEstimatedTime {
                    infoRow(label: "Estimated Ready", value: estimatedTime)
                }
                infoRow(label: "Total", value: order.formattedTotal)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            
            Spacer()
            
            PrimaryButton(title: "Done", action: onDismiss)
        }
        .padding()
    }
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    CheckoutView(viewModel: CartViewModel(
        getCartUseCase: GetCartUseCase(repository: CartRepository()),
        addToCartUseCase: AddToCartUseCase(repository: CartRepository()),
        updateCartItemUseCase: UpdateCartItemUseCase(repository: CartRepository()),
        removeFromCartUseCase: RemoveFromCartUseCase(repository: CartRepository()),
        clearCartUseCase: ClearCartUseCase(repository: CartRepository()),
        applyPromoCodeUseCase: ApplyPromoCodeUseCase(repository: CartRepository()),
        placeOrderUseCase: PlaceOrderUseCase(orderRepository: OrderRepository(), cartRepository: CartRepository())
    ))
}

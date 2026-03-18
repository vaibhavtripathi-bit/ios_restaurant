import SwiftUI

struct MenuItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: MenuItem
    @State var cartViewModel: CartViewModel
    
    @State private var quantity: Int = 1
    @State private var specialInstructions: String = ""
    @State private var showingAddedToast = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    itemImage
                    
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        descriptionSection
                        dietarySection
                        ingredientsSection
                        allergensSection
                        instructionsSection
                        quantitySection
                    }
                    .padding(.horizontal)
                }
            }
            .safeAreaInset(edge: .bottom) {
                addToCartButton
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if showingAddedToast {
                    toastView
                }
            }
        }
    }
    
    private var itemImage: some View {
        ZStack {
            Rectangle()
                .fill(AppColors.surfaceSecondary)
            
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(height: 250)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if item.spicyLevel != .none {
                    Text(item.spicyLevel.icon)
                }
                
                Spacer()
            }
            
            HStack {
                PriceTag(price: item.price, size: .large)
                
                Spacer()
                
                HStack(spacing: 16) {
                    if let calories = item.calories {
                        Label("\(calories) cal", systemImage: "flame")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Label("\(item.preparationTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        Text(item.description)
            .font(.body)
            .foregroundColor(AppColors.textSecondary)
    }
    
    @ViewBuilder
    private var dietarySection: some View {
        if !item.dietaryBadges.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dietary")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    ForEach(item.dietaryBadges, id: \.self) { badge in
                        DietaryBadge(text: badge)
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ingredients")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Text(item.ingredients.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    @ViewBuilder
    private var allergensSection: some View {
        if !item.allergens.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppColors.warning)
                    Text("Allergens")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Text(item.allergens.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.warning.opacity(0.1))
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Special Instructions")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            TextField("e.g., No onions, extra sauce...", text: $specialInstructions, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(AppColors.surface)
                .cornerRadius(AppConstants.Layout.cornerRadius)
                .lineLimit(3...5)
        }
    }
    
    private var quantitySection: some View {
        LargeQuantitySelector(
            quantity: $quantity,
            minValue: 1,
            maxValue: 10,
            label: "Quantity"
        )
    }
    
    private var addToCartButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Text((item.price * Double(quantity)).asCompactCurrency)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                PrimaryButton(
                    title: "Add to Cart",
                    icon: "cart.badge.plus",
                    isLoading: cartViewModel.isLoading
                ) {
                    Task {
                        await cartViewModel.addToCart(
                            item,
                            quantity: quantity,
                            specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
                        )
                        showingAddedToast = true
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        showingAddedToast = false
                        dismiss()
                    }
                }
                .frame(maxWidth: 180)
            }
            .padding()
            .background(AppColors.background)
        }
    }
    
    private var toastView: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.success)
                Text("Added to cart!")
                    .fontWeight(.medium)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: showingAddedToast)
    }
}

#Preview {
    MenuItemDetailView(
        item: MenuItem(
            id: "1",
            name: "Bruschetta Classica",
            description: "Grilled bread topped with fresh tomatoes, basil, garlic, and extra virgin olive oil",
            price: 8.99,
            imageURL: nil,
            categoryId: "1",
            isVegetarian: true,
            isVegan: true,
            isGlutenFree: false,
            spicyLevel: .mild,
            calories: 250,
            preparationTime: 10,
            ingredients: ["Ciabatta bread", "Roma tomatoes", "Fresh basil", "Garlic", "Olive oil"],
            allergens: ["Gluten"]
        ),
        cartViewModel: CartViewModel(
            getCartUseCase: GetCartUseCase(repository: CartRepository()),
            addToCartUseCase: AddToCartUseCase(repository: CartRepository()),
            updateCartItemUseCase: UpdateCartItemUseCase(repository: CartRepository()),
            removeFromCartUseCase: RemoveFromCartUseCase(repository: CartRepository()),
            clearCartUseCase: ClearCartUseCase(repository: CartRepository()),
            applyPromoCodeUseCase: ApplyPromoCodeUseCase(repository: CartRepository()),
            placeOrderUseCase: PlaceOrderUseCase(orderRepository: OrderRepository(), cartRepository: CartRepository())
        )
    )
}

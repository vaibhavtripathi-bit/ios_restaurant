import SwiftUI

struct CartItemRow: View {
    let cartItem: CartItem
    let onQuantityChanged: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            itemImage
            
            VStack(alignment: .leading, spacing: 6) {
                itemInfo
                specialInstructions
                priceAndQuantity
            }
        }
        .padding(AppConstants.Layout.defaultPadding)
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
    
    private var itemImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppConstants.Layout.smallCornerRadius)
                .fill(AppColors.surfaceSecondary)
            
            Image(systemName: "fork.knife")
                .font(.title3)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(width: 60, height: 60)
    }
    
    private var itemInfo: some View {
        HStack {
            Text(cartItem.menuItem.name)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundColor(AppColors.error)
            }
        }
    }
    
    @ViewBuilder
    private var specialInstructions: some View {
        if let instructions = cartItem.specialInstructions, !instructions.isEmpty {
            Text(instructions)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .italic()
        }
    }
    
    private var priceAndQuantity: some View {
        HStack {
            Text(cartItem.formattedTotalPrice)
                .font(.headline)
                .foregroundColor(AppColors.primary)
            
            Spacer()
            
            QuantitySelector(
                quantity: cartItem.quantity,
                onQuantityChanged: onQuantityChanged
            )
        }
    }
}

#Preview {
    CartItemRow(
        cartItem: CartItem(
            id: "1",
            menuItem: MenuItem(
                id: "1",
                name: "Bruschetta Classica",
                description: "Grilled bread with tomatoes",
                price: 8.99,
                imageURL: nil,
                categoryId: "1",
                isVegetarian: true,
                isVegan: true,
                isGlutenFree: false,
                spicyLevel: .none,
                calories: 250,
                preparationTime: 10,
                ingredients: [],
                allergens: []
            ),
            quantity: 2,
            specialInstructions: "Extra basil please"
        ),
        onQuantityChanged: { _ in },
        onRemove: {}
    )
    .padding()
}

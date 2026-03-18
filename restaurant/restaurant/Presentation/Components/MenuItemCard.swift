import SwiftUI

struct MenuItemCard: View {
    let item: MenuItem
    let onAddToCart: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            itemImage
            
            VStack(alignment: .leading, spacing: 6) {
                itemHeader
                itemDescription
                dietaryBadges
                itemFooter
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
                .font(.title2)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(width: 80, height: 80)
    }
    
    private var itemHeader: some View {
        HStack {
            Text(item.name)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if item.spicyLevel != .none {
                Text(item.spicyLevel.icon)
                    .font(.caption)
            }
        }
    }
    
    private var itemDescription: some View {
        Text(item.description)
            .font(.subheadline)
            .foregroundColor(AppColors.textSecondary)
            .lineLimit(2)
    }
    
    @ViewBuilder
    private var dietaryBadges: some View {
        if !item.dietaryBadges.isEmpty {
            HStack(spacing: 6) {
                ForEach(item.dietaryBadges, id: \.self) { badge in
                    DietaryBadge(text: badge)
                }
            }
        }
    }
    
    private var itemFooter: some View {
        HStack {
            Text(item.formattedPrice)
                .font(.headline)
                .foregroundColor(AppColors.primary)
            
            Spacer()
            
            if let calories = item.calories {
                HStack(spacing: 4) {
                    Image(systemName: "flame")
                        .font(.caption2)
                    Text("\(calories) cal")
                        .font(.caption)
                }
                .foregroundColor(AppColors.textTertiary)
            }
            
            Button(action: onAddToCart) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)
            }
        }
    }
}

struct DietaryBadge: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppColors.success.opacity(0.15))
            .foregroundColor(AppColors.success)
            .cornerRadius(AppConstants.Layout.smallCornerRadius)
    }
}

#Preview {
    MenuItemCard(
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
            ingredients: [],
            allergens: []
        ),
        onAddToCart: {}
    )
    .padding()
}

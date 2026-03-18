import SwiftUI

struct CategoryPill: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.iconName)
                    .font(.subheadline)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? AppColors.primary : AppColors.surface)
            .foregroundColor(isSelected ? .white : AppColors.textPrimary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : AppColors.surfaceSecondary, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct CategoryScrollView: View {
    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory?.id == category.id,
                        action: { onSelect(category) }
                    )
                }
            }
            .padding(.horizontal, AppConstants.Layout.defaultPadding)
        }
    }
}

#Preview {
    VStack {
        CategoryScrollView(
            categories: [
                Category(id: "1", name: "Appetizers", imageURL: nil, itemCount: 6, displayOrder: 1),
                Category(id: "2", name: "Mains", imageURL: nil, itemCount: 8, displayOrder: 2),
                Category(id: "3", name: "Desserts", imageURL: nil, itemCount: 4, displayOrder: 3),
                Category(id: "4", name: "Drinks", imageURL: nil, itemCount: 5, displayOrder: 4)
            ],
            selectedCategory: Category(id: "1", name: "Appetizers", imageURL: nil, itemCount: 6, displayOrder: 1),
            onSelect: { _ in }
        )
    }
}

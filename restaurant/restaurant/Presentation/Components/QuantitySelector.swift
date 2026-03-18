import SwiftUI

struct QuantitySelector: View {
    let quantity: Int
    let onQuantityChanged: (Int) -> Void
    var minValue: Int = AppConstants.Cart.minQuantity
    var maxValue: Int = AppConstants.Cart.maxQuantity
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                if quantity > minValue {
                    onQuantityChanged(quantity - 1)
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundColor(quantity > minValue ? AppColors.primary : AppColors.textTertiary)
            }
            .disabled(quantity <= minValue)
            
            Text("\(quantity)")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
                .frame(minWidth: 30)
            
            Button {
                if quantity < maxValue {
                    onQuantityChanged(quantity + 1)
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(quantity < maxValue ? AppColors.primary : AppColors.textTertiary)
            }
            .disabled(quantity >= maxValue)
        }
    }
}

struct LargeQuantitySelector: View {
    @Binding var quantity: Int
    var minValue: Int = 1
    var maxValue: Int = 20
    var label: String = "Quantity"
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    if quantity > minValue {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(quantity > minValue ? AppColors.primary : AppColors.textTertiary)
                }
                .disabled(quantity <= minValue)
                
                Text("\(quantity)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(minWidth: 40)
                
                Button {
                    if quantity < maxValue {
                        quantity += 1
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(quantity < maxValue ? AppColors.primary : AppColors.textTertiary)
                }
                .disabled(quantity >= maxValue)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

#Preview {
    VStack(spacing: 20) {
        QuantitySelector(quantity: 2, onQuantityChanged: { _ in })
        
        LargeQuantitySelector(quantity: .constant(3))
    }
    .padding()
}

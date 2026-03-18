import SwiftUI

struct PriceTag: View {
    let price: Double
    var originalPrice: Double?
    var size: Size = .medium
    
    enum Size {
        case small
        case medium
        case large
        
        var font: Font {
            switch self {
            case .small: return .subheadline
            case .medium: return .headline
            case .large: return .title2
            }
        }
        
        var originalFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(price.asCompactCurrency)
                .font(size.font)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primary)
            
            if let originalPrice = originalPrice, originalPrice > price {
                Text(originalPrice.asCompactCurrency)
                    .font(size.originalFont)
                    .foregroundColor(AppColors.textTertiary)
                    .strikethrough()
            }
        }
    }
}

struct PriceSummaryRow: View {
    let label: String
    let value: String
    var isTotal: Bool = false
    var isDiscount: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .foregroundColor(isTotal ? AppColors.textPrimary : AppColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isDiscount ? AppColors.success : (isTotal ? AppColors.primary : AppColors.textPrimary))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PriceTag(price: 12.99, size: .small)
        PriceTag(price: 12.99, size: .medium)
        PriceTag(price: 12.99, originalPrice: 15.99, size: .large)
        
        Divider()
        
        VStack(spacing: 8) {
            PriceSummaryRow(label: "Subtotal", value: "$45.97")
            PriceSummaryRow(label: "Discount", value: "-$5.00", isDiscount: true)
            PriceSummaryRow(label: "Tax", value: "$3.68")
            Divider()
            PriceSummaryRow(label: "Total", value: "$44.65", isTotal: true)
        }
        .padding()
    }
    .padding()
}

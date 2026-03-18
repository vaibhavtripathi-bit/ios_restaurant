import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.buttonHeight)
            .background(isDisabled ? AppColors.textTertiary : AppColors.primary)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .foregroundColor(AppColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.buttonHeight)
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
        }
    }
}

struct SmallButton: View {
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    
    enum Style {
        case primary
        case secondary
        case destructive
    }
    
    init(title: String, icon: String? = nil, style: Style = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return AppColors.primary
        case .secondary: return AppColors.surface
        case .destructive: return AppColors.error
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: return .white
        case .secondary: return AppColors.primary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(AppConstants.Layout.smallCornerRadius)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Add to Cart", icon: "cart.badge.plus", action: {})
        PrimaryButton(title: "Loading...", isLoading: true, action: {})
        PrimaryButton(title: "Disabled", isDisabled: true, action: {})
        SecondaryButton(title: "View Menu", icon: "menucard", action: {})
        
        HStack {
            SmallButton(title: "Add", icon: "plus", action: {})
            SmallButton(title: "Edit", icon: "pencil", style: .secondary, action: {})
            SmallButton(title: "Delete", icon: "trash", style: .destructive, action: {})
        }
    }
    .padding()
}

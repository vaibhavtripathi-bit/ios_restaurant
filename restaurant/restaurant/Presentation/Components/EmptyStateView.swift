import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.textTertiary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                PrimaryButton(title: buttonTitle, action: buttonAction)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppConstants.Layout.largePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(AppColors.error)
            
            Text("Oops!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            PrimaryButton(title: "Try Again", icon: "arrow.clockwise", action: retryAction)
                .frame(maxWidth: 200)
        }
        .padding(AppConstants.Layout.largePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        EmptyStateView(
            icon: "cart",
            title: "Your Cart is Empty",
            message: "Looks like you haven't added any items yet.",
            buttonTitle: "Browse Menu",
            buttonAction: {}
        )
        
        Divider()
        
        ErrorView(message: "Unable to load menu. Please check your connection.", retryAction: {})
    }
}

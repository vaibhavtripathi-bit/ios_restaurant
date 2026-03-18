import SwiftUI

extension View {
    func cardStyle(padding: CGFloat = AppConstants.Layout.defaultPadding) -> some View {
        self
            .padding(padding)
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: AppConstants.Layout.cardShadowRadius, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppConstants.Layout.buttonHeight)
            .background(AppColors.primary)
            .cornerRadius(AppConstants.Layout.cornerRadius)
    }
    
    func secondaryButtonStyle() -> some View {
        self
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
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func onTapGestureHideKeyboard() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}

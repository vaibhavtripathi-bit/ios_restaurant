import SwiftUI

struct LoadingView: View {
    var message: String = "Loading..."
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LoadingOverlay: View {
    let isLoading: Bool
    var message: String = "Loading..."
    
    var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(.ultraThinMaterial)
                .cornerRadius(AppConstants.Layout.cornerRadius)
            }
        }
    }
}

struct ShimmerView: View {
    @State private var isAnimating = false
    
    var body: some View {
        LinearGradient(
            colors: [
                AppColors.surfaceSecondary.opacity(0.5),
                AppColors.surfaceSecondary,
                AppColors.surfaceSecondary.opacity(0.5)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .offset(x: isAnimating ? 200 : -200)
        .animation(
            Animation.linear(duration: 1.5)
                .repeatForever(autoreverses: false),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
    }
}

struct SkeletonCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: AppConstants.Layout.smallCornerRadius)
                .fill(AppColors.surfaceSecondary)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.surfaceSecondary)
                    .frame(height: 16)
                    .frame(maxWidth: 150)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.surfaceSecondary)
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.surfaceSecondary)
                    .frame(height: 12)
                    .frame(maxWidth: 100)
            }
        }
        .padding(AppConstants.Layout.defaultPadding)
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

#Preview {
    VStack {
        LoadingView()
        
        SkeletonCard()
            .padding()
    }
}

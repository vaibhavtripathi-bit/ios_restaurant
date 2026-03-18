import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewModel: ProfileViewModel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if let viewModel = viewModel {
                    mainContent(viewModel: viewModel)
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("Profile")
        }
        .task {
            if viewModel == nil {
                viewModel = container.makeProfileViewModel()
            }
            await viewModel?.loadOrderHistory()
        }
    }
    
    @ViewBuilder
    private func mainContent(viewModel: ProfileViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader(viewModel: viewModel)
                statsSection(viewModel: viewModel)
                ordersSection(viewModel: viewModel)
            }
            .padding()
        }
    }
    
    private func profileHeader(viewModel: ProfileViewModel) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Text(viewModel.user.initials)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(spacing: 4) {
                Text(viewModel.user.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                
                if !viewModel.user.isGuest {
                    Text(viewModel.user.email)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
    
    private func statsSection(viewModel: ProfileViewModel) -> some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "bag.fill",
                value: "\(viewModel.totalOrdersCount)",
                label: "Orders"
            )
            
            StatCard(
                icon: "dollarsign.circle.fill",
                value: viewModel.totalSpent.asCompactCurrency,
                label: "Total Spent"
            )
        }
    }
    
    @ViewBuilder
    private func ordersSection(viewModel: ProfileViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order History")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if viewModel.isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    SkeletonCard()
                }
            } else if viewModel.orders.isEmpty {
                EmptyOrdersView()
            } else {
                ForEach(viewModel.orders) { order in
                    OrderHistoryCard(order: order)
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

struct OrderHistoryCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(String(order.id.prefix(8)).uppercased())")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(order.formattedDate)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                OrderStatusBadge(status: order.status)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(order.items.count) item\(order.items.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(order.orderType.displayName)
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                
                Spacer()
                
                Text(order.formattedTotal)
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

struct OrderStatusBadge: View {
    let status: Order.OrderStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.iconName)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .cornerRadius(AppConstants.Layout.smallCornerRadius)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return AppColors.warning
        case .confirmed, .preparing:
            return AppColors.info
        case .ready:
            return AppColors.success
        case .delivered:
            return AppColors.textSecondary
        case .cancelled:
            return AppColors.error
        }
    }
}

struct EmptyOrdersView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bag")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textTertiary)
            
            Text("No orders yet")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

#Preview {
    ProfileView()
        .environmentObject(DIContainer())
}

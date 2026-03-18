import SwiftUI
import MapKit

struct RestaurantInfoView: View {
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel: RestaurantViewModel = RestaurantViewModel(
        repository: RestaurantRepository()
    )

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if let restaurant = viewModel.restaurant {
                    mainContent(viewModel: viewModel, restaurant: restaurant)
                } else if viewModel.isLoading {
                    LoadingView(message: "Loading restaurant info...")
                } else if let error = viewModel.error {
                    ErrorView(message: error) {
                        Task { await viewModel.loadRestaurantInfo() }
                    }
                } else {
                    LoadingView()
                }
            }
            .navigationTitle("About Us")
        }
        .task {
            await viewModel.loadRestaurantInfo()
        }
    }
    
    private func mainContent(viewModel: RestaurantViewModel, restaurant: Restaurant) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection(restaurant: restaurant, viewModel: viewModel)
                mapSection(viewModel: viewModel, restaurant: restaurant)
                hoursSection(restaurant: restaurant)
                contactSection(viewModel: viewModel, restaurant: restaurant)
                featuresSection(restaurant: restaurant)
            }
            .padding()
        }
    }
    
    private func headerSection(restaurant: Restaurant, viewModel: RestaurantViewModel) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primary)
            }
            
            Text(restaurant.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.isOpen ? AppColors.success : AppColors.error)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isOpen ? "Open Now" : "Closed")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(viewModel.isOpen ? AppColors.success : AppColors.error)
                
                Text("•")
                    .foregroundColor(AppColors.textTertiary)
                
                Text(viewModel.todayHours)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(restaurant.description)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
    
    private func mapSection(viewModel: RestaurantViewModel, restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            Map(position: .constant(MapCameraPosition.region(
                MKCoordinateRegion(
                    center: viewModel.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            ))) {
                Marker(restaurant.name, coordinate: restaurant.coordinate)
                    .tint(AppColors.primary)
            }
            .frame(height: 180)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .allowsHitTesting(false)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(AppColors.primary)
                
                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Button {
                    viewModel.openInMaps()
                } label: {
                    Text("Directions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
    
    private func hoursSection(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hours")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                ForEach(restaurant.hours) { dayHours in
                    HStack {
                        Text(dayHours.day.rawValue)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(dayHours.displayHours)
                            .font(.subheadline)
                            .foregroundColor(dayHours.isClosed ? AppColors.error : AppColors.textSecondary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    
                    if dayHours.day != .sunday {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
    
    private func contactSection(viewModel: RestaurantViewModel, restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 0) {
                ContactRow(icon: "phone.fill", label: "Phone", value: restaurant.phone) {
                    viewModel.call()
                }
                
                Divider().padding(.horizontal)
                
                ContactRow(icon: "envelope.fill", label: "Email", value: restaurant.email) {
                    viewModel.email()
                }
                
                if let website = restaurant.website {
                    Divider().padding(.horizontal)
                    
                    ContactRow(icon: "globe", label: "Website", value: website) {
                        if let url = URL(string: website) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .background(AppColors.surface)
            .cornerRadius(AppConstants.Layout.cornerRadius)
        }
    }
    
    private func featuresSection(restaurant: Restaurant) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(restaurant.features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                            .font(.caption)
                        
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.surface)
                    .cornerRadius(AppConstants.Layout.smallCornerRadius)
                }
            }
        }
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            .padding()
        }
    }
}

extension Restaurant: Identifiable {
    var id: String { name }
}

#Preview {
    RestaurantInfoView()
        .environmentObject(DIContainer())
}

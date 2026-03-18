import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var selectedTab: Tab = .menu

    enum Tab: String, CaseIterable {
        case menu = "Menu"
        case cart = "Cart"
        case reservations = "Reserve"
        case info = "Info"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .menu: return "menucard"
            case .cart: return "cart"
            case .reservations: return "calendar"
            case .info: return "info.circle"
            case .profile: return "person"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MenuView(cartViewModel: container.sharedCartViewModel)
                .tabItem { Label(Tab.menu.rawValue, systemImage: Tab.menu.icon) }
                .tag(Tab.menu)

            CartView(viewModel: container.sharedCartViewModel)
                .tabItem { Label(Tab.cart.rawValue, systemImage: Tab.cart.icon) }
                .tag(Tab.cart)
                .badge(container.sharedCartViewModel.itemCount)

            ReservationView()
                .tabItem { Label(Tab.reservations.rawValue, systemImage: Tab.reservations.icon) }
                .tag(Tab.reservations)

            RestaurantInfoView()
                .tabItem { Label(Tab.info.rawValue, systemImage: Tab.info.icon) }
                .tag(Tab.info)

            ProfileView()
                .tabItem { Label(Tab.profile.rawValue, systemImage: Tab.profile.icon) }
                .tag(Tab.profile)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(DIContainer())
}

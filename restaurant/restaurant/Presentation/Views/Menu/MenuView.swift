import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var container: DIContainer
    @State private var viewModel: MenuViewModel?
    @State private var cartViewModel: CartViewModel
    @State private var selectedItem: MenuItem?
    @State private var showingItemDetail = false
    
    init(cartViewModel: CartViewModel) {
        _cartViewModel = State(initialValue: cartViewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if let viewModel = viewModel {
                    mainContent(viewModel: viewModel)
                } else {
                    LoadingView(message: "Loading menu...")
                }
            }
            .navigationTitle(AppConstants.appName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    searchButton
                }
            }
            .sheet(isPresented: $showingItemDetail) {
                if let item = selectedItem {
                    MenuItemDetailView(
                        item: item,
                        cartViewModel: cartViewModel
                    )
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = container.makeMenuViewModel()
            }
            await viewModel?.loadInitialData()
        }
    }
    
    @ViewBuilder
    private func mainContent(viewModel: MenuViewModel) -> some View {
        VStack(spacing: 0) {
            if viewModel.showingSearch {
                searchBar(viewModel: viewModel)
            }
            
            if !viewModel.showingSearch {
                CategoryScrollView(
                    categories: viewModel.categories,
                    selectedCategory: viewModel.selectedCategory,
                    onSelect: { category in
                        Task {
                            await viewModel.selectCategory(category)
                        }
                    }
                )
                .padding(.vertical, 12)
            }
            
            if viewModel.isLoading {
                loadingContent
            } else if let error = viewModel.error {
                ErrorView(message: error) {
                    Task {
                        await viewModel.loadInitialData()
                    }
                }
            } else if viewModel.displayedItems.isEmpty {
                emptyContent(viewModel: viewModel)
            } else {
                menuList(viewModel: viewModel)
            }
        }
    }
    
    private var searchButton: some View {
        Button {
            withAnimation {
                viewModel?.showingSearch.toggle()
            }
        } label: {
            Image(systemName: viewModel?.showingSearch == true ? "xmark" : "magnifyingglass")
                .foregroundColor(AppColors.primary)
        }
    }
    
    @ViewBuilder
    private func searchBar(viewModel: MenuViewModel) -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textTertiary)
            
            TextField("Search menu...", text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.searchQuery = $0 }
            ))
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
            
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .padding(.horizontal)
        .padding(.bottom, 8)
        .onChange(of: viewModel.searchQuery) { _, _ in
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await viewModel.search()
            }
        }
    }
    
    private var loadingContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { _ in
                    SkeletonCard()
                }
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private func emptyContent(viewModel: MenuViewModel) -> some View {
        if viewModel.showingSearch {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "Try a different search term"
            )
        } else {
            EmptyStateView(
                icon: "menucard",
                title: "No Items",
                message: "This category is empty"
            )
        }
    }
    
    private func menuList(viewModel: MenuViewModel) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.displayedItems) { item in
                    MenuItemCard(item: item) {
                        Task {
                            await cartViewModel.addToCart(item)
                        }
                    }
                    .onTapGesture {
                        selectedItem = item
                        showingItemDetail = true
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView(cartViewModel: CartViewModel(
        getCartUseCase: GetCartUseCase(repository: CartRepository()),
        addToCartUseCase: AddToCartUseCase(repository: CartRepository()),
        updateCartItemUseCase: UpdateCartItemUseCase(repository: CartRepository()),
        removeFromCartUseCase: RemoveFromCartUseCase(repository: CartRepository()),
        clearCartUseCase: ClearCartUseCase(repository: CartRepository()),
        applyPromoCodeUseCase: ApplyPromoCodeUseCase(repository: CartRepository()),
        placeOrderUseCase: PlaceOrderUseCase(orderRepository: OrderRepository(), cartRepository: CartRepository())
    ))
    .environmentObject(DIContainer())
}

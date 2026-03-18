import Combine
import Foundation

final class MenuViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var categories: [Category] = []
    @Published private(set) var menuItems: [MenuItem] = []
    @Published private(set) var searchResults: [MenuItem] = []
    @Published private(set) var selectedCategory: Category?
    @Published private(set) var isLoading = false
    @Published private(set) var isSearching = false
    @Published private(set) var error: String?
    @Published var searchQuery: String = ""
    @Published var showingSearch = false

    // MARK: - Dependencies

    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let getMenuItemsUseCase: GetMenuItemsUseCaseProtocol
    private let searchMenuUseCase: SearchMenuUseCaseProtocol

    init(
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        getMenuItemsUseCase: GetMenuItemsUseCaseProtocol,
        searchMenuUseCase: SearchMenuUseCaseProtocol
    ) {
        self.getCategoriesUseCase = getCategoriesUseCase
        self.getMenuItemsUseCase = getMenuItemsUseCase
        self.searchMenuUseCase = searchMenuUseCase
    }

    // MARK: - Computed Properties

    var displayedItems: [MenuItem] {
        if !searchQuery.isEmpty { return searchResults }
        return menuItems
    }

    // MARK: - Actions

    @MainActor
    func loadInitialData() async {
        guard categories.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            categories = try await getCategoriesUseCase.execute()
            if let firstCategory = categories.first {
                await selectCategory(firstCategory)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func selectCategory(_ category: Category?) async {
        selectedCategory = category
        isLoading = true
        error = nil

        do {
            menuItems = try await getMenuItemsUseCase.execute(categoryId: category?.id)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func search() async {
        guard !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        do {
            searchResults = try await searchMenuUseCase.execute(query: searchQuery)
        } catch {
            self.error = error.localizedDescription
        }

        isSearching = false
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        showingSearch = false
    }

    func clearError() {
        error = nil
    }
}

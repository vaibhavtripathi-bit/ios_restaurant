import Foundation

final class MenuRepository: MenuRepositoryProtocol, @unchecked Sendable {
    private let dataSource: MockDataSource
    
    init(dataSource: MockDataSource = .shared) {
        self.dataSource = dataSource
    }
    
    func getCategories() async throws -> [Category] {
        try await simulateNetworkDelay()
        return dataSource.categories.sorted { $0.displayOrder < $1.displayOrder }
    }
    
    func getMenuItems(for categoryId: String?) async throws -> [MenuItem] {
        try await simulateNetworkDelay()
        
        if let categoryId = categoryId {
            return dataSource.menuItems.filter { $0.categoryId == categoryId }
        }
        return dataSource.menuItems
    }
    
    func getMenuItem(id: String) async throws -> MenuItem {
        try await simulateNetworkDelay()
        
        guard let item = dataSource.menuItems.first(where: { $0.id == id }) else {
            throw MenuError.itemNotFound
        }
        return item
    }
    
    func searchMenuItems(query: String) async throws -> [MenuItem] {
        try await simulateNetworkDelay()
        
        let lowercasedQuery = query.lowercased()
        return dataSource.menuItems.filter { item in
            item.name.lowercased().contains(lowercasedQuery) ||
            item.description.lowercased().contains(lowercasedQuery) ||
            item.ingredients.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    private func simulateNetworkDelay() async throws {
        try await Task.sleep(nanoseconds: UInt64.random(in: 200_000_000...500_000_000))
    }
}

enum MenuError: LocalizedError {
    case itemNotFound
    case categoryNotFound
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Menu item not found"
        case .categoryNotFound:
            return "Category not found"
        }
    }
}

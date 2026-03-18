import Foundation

protocol GetMenuItemsUseCaseProtocol: Sendable {
    func execute(categoryId: String?) async throws -> [MenuItem]
}

final class GetMenuItemsUseCase: GetMenuItemsUseCaseProtocol, Sendable {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(categoryId: String? = nil) async throws -> [MenuItem] {
        try await repository.getMenuItems(for: categoryId)
    }
}

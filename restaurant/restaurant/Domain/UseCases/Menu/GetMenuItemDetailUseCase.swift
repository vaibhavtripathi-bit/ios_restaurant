import Foundation

protocol GetMenuItemDetailUseCaseProtocol: Sendable {
    func execute(itemId: String) async throws -> MenuItem
}

final class GetMenuItemDetailUseCase: GetMenuItemDetailUseCaseProtocol, Sendable {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(itemId: String) async throws -> MenuItem {
        try await repository.getMenuItem(id: itemId)
    }
}

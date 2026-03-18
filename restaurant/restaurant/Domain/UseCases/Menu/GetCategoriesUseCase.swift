import Foundation

protocol GetCategoriesUseCaseProtocol: Sendable {
    func execute() async throws -> [Category]
}

final class GetCategoriesUseCase: GetCategoriesUseCaseProtocol, Sendable {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Category] {
        try await repository.getCategories()
    }
}

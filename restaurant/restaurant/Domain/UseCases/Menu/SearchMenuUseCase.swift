import Foundation

protocol SearchMenuUseCaseProtocol: Sendable {
    func execute(query: String) async throws -> [MenuItem]
}

final class SearchMenuUseCase: SearchMenuUseCaseProtocol, Sendable {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [MenuItem] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        return try await repository.searchMenuItems(query: query)
    }
}

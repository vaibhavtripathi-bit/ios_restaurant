import Foundation

protocol GetCartUseCaseProtocol: Sendable {
    func execute() async throws -> Cart
}

final class GetCartUseCase: GetCartUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> Cart {
        try await repository.getCart()
    }
}

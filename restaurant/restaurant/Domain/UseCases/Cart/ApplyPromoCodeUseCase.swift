import Foundation

protocol ApplyPromoCodeUseCaseProtocol: Sendable {
    func execute(code: String) async throws -> Cart
}

final class ApplyPromoCodeUseCase: ApplyPromoCodeUseCaseProtocol, Sendable {
    private let repository: CartRepositoryProtocol
    
    init(repository: CartRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(code: String) async throws -> Cart {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmedCode.isEmpty else {
            throw CartError.promoCodeInvalid
        }
        return try await repository.applyPromoCode(trimmedCode)
    }
}

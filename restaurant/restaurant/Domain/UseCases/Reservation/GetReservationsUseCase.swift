import Foundation

protocol GetReservationsUseCaseProtocol: Sendable {
    func execute() async throws -> [Reservation]
}

final class GetReservationsUseCase: GetReservationsUseCaseProtocol, Sendable {
    private let repository: ReservationRepositoryProtocol
    
    init(repository: ReservationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Reservation] {
        try await repository.getReservations()
    }
}

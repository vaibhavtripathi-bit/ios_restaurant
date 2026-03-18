import Foundation

protocol CancelReservationUseCaseProtocol: Sendable {
    func execute(reservationId: String) async throws -> Reservation
}

final class CancelReservationUseCase: CancelReservationUseCaseProtocol, Sendable {
    private let repository: ReservationRepositoryProtocol
    
    init(repository: ReservationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(reservationId: String) async throws -> Reservation {
        try await repository.cancelReservation(id: reservationId)
    }
}

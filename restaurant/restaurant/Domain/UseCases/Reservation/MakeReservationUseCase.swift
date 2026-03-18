import Foundation

protocol MakeReservationUseCaseProtocol: Sendable {
    func execute(
        date: Date,
        time: String,
        partySize: Int,
        customerName: String,
        customerPhone: String,
        customerEmail: String?,
        specialRequests: String?
    ) async throws -> Reservation
}

final class MakeReservationUseCase: MakeReservationUseCaseProtocol, Sendable {
    private let repository: ReservationRepositoryProtocol
    
    init(repository: ReservationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        date: Date,
        time: String,
        partySize: Int,
        customerName: String,
        customerPhone: String,
        customerEmail: String?,
        specialRequests: String?
    ) async throws -> Reservation {
        guard partySize > 0 else {
            throw ReservationError.invalidPartySize
        }
        
        guard date >= Calendar.current.startOfDay(for: Date()) else {
            throw ReservationError.invalidDate
        }
        
        let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = customerPhone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty, !trimmedPhone.isEmpty else {
            throw ReservationError.missingContactInfo
        }
        
        return try await repository.makeReservation(
            date: date,
            time: time,
            partySize: partySize,
            customerName: trimmedName,
            customerPhone: trimmedPhone,
            customerEmail: customerEmail,
            specialRequests: specialRequests
        )
    }
}

import Foundation

protocol GetAvailableSlotsUseCaseProtocol: Sendable {
    func execute(date: Date, partySize: Int) async throws -> [TimeSlot]
}

final class GetAvailableSlotsUseCase: GetAvailableSlotsUseCaseProtocol, Sendable {
    private let repository: ReservationRepositoryProtocol
    
    init(repository: ReservationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(date: Date, partySize: Int) async throws -> [TimeSlot] {
        guard partySize > 0 else {
            throw ReservationError.invalidPartySize
        }
        return try await repository.getAvailableSlots(date: date, partySize: partySize)
    }
}

enum ReservationError: LocalizedError {
    case invalidPartySize
    case slotUnavailable
    case reservationNotFound
    case cannotCancel
    case invalidDate
    case missingContactInfo
    
    var errorDescription: String? {
        switch self {
        case .invalidPartySize:
            return "Party size must be at least 1"
        case .slotUnavailable:
            return "This time slot is no longer available"
        case .reservationNotFound:
            return "Reservation not found"
        case .cannotCancel:
            return "This reservation cannot be cancelled"
        case .invalidDate:
            return "Please select a valid date"
        case .missingContactInfo:
            return "Please provide contact information"
        }
    }
}

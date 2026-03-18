import Foundation

protocol ReservationRepositoryProtocol: Sendable {
    func getAvailableSlots(date: Date, partySize: Int) async throws -> [TimeSlot]
    func makeReservation(
        date: Date,
        time: String,
        partySize: Int,
        customerName: String,
        customerPhone: String,
        customerEmail: String?,
        specialRequests: String?
    ) async throws -> Reservation
    func getReservations() async throws -> [Reservation]
    func cancelReservation(id: String) async throws -> Reservation
}

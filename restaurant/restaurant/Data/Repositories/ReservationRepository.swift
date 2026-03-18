import Foundation

actor ReservationRepository: ReservationRepositoryProtocol {
    private var reservations: [Reservation] = []
    private let dataSource: MockDataSource
    
    init(dataSource: MockDataSource = .shared) {
        self.dataSource = dataSource
    }
    
    func getAvailableSlots(date: Date, partySize: Int) async throws -> [TimeSlot] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return dataSource.generateTimeSlots(for: date)
    }
    
    func makeReservation(
        date: Date,
        time: String,
        partySize: Int,
        customerName: String,
        customerPhone: String,
        customerEmail: String?,
        specialRequests: String?
    ) async throws -> Reservation {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let confirmationCode = generateConfirmationCode()
        
        let reservation = Reservation(
            id: UUID().uuidString,
            date: date,
            time: time,
            partySize: partySize,
            customerName: customerName,
            customerPhone: customerPhone,
            customerEmail: customerEmail,
            specialRequests: specialRequests,
            status: .confirmed,
            confirmationCode: confirmationCode,
            createdAt: Date()
        )
        
        reservations.insert(reservation, at: 0)
        return reservation
    }
    
    func getReservations() async throws -> [Reservation] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return reservations
    }
    
    func cancelReservation(id: String) async throws -> Reservation {
        guard let index = reservations.firstIndex(where: { $0.id == id }) else {
            throw ReservationError.reservationNotFound
        }
        
        let reservation = reservations[index]
        guard reservation.status == .confirmed || reservation.status == .pending else {
            throw ReservationError.cannotCancel
        }
        
        let cancelledReservation = Reservation(
            id: reservation.id,
            date: reservation.date,
            time: reservation.time,
            partySize: reservation.partySize,
            customerName: reservation.customerName,
            customerPhone: reservation.customerPhone,
            customerEmail: reservation.customerEmail,
            specialRequests: reservation.specialRequests,
            status: .cancelled,
            confirmationCode: reservation.confirmationCode,
            createdAt: reservation.createdAt
        )
        
        reservations[index] = cancelledReservation
        return cancelledReservation
    }
    
    private func generateConfirmationCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        
        var code = ""
        for _ in 0..<3 {
            code += String(letters.randomElement()!)
        }
        for _ in 0..<3 {
            code += String(numbers.randomElement()!)
        }
        return code
    }
}

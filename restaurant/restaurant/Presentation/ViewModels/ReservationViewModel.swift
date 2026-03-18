import Combine
import Foundation

final class ReservationViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var availableSlots: [TimeSlot] = []
    @Published private(set) var reservations: [Reservation] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var error: String?
    @Published private(set) var lastCreatedReservation: Reservation?
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: String?
    @Published var partySize: Int = 2
    @Published var customerName: String = ""
    @Published var customerPhone: String = ""
    @Published var customerEmail: String = ""
    @Published var specialRequests: String = ""
    @Published var showingConfirmation = false

    // MARK: - Dependencies

    private let getAvailableSlotsUseCase: GetAvailableSlotsUseCaseProtocol
    private let makeReservationUseCase: MakeReservationUseCaseProtocol
    private let getReservationsUseCase: GetReservationsUseCaseProtocol
    private let cancelReservationUseCase: CancelReservationUseCaseProtocol

    init(
        getAvailableSlotsUseCase: GetAvailableSlotsUseCaseProtocol,
        makeReservationUseCase: MakeReservationUseCaseProtocol,
        getReservationsUseCase: GetReservationsUseCaseProtocol,
        cancelReservationUseCase: CancelReservationUseCaseProtocol
    ) {
        self.getAvailableSlotsUseCase = getAvailableSlotsUseCase
        self.makeReservationUseCase = makeReservationUseCase
        self.getReservationsUseCase = getReservationsUseCase
        self.cancelReservationUseCase = cancelReservationUseCase
    }

    // MARK: - Computed Properties

    var canMakeReservation: Bool {
        selectedTime != nil &&
        !customerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !customerPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var minDate: Date { Calendar.current.startOfDay(for: Date()) }

    var maxDate: Date {
        Calendar.current.date(byAdding: .day, value: AppConstants.Reservation.maxAdvanceBookingDays, to: Date()) ?? Date()
    }

    var upcomingReservations: [Reservation] {
        reservations.filter { $0.date >= Calendar.current.startOfDay(for: Date()) && $0.status != .cancelled }
    }

    var pastReservations: [Reservation] {
        reservations.filter { $0.date < Calendar.current.startOfDay(for: Date()) || $0.status == .cancelled }
    }

    // MARK: - Actions

    @MainActor
    func loadAvailableSlots() async {
        isLoading = true
        error = nil
        selectedTime = nil

        do {
            availableSlots = try await getAvailableSlotsUseCase.execute(date: selectedDate, partySize: partySize)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func loadReservations() async {
        isLoading = true

        do {
            reservations = try await getReservationsUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    @MainActor
    func makeReservation() async {
        guard let selectedTime = selectedTime else { error = "Please select a time"; return }

        isSubmitting = true
        error = nil

        do {
            let reservation = try await makeReservationUseCase.execute(
                date: selectedDate,
                time: selectedTime,
                partySize: partySize,
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail.isEmpty ? nil : customerEmail,
                specialRequests: specialRequests.isEmpty ? nil : specialRequests
            )
            lastCreatedReservation = reservation
            reservations.insert(reservation, at: 0)
            resetForm()
            showingConfirmation = true
        } catch {
            self.error = error.localizedDescription
        }

        isSubmitting = false
    }

    @MainActor
    func cancelReservation(_ reservation: Reservation) async {
        do {
            let cancelled = try await cancelReservationUseCase.execute(reservationId: reservation.id)
            if let index = reservations.firstIndex(where: { $0.id == reservation.id }) {
                reservations[index] = cancelled
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func resetForm() {
        selectedDate = Date()
        selectedTime = nil
        partySize = 2
        customerName = ""
        customerPhone = ""
        customerEmail = ""
        specialRequests = ""
        availableSlots = []
    }

    func clearError() { error = nil }

    func dismissConfirmation() {
        showingConfirmation = false
        lastCreatedReservation = nil
    }
}

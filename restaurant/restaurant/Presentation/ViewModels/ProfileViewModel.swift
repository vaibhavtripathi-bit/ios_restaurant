import Combine
import Foundation

final class ProfileViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var user: User = .guest
    @Published private(set) var orders: [Order] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?

    // MARK: - Dependencies

    private let getOrderHistoryUseCase: GetOrderHistoryUseCaseProtocol

    init(getOrderHistoryUseCase: GetOrderHistoryUseCaseProtocol) {
        self.getOrderHistoryUseCase = getOrderHistoryUseCase
    }

    // MARK: - Computed Properties

    var activeOrders: [Order] { orders.filter { $0.status.isActive } }
    var completedOrders: [Order] { orders.filter { !$0.status.isActive } }
    var totalOrdersCount: Int { orders.count }
    var totalSpent: Double { orders.filter { $0.status != .cancelled }.reduce(0) { $0 + $1.total } }

    // MARK: - Actions

    @MainActor
    func loadOrderHistory() async {
        isLoading = true
        error = nil

        do {
            orders = try await getOrderHistoryUseCase.execute()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func clearError() { error = nil }
}

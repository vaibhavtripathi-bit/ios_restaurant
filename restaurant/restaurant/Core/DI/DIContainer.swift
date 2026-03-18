import Combine
import Foundation
import Observation

// DIContainer uses a class (not @Observable) to allow lazy stored properties.
// ViewModels are created fresh each time via factory methods to avoid lazy+@Observable conflict.
final class DIContainer: ObservableObject {

    // MARK: - Data Sources

    private let mockDataSource: MockDataSource = .shared

    // MARK: - Repositories (initialized once on first access via lazy)

    private lazy var menuRepository: MenuRepositoryProtocol = MenuRepository(dataSource: mockDataSource)
    private lazy var cartRepository: CartRepositoryProtocol = CartRepository()
    private lazy var orderRepository: OrderRepositoryProtocol = OrderRepository()
    private lazy var reservationRepository: ReservationRepositoryProtocol = ReservationRepository(dataSource: mockDataSource)
    private lazy var restaurantRepository: RestaurantRepositoryProtocol = RestaurantRepository(dataSource: mockDataSource)

    // MARK: - Menu Use Cases

    private lazy var getCategoriesUseCase: GetCategoriesUseCaseProtocol = GetCategoriesUseCase(repository: menuRepository)
    private lazy var getMenuItemsUseCase: GetMenuItemsUseCaseProtocol = GetMenuItemsUseCase(repository: menuRepository)
    private lazy var getMenuItemDetailUseCase: GetMenuItemDetailUseCaseProtocol = GetMenuItemDetailUseCase(repository: menuRepository)
    private lazy var searchMenuUseCase: SearchMenuUseCaseProtocol = SearchMenuUseCase(repository: menuRepository)

    // MARK: - Cart Use Cases

    private lazy var getCartUseCase: GetCartUseCaseProtocol = GetCartUseCase(repository: cartRepository)
    private lazy var addToCartUseCase: AddToCartUseCaseProtocol = AddToCartUseCase(repository: cartRepository)
    private lazy var updateCartItemUseCase: UpdateCartItemUseCaseProtocol = UpdateCartItemUseCase(repository: cartRepository)
    private lazy var removeFromCartUseCase: RemoveFromCartUseCaseProtocol = RemoveFromCartUseCase(repository: cartRepository)
    private lazy var clearCartUseCase: ClearCartUseCaseProtocol = ClearCartUseCase(repository: cartRepository)
    private lazy var applyPromoCodeUseCase: ApplyPromoCodeUseCaseProtocol = ApplyPromoCodeUseCase(repository: cartRepository)

    // MARK: - Order Use Cases

    private lazy var placeOrderUseCase: PlaceOrderUseCaseProtocol = PlaceOrderUseCase(
        orderRepository: orderRepository,
        cartRepository: cartRepository
    )
    private lazy var getOrderHistoryUseCase: GetOrderHistoryUseCaseProtocol = GetOrderHistoryUseCase(repository: orderRepository)
    private lazy var cancelOrderUseCase: CancelOrderUseCaseProtocol = CancelOrderUseCase(repository: orderRepository)

    // MARK: - Reservation Use Cases

    private lazy var getAvailableSlotsUseCase: GetAvailableSlotsUseCaseProtocol = GetAvailableSlotsUseCase(repository: reservationRepository)
    private lazy var makeReservationUseCase: MakeReservationUseCaseProtocol = MakeReservationUseCase(repository: reservationRepository)
    private lazy var getReservationsUseCase: GetReservationsUseCaseProtocol = GetReservationsUseCase(repository: reservationRepository)
    private lazy var cancelReservationUseCase: CancelReservationUseCaseProtocol = CancelReservationUseCase(repository: reservationRepository)

    // MARK: - Shared CartViewModel (single instance so cart state is shared across tabs)

    lazy var sharedCartViewModel: CartViewModel = makeCartViewModel()

    // MARK: - ViewModel Factories

    func makeMenuViewModel() -> MenuViewModel {
        MenuViewModel(
            getCategoriesUseCase: getCategoriesUseCase,
            getMenuItemsUseCase: getMenuItemsUseCase,
            searchMenuUseCase: searchMenuUseCase
        )
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(
            getCartUseCase: getCartUseCase,
            addToCartUseCase: addToCartUseCase,
            updateCartItemUseCase: updateCartItemUseCase,
            removeFromCartUseCase: removeFromCartUseCase,
            clearCartUseCase: clearCartUseCase,
            applyPromoCodeUseCase: applyPromoCodeUseCase,
            placeOrderUseCase: placeOrderUseCase
        )
    }

    func makeReservationViewModel() -> ReservationViewModel {
        ReservationViewModel(
            getAvailableSlotsUseCase: getAvailableSlotsUseCase,
            makeReservationUseCase: makeReservationUseCase,
            getReservationsUseCase: getReservationsUseCase,
            cancelReservationUseCase: cancelReservationUseCase
        )
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(getOrderHistoryUseCase: getOrderHistoryUseCase)
    }

    func makeRestaurantViewModel() -> RestaurantViewModel {
        RestaurantViewModel(repository: restaurantRepository)
    }
}

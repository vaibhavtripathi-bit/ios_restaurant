import Combine
import Foundation
import MapKit
import UIKit

final class RestaurantViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var restaurant: Restaurant?
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    // MARK: - Dependencies

    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Computed Properties

    var isOpen: Bool {
        restaurant?.isCurrentlyOpen ?? false
    }

    var todayHours: String {
        guard let hours = restaurant?.todayHours else { return "Hours unavailable" }
        return hours.displayHours
    }

    // MARK: - Actions

    @MainActor
    func loadRestaurantInfo() async {
        guard restaurant == nil else { return }

        isLoading = true
        error = nil

        do {
            restaurant = try await repository.getRestaurantInfo()
            if let coord = restaurant?.coordinate {
                coordinate = coord
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func openInMaps() {
        guard let restaurant = restaurant else { return }
        let placemark = MKPlacemark(coordinate: restaurant.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func call() {
        guard let restaurant = restaurant,
              let url = URL(string: "tel://\(restaurant.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") else { return }
        UIApplication.shared.open(url)
    }

    func email() {
        guard let restaurant = restaurant,
              let url = URL(string: "mailto:\(restaurant.email)") else { return }
        UIApplication.shared.open(url)
    }

    func clearError() {
        error = nil
    }
}

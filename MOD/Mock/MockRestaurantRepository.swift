import Foundation
import CoreLocation

// MARK: - Mock Restaurant Repository
class MockRestaurantRepository: RestaurantRepositoryProtocol {
    static let shared = MockRestaurantRepository()
    
    private init() {}
    
    func getRestaurants(location: CLLocation? = nil, radius: Double = 50000) async throws -> [Restaurant] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        var restaurants = MockData.restaurants
        
        // Calculate distances if location is provided
        if let location = location {
            restaurants = restaurants.map { restaurant in
                var updatedRestaurant = restaurant
                let restaurantLocation = CLLocation(
                    latitude: restaurant.location.latitude,
                    longitude: restaurant.location.longitude
                )
                let distanceInMeters = location.distance(from: restaurantLocation)
                updatedRestaurant.distance = distanceInMeters / 1000.0 // Convert to km
                return updatedRestaurant
            }
        }
        
        return restaurants.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
    }
    
    func getRestaurant(id: String) async throws -> Restaurant {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        guard let restaurant = MockData.restaurants.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return restaurant
    }
    
    func searchRestaurants(query: String, location: CLLocation? = nil) async throws -> [Restaurant] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let restaurants = try await getRestaurants(location: location)
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(query) ||
            restaurant.city.localizedCaseInsensitiveContains(query) ||
            restaurant.address.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getOfferBanners() async throws -> [OfferBanner] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        return MockData.offerBanners.filter { $0.isActiveNow }
    }
}

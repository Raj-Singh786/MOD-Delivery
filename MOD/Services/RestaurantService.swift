import Foundation
import CoreLocation
import Combine

// MARK: - Restaurant Service Protocol
protocol RestaurantServiceProtocol {
    func getRestaurants(location: CLLocation?, radius: Double) async throws -> [Restaurant]
    func getRestaurant(id: String) async throws -> Restaurant
    func searchRestaurants(query: String, location: CLLocation?) async throws -> [Restaurant]
    func getOfferBanners() async throws -> [OfferBanner]
}

// MARK: - Restaurant Service Implementation
class RestaurantService: RestaurantServiceProtocol {
    static let shared = RestaurantService()
    
    private let apiService: APIServiceProtocol
    
    private init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func getRestaurants(
        location: CLLocation? = nil,
        radius: Double = 50000
    ) async throws -> [Restaurant] {

        var restaurants = MockData.restaurants

        guard let currentLocation = location else {
            return restaurants
        }

        restaurants = restaurants.compactMap { restaurant in

            var updatedRestaurant = restaurant

            let restaurantLocation = CLLocation(
                latitude: restaurant.location.latitude,
                longitude: restaurant.location.longitude
            )

            let distanceInMeters = currentLocation.distance(
                from: restaurantLocation
            )

            // Ignore restaurants outside the radius
            guard distanceInMeters <= radius else {
                return nil
            }

            // Store distance in kilometers
            updatedRestaurant.distance = distanceInMeters / 1000.0

            return updatedRestaurant
        }

        return restaurants.sorted {
            ($0.distance ?? Double.infinity) <
            ($1.distance ?? Double.infinity)
        }
    }
    
    func getRestaurant(id: String) async throws -> Restaurant {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/restaurants/\(id)", queryParams: nil)
        
        // Mock response
        guard let restaurant = MockData.restaurants.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        
        return restaurant
    }
    
    func searchRestaurants(query: String, location: CLLocation? = nil) async throws -> [Restaurant] {
        // TODO: Replace with actual API call
        // let queryParams = ["query": query]
        // return try await apiService.get(endpoint: "/restaurants/search", queryParams: queryParams)
        
        // Mock response
        let restaurants = try await getRestaurants(location: location)
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(query) ||
            restaurant.city.localizedCaseInsensitiveContains(query) ||
            restaurant.address.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getOfferBanners() async throws -> [OfferBanner] {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/marketing/banners", queryParams: nil)
        
        // Mock response
        return MockData.offerBanners.filter { $0.isActiveNow }
    }
}

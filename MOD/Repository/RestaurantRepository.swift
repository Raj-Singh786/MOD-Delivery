import Foundation
import CoreLocation
import Combine

// MARK: - Restaurant Repository Protocol
protocol RestaurantRepositoryProtocol {
    func getRestaurants(location: CLLocation?, radius: Double) async throws -> [Restaurant]
    func getRestaurant(id: String) async throws -> Restaurant
    func searchRestaurants(query: String, location: CLLocation?) async throws -> [Restaurant]
    func getOfferBanners() async throws -> [OfferBanner]
}

// MARK: - Restaurant Repository Implementation
class RestaurantRepository: RestaurantRepositoryProtocol {
    static let shared = RestaurantRepository()
    
    private let restaurantService: RestaurantServiceProtocol
    
    private init(restaurantService: RestaurantServiceProtocol = RestaurantService.shared) {
        self.restaurantService = restaurantService
    }
    
    func getRestaurants(location: CLLocation? = nil, radius: Double = 50000) async throws -> [Restaurant] {
        return try await restaurantService.getRestaurants(location: location, radius: radius)
    }
    
    func getRestaurant(id: String) async throws -> Restaurant {
        return try await restaurantService.getRestaurant(id: id)
    }
    
    func searchRestaurants(query: String, location: CLLocation? = nil) async throws -> [Restaurant] {
        return try await restaurantService.searchRestaurants(query: query, location: location)
    }
    
    func getOfferBanners() async throws -> [OfferBanner] {
        return try await restaurantService.getOfferBanners()
    }
}

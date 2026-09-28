import Foundation
import Combine

// MARK: - App State
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Customer?
    @Published var selectedOrderType: OrderType = .delivery
    @Published var selectedRestaurant: Restaurant?
    @Published var userLocation: String = "Gurgaon, Haryana"
    @Published var isLocationEnabled: Bool = false
    @Published var isFirstLaunch: Bool = true
    @Published var hasRequestedTrackingPermission: Bool = false
    
    private let authenticationService: AuthenticationService
    private let userDefaults = UserDefaults.standard
    
    private init() {
        self.authenticationService = AuthenticationService.shared
        loadAppState()
        setupAuthenticationObserver()
    }
    
    // MARK: - Authentication
    
    private func setupAuthenticationObserver() {
        authenticationService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        authenticationService.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }
    
    func login(customer: Customer) {
        // This will be called by the authentication service
        saveAppState()
    }
    
    func logout() {
        Task {
            try? await authenticationService.logout()
            clearAppState()
        }
    }
    
    // MARK: - Order Type
    
    func setOrderType(_ orderType: OrderType) {
        selectedOrderType = orderType
        CartManager.shared.setOrderType(orderType)
        saveAppState()
    }
    
    // MARK: - Restaurant
    
    func setSelectedRestaurant(_ restaurant: Restaurant?) {
        selectedRestaurant = restaurant
        CartManager.shared.setRestaurant(restaurant)
        saveAppState()
    }
    
    // MARK: - Location
    
    func setUserLocation(_ location: String) {
        userLocation = location
        saveAppState()
    }
    
    func setLocationEnabled(_ enabled: Bool) {
        isLocationEnabled = enabled
        saveAppState()
    }
    
    // MARK: - Persistence
    
    private func saveAppState() {
        userDefaults.set(isAuthenticated, forKey: Constants.isLoggedInKey)
        userDefaults.set(selectedOrderType.rawValue, forKey: Constants.selectedOrderTypeKey)
        userDefaults.set(userLocation, forKey: "userLocation")
        userDefaults.set(isLocationEnabled, forKey: "isLocationEnabled")
        userDefaults.set(isFirstLaunch, forKey: "isFirstLaunch")
        userDefaults.set(hasRequestedTrackingPermission, forKey: "hasRequestedTrackingPermission")
        
        if let restaurant = selectedRestaurant,
           let encoded = try? JSONEncoder().encode(restaurant) {
            userDefaults.set(encoded, forKey: Constants.selectedRestaurantKey)
        } else {
            userDefaults.removeObject(forKey: Constants.selectedRestaurantKey)
        }
    }
    
    private func loadAppState() {
        isAuthenticated = userDefaults.bool(forKey: Constants.isLoggedInKey)
        
        if let orderTypeString = userDefaults.string(forKey: Constants.selectedOrderTypeKey),
           let orderType = OrderType(rawValue: orderTypeString) {
            selectedOrderType = orderType
        }
        
        userLocation = userDefaults.string(forKey: "userLocation") ?? "Gurgaon, Haryana"
        isLocationEnabled = userDefaults.bool(forKey: "isLocationEnabled")
        isFirstLaunch = userDefaults.bool(forKey: "isFirstLaunch")
        hasRequestedTrackingPermission = userDefaults.bool(forKey: "hasRequestedTrackingPermission")
        
        if let restaurantData = userDefaults.data(forKey: Constants.selectedRestaurantKey),
           let restaurant = try? JSONDecoder().decode(Restaurant.self, from: restaurantData) {
            selectedRestaurant = restaurant
        }
    }
    
    private func clearAppState() {
        userDefaults.removeObject(forKey: Constants.isLoggedInKey)
        userDefaults.removeObject(forKey: Constants.selectedRestaurantKey)
        userDefaults.removeObject(forKey: "userLocation")
        userDefaults.removeObject(forKey: "isLocationEnabled")
        
        // Keep first launch and tracking permission state
        isFirstLaunch = false
        hasRequestedTrackingPermission = true
        
        // Clear cart
        CartManager.shared.clearCart()
    }
    
    // MARK: - App Lifecycle
    
    func markFirstLaunchComplete() {
        isFirstLaunch = false
        saveAppState()
    }
    
    func markTrackingPermissionRequested() {
        hasRequestedTrackingPermission = true
        saveAppState()
    }
}

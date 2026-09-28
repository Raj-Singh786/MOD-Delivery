import Foundation

struct Constants {
    // API
    static let apiBaseURL = "https://api.modpizza.com/v1"
    static let apiTimeout: TimeInterval = 30.0
    
    // App Storage Keys
    static let isLoggedInKey = "isLoggedIn"
    static let userTokenKey = "userToken"
    static let guestCartKey = "guestCart"
    static let selectedOrderTypeKey = "selectedOrderType"
    static let selectedRestaurantKey = "selectedRestaurant"
    
    // Loyalty
    static let loyaltyPointsPerRupee = 1.0 // Default, will be overridden by backend
    
    // Pizza
    static let maxToppings = 40
    static let maxQuantity = 99
    static let specialInstructionsMaxLength = 200
    
    // Location
    static let defaultLocationRadius: Double = 50000 // 50km in meters
    
    // Animation
    static let defaultAnimationDuration: Double = 0.3
}

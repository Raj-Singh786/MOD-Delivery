import Foundation
import Combine

// MARK: - Cart Manager
@MainActor
class CartManager: ObservableObject {
    static let shared = CartManager()
    
    @Published var cart: Cart = Cart()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadCart()
    }
    
    // MARK: - Cart Operations
    
    func addItem(_ item: CartItem) {
        cart.addItem(item)
        saveCart()
    }
    
    func removeItem(_ itemId: String) {
        cart.removeItem(itemId)
        saveCart()
    }
    
    func updateQuantity(_ itemId: String, quantity: Int) {
        cart.updateQuantity(itemId, quantity: quantity)
        saveCart()
    }
    
    func editItem(_ itemId: String, newItem: CartItem) {
        if let index = cart.items.firstIndex(where: { $0.id == itemId }) {
            cart.items[index] = newItem
            cart.items[index].totalPrice = cart.items[index].unitPrice * Double(cart.items[index].quantity)
            saveCart()
        }
    }
    
    func clearCart() {
        cart.clear()
        saveCart()
    }
    
    func setOrderType(_ orderType: OrderType) {
        cart.orderType = orderType
        saveCart()
    }
    
    func setRestaurant(_ restaurant: Restaurant?) {
        cart.restaurant = restaurant
        saveCart()
    }
    
    func setAddress(_ address: Address) {
        cart.address = address
        saveCart()
    }
    
    func setSpecialInstructions(_ instructions: String) {
        cart.specialInstructions = instructions
        saveCart()
    }
    
    // MARK: - Persistence
    
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(cart) {
            userDefaults.set(encoded, forKey: Constants.guestCartKey)
        }
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: Constants.guestCartKey),
           let decoded = try? JSONDecoder().decode(Cart.self, from: data) {
            self.cart = decoded
        }
    }
    
    // MARK: - Calculations
    
    var deliveryFee: Double {
        switch cart.orderType {
        case .delivery:
            return 49.0 // Fixed delivery fee
        case .takeaway, .dineIn:
            return 0.0
        }
    }
    
    var tax: Double {
        cart.subtotal * 0.05 // 5% tax
    }
    
    var discount: Double {
        0.0 // Will be calculated based on rewards
    }
    
    var total: Double {
        cart.subtotal + deliveryFee + tax - discount
    }
    
    var estimatedPoints: Int {
        Int(cart.subtotal * Constants.loyaltyPointsPerRupee)
    }
    
    // MARK: - Validation
    
    var isValidForCheckout: Bool {
        !cart.isEmpty && cart.restaurant != nil
    }
    
    var requiresAddress: Bool {
        cart.orderType == .delivery && cart.address == nil
    }
    
    var requiresRestaurant: Bool {
        cart.restaurant == nil
    }
}

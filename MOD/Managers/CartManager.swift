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
    
    // MARK: - Points discount ($5 off for 200 pts)
    static let pointsDiscountAmount: Double = 5
    static let pointsDiscountCost: Int = 200

    @Published var pointsRedeemed: Int = 0      // 0 = not applied

    var pointsDiscount: Double {
        pointsRedeemed > 0 ? min(cart.subtotal, Self.pointsDiscountAmount) : 0
    }

    func applyPointsDiscount()  { pointsRedeemed = Self.pointsDiscountCost }
    func removePointsDiscount() { pointsRedeemed = 0 }

    // MARK: - Coupon Code
    @Published var appliedCouponCode: String? = nil

    // Valid coupon codes with their discount details
    private let couponCodes: [String: CouponDetails] = [
        "MODFEAST": CouponDetails(discountType: .percentage, value: 50, minOrderValue: 299),
        "BOGOTU": CouponDetails(discountType: .percentage, value: 50, minOrderValue: 399),
        "SAVE10": CouponDetails(discountType: .percentage, value: 10, minOrderValue: 0),
        "FLAT20": CouponDetails(discountType: .flat, value: 20, minOrderValue: 0)
    ]

    struct CouponDetails {
        let discountType: DiscountType
        let value: Double
        let minOrderValue: Double
    }

    enum DiscountType {
        case percentage
        case flat
    }

    var couponDiscount: Double {
        guard let code = appliedCouponCode,
              let coupon = couponCodes[code] else { return 0 }

        // Check minimum order value
        if cart.subtotal < coupon.minOrderValue {
            return 0
        }

        switch coupon.discountType {
        case .percentage:
            return cart.subtotal * (coupon.value / 100)
        case .flat:
            return min(coupon.value, cart.subtotal)
        }
    }

    func applyCouponCode(_ code: String) -> Bool {
        let uppercasedCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        
        guard couponCodes[uppercasedCode] != nil else {
            return false
        }

        appliedCouponCode = uppercasedCode
        saveCart()
        return true
    }

    func removeCouponCode() {
        appliedCouponCode = nil
        saveCart()
    }

    func validateCouponCode(_ code: String) -> (isValid: Bool, message: String?) {
        let uppercasedCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        
        guard let coupon = couponCodes[uppercasedCode] else {
            return (false, "Invalid coupon code")
        }

        if cart.subtotal < coupon.minOrderValue {
            return (false, "Minimum order value ₹\(Int(coupon.minOrderValue)) required")
        }

        return (true, nil)
    }
    
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
        pointsRedeemed = 0
        appliedCouponCode = nil
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
        // Save coupon code separately
        userDefaults.set(appliedCouponCode, forKey: "appliedCouponCode")
    }
    
    private func loadCart() {
        if let data = userDefaults.data(forKey: Constants.guestCartKey),
           let decoded = try? JSONDecoder().decode(Cart.self, from: data) {
            self.cart = decoded
        }
        // Load coupon code
        appliedCouponCode = userDefaults.string(forKey: "appliedCouponCode")
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
        pointsDiscount + couponDiscount
    }
    
    var total: Double {
        max(0, cart.subtotal + deliveryFee + tax - discount)
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

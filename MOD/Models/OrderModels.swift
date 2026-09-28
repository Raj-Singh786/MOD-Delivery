import Foundation

// MARK: - Order Type
enum OrderType: String, Codable, CaseIterable {
    case delivery = "delivery"
    case takeaway = "takeaway"
    case dineIn = "dine_in"
    
    var displayName: String {
        switch self {
        case .delivery: return "Delivery"
        case .takeaway: return "Takeaway"
        case .dineIn: return "Dine-In"
        }
    }
    
    var icon: String {
        switch self {
        case .delivery: return "car.fill"
        case .takeaway: return "bag.fill"
        case .dineIn: return "fork.knife"
        }
    }
}

// MARK: - Order Status
enum OrderStatus: String, Codable, CaseIterable {
    case placed = "placed"
    case confirmed = "confirmed"
    case preparing = "preparing"
    case ready = "ready"
    case outForDelivery = "out_for_delivery"
    case delivered = "delivered"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .placed: return "Order Placed"
        case .confirmed: return "Confirmed"
        case .preparing: return "Preparing"
        case .ready: return "Ready"
        case .outForDelivery: return "Out for Delivery"
        case .delivered: return "Delivered"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    
    var isCompleted: Bool {
        return self == .completed || self == .delivered || self == .cancelled
    }
    
    var isActive: Bool {
        return !isCompleted
    }
}

// MARK: - Order
struct Order: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let orderType: OrderType
    let restaurant: Restaurant
    let items: [CartItem]
    let subtotal: Double
    let deliveryFee: Double
    let tax: Double
    let discount: Double
    let total: Double
    var status: OrderStatus
    var estimatedTime: Date?
    let createdAt: Date
    let updatedAt: Date
    let customer: Customer?
    let address: Address?
    let paymentMethod: PaymentMethod?
    var loyaltyPointsEarned: Int?
    let specialInstructions: String?
    
    init(id: String = UUID().uuidString,
         orderNumber: String,
         orderType: OrderType,
         restaurant: Restaurant,
         items: [CartItem],
         subtotal: Double,
         deliveryFee: Double = 0,
         tax: Double = 0,
         discount: Double = 0,
         total: Double,
         status: OrderStatus = .placed,
         estimatedTime: Date? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         customer: Customer? = nil,
         address: Address? = nil,
         paymentMethod: PaymentMethod? = nil,
         loyaltyPointsEarned: Int? = nil,
         specialInstructions: String? = nil) {
        self.id = id
        self.orderNumber = orderNumber
        self.orderType = orderType
        self.restaurant = restaurant
        self.items = items
        self.subtotal = subtotal
        self.deliveryFee = deliveryFee
        self.tax = tax
        self.estimatedTime = estimatedTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.customer = customer
        self.address = address
        self.paymentMethod = paymentMethod
        self.loyaltyPointsEarned = loyaltyPointsEarned
        self.specialInstructions = specialInstructions
        self.total = total
        self.status = status
        self.discount = discount
    }
}

// MARK: - Address
struct Address: Codable, Identifiable {
    let id: String
    let type: AddressType
    let fullName: String
    let mobileNumber: String
    let addressLine1: String
    let addressLine2: String?
    let city: String
    let state: String
    let postalCode: String
    let isDefault: Bool
    let landmark: String?
    
    enum AddressType: String, Codable {
        case home = "home"
        case work = "work"
        case other = "other"
    }
    
    var fullAddress: String {
        var parts = [addressLine1]
        if let line2 = addressLine2 {
            parts.append(line2)
        }
        parts.append(city)
        parts.append(state)
        parts.append(postalCode)
        return parts.joined(separator: ", ")
    }
    
    init(id: String = UUID().uuidString,
         type: AddressType = .home,
         fullName: String,
         mobileNumber: String,
         addressLine1: String,
         addressLine2: String? = nil,
         city: String,
         state: String,
         postalCode: String,
         isDefault: Bool = false,
         landmark: String? = nil) {
        self.id = id
        self.type = type
        self.fullName = fullName
        self.mobileNumber = mobileNumber
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.isDefault = isDefault
        self.landmark = landmark
    }
}

// MARK: - Payment Method
struct PaymentMethod: Codable, Identifiable {
    let id: String
    let type: PaymentType
    let displayName: String
    let isDefault: Bool
    let lastFour: String?
    let expiryMonth: Int?
    let expiryYear: Int?
    
    enum PaymentType: String, Codable {
        case upi = "upi"
        case creditCard = "credit_card"
        case debitCard = "debit_card"
        case cash = "cash"
        case applePay = "apple_pay"
        case googlePay = "google_pay"
    }
    
    init(id: String = UUID().uuidString,
         type: PaymentType,
         displayName: String,
         isDefault: Bool = false,
         lastFour: String? = nil,
         expiryMonth: Int? = nil,
         expiryYear: Int? = nil) {
        self.id = id
        self.type = type
        self.displayName = displayName
        self.isDefault = isDefault
        self.lastFour = lastFour
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
}

// MARK: - Customer
struct Customer: Codable {
    let id: String
    let name: String
    let email: String?
    let mobileNumber: String
    let dateOfBirth: Date?
    let createdAt: Date
    let updatedAt: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         email: String? = nil,
         mobileNumber: String,
         dateOfBirth: Date? = nil,
         createdAt: Date = Date(),
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.mobileNumber = mobileNumber
        self.dateOfBirth = dateOfBirth
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

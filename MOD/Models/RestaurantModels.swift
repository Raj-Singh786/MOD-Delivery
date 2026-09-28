import Foundation
import CoreLocation

// MARK: - Restaurant
struct Restaurant: Codable, Identifiable {
    let id: String
    let name: String
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let phoneNumber: String
    let email: String?
    let location: RestaurantLocation
    let isOpen: Bool
    let openingHours: [OpeningHours]
    let availableOrderTypes: [OrderType]
    var distance: Double? // in kilometers
    let estimatedDeliveryTime: Int? // in minutes
    let estimatedPickupTime: Int? // in minutes
    let rating: Double?
    let totalRatings: Int?
    let image: String?
    let features: [String]?
    let hasDriveThru: Bool
    let hasOutdoorSeating: Bool
    
    struct RestaurantLocation: Codable {
        let latitude: Double
        let longitude: Double
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    struct OpeningHours: Codable {
        let day: DayOfWeek
        let openTime: String
        let closeTime: String
        let isClosed: Bool
        
        enum DayOfWeek: String, Codable, CaseIterable {
            case monday = "monday"
            case tuesday = "tuesday"
            case wednesday = "wednesday"
            case thursday = "thursday"
            case friday = "friday"
            case saturday = "saturday"
            case sunday = "sunday"
            
            var displayName: String {
                switch self {
                case .monday: return "Mon"
                case .tuesday: return "Tue"
                case .wednesday: return "Wed"
                case .thursday: return "Thu"
                case .friday: return "Fri"
                case .saturday: return "Sat"
                case .sunday: return "Sun"
                }
            }
        }
    }
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(postalCode)"
    }
    
    var isOpenNow: Bool {
        guard isOpen else { return false }
        
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.weekday, from: now)
        let today = OpeningHours.DayOfWeek.allCases[currentDay - 1]
        
        if let todayHours = openingHours.first(where: { $0.day == today }) {
            return !todayHours.isClosed
        }
        
        return false
    }
    
    var currentOpeningHours: OpeningHours? {
        let calendar = Calendar.current
        let now = Date()
        let currentDay = calendar.component(.weekday, from: now)
        let today = OpeningHours.DayOfWeek.allCases[currentDay - 1]
        
        return openingHours.first(where: { $0.day == today })
    }
    
    var distanceString: String {
        guard let distance = distance else { return "" }
        if distance < 1 {
            return String(format: "%.0f m", distance * 1000)
        }
        return String(format: "%.1f km", distance)
    }
    
    var zipCode: String {
        return postalCode
    }
    
    var ratingString: String {
        guard let rating = rating else { return "New" }
        return String(format: "%.1f", rating)
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         address: String,
         city: String,
         state: String,
         postalCode: String,
         phoneNumber: String,
         email: String? = nil,
         location: RestaurantLocation,
         isOpen: Bool = true,
         openingHours: [OpeningHours] = [],
         availableOrderTypes: [OrderType] = OrderType.allCases,
         distance: Double? = nil,
         estimatedDeliveryTime: Int? = nil,
         estimatedPickupTime: Int? = nil,
         rating: Double? = nil,
         totalRatings: Int? = nil,
         image: String? = nil,
         features: [String]? = nil,
         hasDriveThru: Bool = false,
         hasOutdoorSeating: Bool = false) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.phoneNumber = phoneNumber
        self.email = email
        self.location = location
        self.isOpen = isOpen
        self.openingHours = openingHours
        self.availableOrderTypes = availableOrderTypes
        self.distance = distance
        self.estimatedDeliveryTime = estimatedDeliveryTime
        self.estimatedPickupTime = estimatedPickupTime
        self.rating = rating
        self.totalRatings = totalRatings
        self.image = image
        self.features = features
        self.hasDriveThru = hasDriveThru
        self.hasOutdoorSeating = hasOutdoorSeating
    }
}

// MARK: - Offer Banner Model
struct OfferBanner: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let image: String?
    let backgroundColor: String?
    let textColor: String?
    let callToAction: String
    let targetUrl: String?
    let isActive: Bool
    let startDate: Date
    let endDate: Date
    let sortOrder: Int
    
    var isExpired: Bool {
        endDate < Date()
    }
    
    var isActiveNow: Bool {
        isActive && !isExpired && startDate <= Date()
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         subtitle: String,
         description: String,
         image: String? = nil,
         backgroundColor: String? = nil,
         textColor: String? = nil,
         callToAction: String = "Order Now",
         targetUrl: String? = nil,
         isActive: Bool = true,
         startDate: Date = Date(),
         endDate: Date = Date().addingTimeInterval(86400 * 7),
         sortOrder: Int = 0) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.callToAction = callToAction
        self.targetUrl = targetUrl
        self.isActive = isActive
        self.startDate = startDate
        self.endDate = endDate
        self.sortOrder = sortOrder
    }
}

// MARK: - Latest Offer Model
struct LatestOffer: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let discountPercentage: String
    let promoCode: String
    let endDate: Date
    let minOrderValue: Double?
    let applicableCategories: [String]?
    let isActive: Bool
    
    var timeRemaining: String {
        let remaining = endDate.timeIntervalSinceNow
        if remaining <= 0 {
            return "Expired"
        }
        
        let hours = Int(remaining / 3600)
        let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 24 {
            let days = hours / 24
            return "Ends in \(days)d"
        } else if hours > 0 {
            return "Ends in \(hours)h"
        } else {
            return "Ends in \(minutes)m"
        }
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         discountPercentage: String,
         promoCode: String,
         endDate: Date = Date().addingTimeInterval(7200),
         minOrderValue: Double? = nil,
         applicableCategories: [String]? = nil,
         isActive: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.discountPercentage = discountPercentage
        self.promoCode = promoCode
        self.endDate = endDate
        self.minOrderValue = minOrderValue
        self.applicableCategories = applicableCategories
        self.isActive = isActive
    }
}

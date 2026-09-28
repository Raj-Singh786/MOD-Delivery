import Foundation

// MARK: - Loyalty Summary
struct LoyaltySummary: Codable {
    let availablePoints: Int
    let pendingPoints: Int
    let pointsToNextReward: Int?
    let currentTier: LoyaltyTier?
    let nextTier: LoyaltyTier?
    let memberSince: Date?
    let totalPointsEarned: Int
    let totalPointsRedeemed: Int
    
    var totalPoints: Int {
        availablePoints + pendingPoints
    }
    
    init(availablePoints: Int = 0,
         pendingPoints: Int = 0,
         pointsToNextReward: Int? = nil,
         currentTier: LoyaltyTier? = nil,
         nextTier: LoyaltyTier? = nil,
         memberSince: Date? = nil,
         totalPointsEarned: Int = 0,
         totalPointsRedeemed: Int = 0) {
        self.availablePoints = availablePoints
        self.pendingPoints = pendingPoints
        self.pointsToNextReward = pointsToNextReward
        self.currentTier = currentTier
        self.nextTier = nextTier
        self.memberSince = memberSince
        self.totalPointsEarned = totalPointsEarned
        self.totalPointsRedeemed = totalPointsRedeemed
    }
}

// MARK: - Loyalty Tier
struct LoyaltyTier: Codable {
    let id: String
    let name: String
    let description: String
    let requiredPoints: Int
    let benefits: [String]
    let color: String?
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         requiredPoints: Int,
         benefits: [String] = [],
         color: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.requiredPoints = requiredPoints
        self.benefits = benefits
        self.color = color
    }
}

// MARK: - Reward
struct Reward: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let pointsRequired: Int
    let image: String?
    let category: RewardCategory
    let isActive: Bool
    let expiryDate: Date?
    let termsAndConditions: String?
    
    enum RewardCategory: String, Codable {
        case food = "food"
        case discount = "discount"
        case drink = "drink"
        case merchandise = "merchandise"
        case experience = "experience"
    }
    
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String,
         pointsRequired: Int,
         image: String? = nil,
         category: RewardCategory = .discount,
         isActive: Bool = true,
         expiryDate: Date? = nil,
         termsAndConditions: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.pointsRequired = pointsRequired
        self.image = image
        self.category = category
        self.isActive = isActive
        self.expiryDate = expiryDate
        self.termsAndConditions = termsAndConditions
    }
}

// MARK: - Loyalty Transaction
struct LoyaltyTransaction: Codable, Identifiable {
    let id: String
    let type: TransactionType
    let points: Int
    let description: String
    let orderId: String?
    let rewardId: String?
    let status: TransactionStatus
    let createdAt: Date
    let processedAt: Date?
    
    enum TransactionType: String, Codable {
        case earned = "earned"
        case redeemed = "redeemed"
        case expired = "expired"
        case adjusted = "adjusted"
    }
    
    enum TransactionStatus: String, Codable {
        case pending = "pending"
        case completed = "completed"
        case failed = "failed"
        
        var displayName: String {
            switch self {
            case .pending: return "Pending"
            case .completed: return "Completed"
            case .failed: return "Failed"
            }
        }
    }
    
    var isPending: Bool {
        status == .pending
    }
    
    var isCompleted: Bool {
        status == .completed
    }
    
    init(id: String = UUID().uuidString,
         type: TransactionType,
         points: Int,
         description: String,
         orderId: String? = nil,
         rewardId: String? = nil,
         status: TransactionStatus = .pending,
         createdAt: Date = Date(),
         processedAt: Date? = nil) {
        self.id = id
        self.type = type
        self.points = points
        self.description = description
        self.orderId = orderId
        self.rewardId = rewardId
        self.status = status
        self.createdAt = createdAt
        self.processedAt = processedAt
    }
}

// MARK: - Campaign
struct Campaign: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let image: String?
    let type: CampaignType
    let startDate: Date
    let endDate: Date
    let isActive: Bool
    let eligibility: CampaignEligibility
    let callToAction: String?
    let termsAndConditions: String?
    
    enum CampaignType: String, Codable {
        case doublePoints = "double_points"
        case birthdayBonus = "birthday_bonus"
        case freeItem = "free_item"
        case discount = "discount"
        case newMember = "new_member"
    }
    
    struct CampaignEligibility: Codable {
        let minimumOrderAmount: Double?
        let isForNewCustomersOnly: Bool
        let requiredTier: String?
        let ageRestriction: Int?

        init(minimumOrderAmount: Double? = nil,
             isForNewCustomersOnly: Bool = false,
             requiredTier: String? = nil,
             ageRestriction: Int? = nil) {
            self.minimumOrderAmount = minimumOrderAmount
            self.isForNewCustomersOnly = isForNewCustomersOnly
            self.requiredTier = requiredTier
            self.ageRestriction = ageRestriction
        }
    }
    
    var isExpired: Bool {
        endDate < Date()
    }
    
    var isUpcoming: Bool {
        startDate > Date()
    }
    
    var isActiveNow: Bool {
        isActive && !isExpired && !isUpcoming
    }
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         image: String? = nil,
         type: CampaignType,
         startDate: Date,
         endDate: Date,
         isActive: Bool = true,
         eligibility: CampaignEligibility = CampaignEligibility(),
         callToAction: String? = nil,
         termsAndConditions: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
        self.eligibility = eligibility
        self.callToAction = callToAction
        self.termsAndConditions = termsAndConditions
    }
}

// MARK: - Loyalty QR
struct LoyaltyQR: Codable {
    let qrCode: String
    let customerName: String
    let currentPoints: Int
    let expiresAt: Date
    let rewardId: String?
    
    var isExpired: Bool {
        expiresAt < Date()
    }
    
    var timeRemaining: TimeInterval {
        expiresAt.timeIntervalSinceNow
    }
    
    init(qrCode: String,
         customerName: String,
         currentPoints: Int,
         expiresAt: Date,
         rewardId: String? = nil) {
        self.qrCode = qrCode
        self.customerName = customerName
        self.currentPoints = currentPoints
        self.expiresAt = expiresAt
        self.rewardId = rewardId
    }
}

// MARK: - User Reward (Redeemed Reward)
struct UserReward: Codable, Identifiable {
    let id: String
    let rewardId: String
    let reward: Reward
    let redeemedAt: Date
    let expiresAt: Date
    let isUsed: Bool
    let usedAt: Date?
    
    var isExpired: Bool {
        expiresAt < Date()
    }
    
    var isValid: Bool {
        !isUsed && !isExpired
    }
    
    init(id: String = UUID().uuidString,
         rewardId: String,
         reward: Reward,
         redeemedAt: Date = Date(),
         expiresAt: Date,
         isUsed: Bool = false,
         usedAt: Date? = nil) {
        self.id = id
        self.rewardId = rewardId
        self.reward = reward
        self.redeemedAt = redeemedAt
        self.expiresAt = expiresAt
        self.isUsed = isUsed
        self.usedAt = usedAt
    }
}

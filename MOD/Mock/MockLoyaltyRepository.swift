import Foundation
import Combine

// MARK: - Mock Loyalty Repository
class MockLoyaltyRepository: LoyaltyRepositoryProtocol, ObservableObject {
    static let shared = MockLoyaltyRepository()
    
    @Published private(set) var currentSummary: LoyaltySummary
    @Published private(set) var currentTransactions: [LoyaltyTransaction]
    
    private init() {
        currentSummary = MockData.loyaltySummary
        currentTransactions = MockData.loyaltyTransactions
    }
    
    /// Adds checkout earnings to Pending Verification (1 point per $1 of subtotal).
    @MainActor
    func addPendingPoints(points: Int, orderNumber: String, orderId: String) {
        guard points > 0 else { return }
        
        let existing = currentSummary
        currentSummary = LoyaltySummary(
            availablePoints: existing.availablePoints,
            pendingPoints: existing.pendingPoints + points,
            pointsToNextReward: existing.pointsToNextReward,
            currentTier: existing.currentTier,
            nextTier: existing.nextTier,
            memberSince: existing.memberSince,
            totalPointsEarned: existing.totalPointsEarned,
            totalPointsRedeemed: existing.totalPointsRedeemed
        )
        
        let transaction = LoyaltyTransaction(
            type: .earned,
            points: points,
            description: "Order #\(orderNumber)",
            orderId: orderId,
            status: .pending,
            createdAt: Date()
        )
        currentTransactions.insert(transaction, at: 0)
    }
    
    func getLoyaltySummary() async throws -> LoyaltySummary {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return currentSummary
    }
    
    func getRewards() async throws -> [Reward] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return MockData.rewards
    }
    
    func getCampaigns() async throws -> [Campaign] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return MockData.campaigns.filter { $0.isActiveNow }
    }
    
    func getLoyaltyTransactions() async throws -> [LoyaltyTransaction] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return currentTransactions
    }
    
    func redeemReward(rewardId: String) async throws -> UserReward {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        guard let reward = MockData.rewards.first(where: { $0.id == rewardId }) else {
            throw APIError.notFound
        }
        
        return UserReward(
            rewardId: rewardId,
            reward: reward,
            redeemedAt: Date(),
            expiresAt: Date().addingTimeInterval(86400 * 30)
        )
    }
    
    func getLoyaltyQR() async throws -> LoyaltyQR {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        return LoyaltyQR(
            qrCode: UUID().uuidString,
            customerName: "Raj Kumar",
            currentPoints: currentSummary.availablePoints,
            expiresAt: Date().addingTimeInterval(300) // 5 minutes
        )
    }
    
    func getUserRewards() async throws -> [UserReward] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return []
    }
}

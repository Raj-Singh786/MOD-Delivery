import Foundation

// MARK: - Mock Loyalty Repository
class MockLoyaltyRepository: LoyaltyRepositoryProtocol {
    static let shared = MockLoyaltyRepository()
    
    private init() {}
    
    func getLoyaltySummary() async throws -> LoyaltySummary {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return MockData.loyaltySummary
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
        return MockData.loyaltyTransactions
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
            currentPoints: MockData.loyaltySummary.availablePoints,
            expiresAt: Date().addingTimeInterval(300) // 5 minutes
        )
    }
    
    func getUserRewards() async throws -> [UserReward] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        return []
    }
}

import Foundation

// MARK: - Loyalty Repository Protocol
protocol LoyaltyRepositoryProtocol {
    func getLoyaltySummary() async throws -> LoyaltySummary
    func getRewards() async throws -> [Reward]
    func getCampaigns() async throws -> [Campaign]
    func getLoyaltyTransactions() async throws -> [LoyaltyTransaction]
    func redeemReward(rewardId: String) async throws -> UserReward
    func getLoyaltyQR() async throws -> LoyaltyQR
    func getUserRewards() async throws -> [UserReward]
}

// MARK: - Loyalty Repository Implementation
class LoyaltyRepository: LoyaltyRepositoryProtocol {
    static let shared = LoyaltyRepository()
    
    private let loyaltyService: LoyaltyServiceProtocol
    
    private init(loyaltyService: LoyaltyServiceProtocol = LoyaltyService.shared) {
        self.loyaltyService = loyaltyService
    }
    
    func getLoyaltySummary() async throws -> LoyaltySummary {
        return try await loyaltyService.getLoyaltySummary()
    }
    
    func getRewards() async throws -> [Reward] {
        return try await loyaltyService.getRewards()
    }
    
    func getCampaigns() async throws -> [Campaign] {
        return try await loyaltyService.getCampaigns()
    }
    
    func getLoyaltyTransactions() async throws -> [LoyaltyTransaction] {
        return try await loyaltyService.getLoyaltyTransactions()
    }
    
    func redeemReward(rewardId: String) async throws -> UserReward {
        return try await loyaltyService.redeemReward(rewardId: rewardId)
    }
    
    func getLoyaltyQR() async throws -> LoyaltyQR {
        return try await loyaltyService.getLoyaltyQR()
    }
    
    func getUserRewards() async throws -> [UserReward] {
        return try await loyaltyService.getUserRewards()
    }
}

import Foundation
import Combine

// MARK: - Loyalty Service Protocol
protocol LoyaltyServiceProtocol {
    func getLoyaltySummary() async throws -> LoyaltySummary
    func getRewards() async throws -> [Reward]
    func getCampaigns() async throws -> [Campaign]
    func getLoyaltyTransactions() async throws -> [LoyaltyTransaction]
    func redeemReward(rewardId: String) async throws -> UserReward
    func getLoyaltyQR() async throws -> LoyaltyQR
    func getUserRewards() async throws -> [UserReward]
}

// MARK: - Loyalty Service Implementation
class LoyaltyService: LoyaltyServiceProtocol {
    static let shared = LoyaltyService()
    
    private let apiService: APIServiceProtocol
    
    private init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    func getLoyaltySummary() async throws -> LoyaltySummary {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/summary", queryParams: nil)
        
        // Mock response
        return MockData.loyaltySummary
    }
    
    func getRewards() async throws -> [Reward] {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/rewards", queryParams: nil)
        
        // Mock response
        return MockData.rewards
    }
    
    func getCampaigns() async throws -> [Campaign] {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/campaigns", queryParams: nil)
        
        // Mock response
        return MockData.campaigns
    }
    
    func getLoyaltyTransactions() async throws -> [LoyaltyTransaction] {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/transactions", queryParams: nil)
        
        // Mock response
        return MockData.loyaltyTransactions
    }
    
    func redeemReward(rewardId: String) async throws -> UserReward {
        // TODO: Replace with actual API call
        // return try await apiService.post(endpoint: "/loyalty/redeem", body: ["rewardId": rewardId], queryParams: nil)
        
        // Mock response
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
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/qr", queryParams: nil)
        
        // Mock response
        return LoyaltyQR(
            qrCode: UUID().uuidString,
            customerName: "Raj Kumar",
            currentPoints: MockData.loyaltySummary.availablePoints,
            expiresAt: Date().addingTimeInterval(300) // 5 minutes
        )
    }
    
    func getUserRewards() async throws -> [UserReward] {
        // TODO: Replace with actual API call
        // return try await apiService.get(endpoint: "/loyalty/user-rewards", queryParams: nil)
        
        // Mock response
        return []
    }
}

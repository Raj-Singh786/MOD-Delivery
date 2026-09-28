import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var loyaltySummary: LoyaltySummary?
    @State private var rewards: [Reward] = []
    @State private var campaigns: [Campaign] = []
    @State private var userRewards: [UserReward] = []
    @State private var transactions: [LoyaltyTransaction] = []
    @State private var selectedTab: RewardsTab = .overview
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var showQRCode: Bool = false
    @State private var loyaltyQR: LoyaltyQR?
    
    private let loyaltyRepository = MockLoyaltyRepository.shared
    
    enum RewardsTab: String, CaseIterable {
        case overview = "overview"
        case rewards = "rewards"
        case history = "history"
        case offers = "offers"
        
        var displayName: String {
            switch self {
            case .overview: return "Overview"
            case .rewards: return "Rewards"
            case .history: return "History"
            case .offers: return "Offers"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Loading rewards...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else {
                    VStack(spacing: 0) {
                        // Loyalty Summary Card
                        if let summary = loyaltySummary {
                            loyaltySummaryCard(summary: summary)
                        }
                        
                        // Tab Selector
                        rewardsTabSelector
                        
                        // Tab Content
                        ScrollView {
                            VStack(spacing: AppSpacing.lg) {
                                switch selectedTab {
                                case .overview:
                                    overviewContent
                                case .rewards:
                                    rewardsContent
                                case .history:
                                    historyContent
                                case .offers:
                                    offersContent
                                }
                                
                                // Bottom spacing
                                Color.clear
                                    .frame(height: 100)
                            }
                            .padding(.vertical, AppSpacing.md)
                        }
                    }
                }
            }
            .navigationTitle("MOD Rewards")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showQRCode = true
                    }) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showQRCode) {
                LoyaltyQRView(loyaltyQR: loyaltyQR)
            }
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Loyalty Summary Card
    
    private func loyaltySummaryCard(summary: LoyaltySummary) -> some View {
        VStack(spacing: AppSpacing.lg) {
            // Points Display
            VStack(spacing: AppSpacing.xs) {
                Text("\(summary.availablePoints)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Available Points")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            // Pending Points
            if summary.pendingPoints > 0 {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.warmOrange)
                    
                    Text("+\(summary.pendingPoints) Points Pending")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
            
            // Progress to Next Reward
            if let pointsToNext = summary.pointsToNextReward {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("\(pointsToNext) points until next reward")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                    }
                    
                    ProgressView(value: Double(summary.availablePoints), total: Double(summary.availablePoints + pointsToNext))
                        .tint(AppColors.primaryRed)
                }
            }
            
            // Show at Checkout Button
            Button(action: {
                showQRCode = true
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 20))
                    
                    Text("Show at Checkout")
                        .font(AppFonts.callout)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
                .background(AppColors.primaryRed)
                .cornerRadius(AppSpacing.cornerRadius)
            }
        }
        .padding(AppSpacing.lg)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [AppColors.primaryRed, AppColors.primaryBurgundy]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Rewards Tab Selector
    
    private var rewardsTabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(RewardsTab.allCases, id: \.self) { tab in
                    RewardsTabChip(
                        title: tab.displayName,
                        isSelected: selectedTab == tab,
                        action: {
                            selectedTab = tab
                        }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: AppSpacing.lg) {
            // Quick Stats
            if let summary = loyaltySummary {
                quickStatsSection(summary: summary)
            }
            
            // Available Rewards Preview
            if !rewards.isEmpty {
                rewardsPreviewSection
            }
            
            // Recent Activity
            if !transactions.isEmpty {
                recentActivitySection
            }
        }
    }
    
    // MARK: - Rewards Content
    
    private var rewardsContent: some View {
        VStack(spacing: AppSpacing.md) {
            if rewards.isEmpty {
                emptyRewardsView
            } else {
                ForEach(rewards) { reward in
                    RewardCard(reward: reward)
                        .padding(.horizontal, AppSpacing.lg)
                }
            }
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        VStack(spacing: AppSpacing.md) {
            if transactions.isEmpty {
                emptyHistoryView
            } else {
                ForEach(transactions) { transaction in
                    TransactionCard(transaction: transaction)
                        .padding(.horizontal, AppSpacing.lg)
                }
            }
        }
    }
    
    // MARK: - Offers Content
    
    private var offersContent: some View {
        VStack(spacing: AppSpacing.md) {
            if campaigns.isEmpty {
                emptyOffersView
            } else {
                ForEach(campaigns) { campaign in
                    CampaignCard(campaign: campaign)
                        .padding(.horizontal, AppSpacing.lg)
                }
            }
        }
    }
    
    // MARK: - Quick Stats Section
    
    private func quickStatsSection(summary: LoyaltySummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Quick Stats")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.md) {
                StatCard(
                    title: "Total Earned",
                    value: "\(summary.totalPointsEarned)",
                    icon: "arrow.up.circle.fill",
                    color: AppColors.success
                )
                
                StatCard(
                    title: "Total Redeemed",
                    value: "\(summary.totalPointsRedeemed)",
                    icon: "arrow.down.circle.fill",
                    color: AppColors.warning
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Rewards Preview Section
    
    private var rewardsPreviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Available Rewards")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedTab = .rewards
                }) {
                    Text("View All")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(rewards.prefix(3)) { reward in
                        RewardPreviewCard(reward: reward)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedTab = .history
                }) {
                    Text("View All")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(transactions.prefix(3)) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Empty Views
    
    private var emptyRewardsView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "gift.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No Rewards Available")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Keep ordering to unlock new rewards.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyHistoryView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No Points History")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Your points activity will appear here.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyOffersView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "tag.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No Active Offers")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Check back later for new offers and campaigns.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let summary = loyaltyRepository.getLoyaltySummary()
            async let rewardsData = loyaltyRepository.getRewards()
            async let campaignsData = loyaltyRepository.getCampaigns()
            async let transactionsData = loyaltyRepository.getLoyaltyTransactions()
            async let userRewardsData = loyaltyRepository.getUserRewards()
            async let qrData = loyaltyRepository.getLoyaltyQR()
            
            let (summaryResult, rewardsResult, campaignsResult, transactionsResult, userRewardsResult, qrResult) = try await (summary, rewardsData, campaignsData, transactionsData, userRewardsData, qrData)
            
            await MainActor.run {
                self.loyaltySummary = summaryResult
                self.rewards = rewardsResult
                self.campaigns = campaignsResult
                self.transactions = transactionsResult
                self.userRewards = userRewardsResult
                self.loyaltyQR = qrResult
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// MARK: - Rewards Tab Chip
struct RewardsTabChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(isSelected ? .white : AppColors.primaryText)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.primaryRed : AppColors.white)
                )
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: AppSpacing.xs) {
                Text(value)
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryText)
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.md)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

// MARK: - Reward Card
struct RewardCard: View {
    let reward: Reward
    @State private var isRedeeming: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Reward Image Placeholder
            ZStack {
                Rectangle()
                    .fill(AppColors.lightGray)
                    .frame(height: 120)
                    .cornerRadius(AppSpacing.smallCornerRadius)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.mediumGray)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(reward.name)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Text(reward.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                HStack {
                    Text("\(reward.pointsRequired) Points")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                    
                    Spacer()
                }
            }
            
            Button(action: {
                // Redeem logic
            }) {
                Text("Redeem")
                    .font(AppFonts.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.smallCornerRadius)
            }
            .disabled(isRedeeming)
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
}

// MARK: - Reward Preview Card
struct RewardPreviewCard: View {
    let reward: Reward
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack {
                Rectangle()
                    .fill(AppColors.lightGray)
                    .frame(height: 80)
                    .cornerRadius(AppSpacing.smallCornerRadius)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.mediumGray)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(reward.name)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
                
                Text("\(reward.pointsRequired) pts")
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .frame(width: 120)
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

// MARK: - Transaction Card
struct TransactionCard: View {
    let transaction: LoyaltyTransaction
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(transactionColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: transactionIcon)
                    .font(.system(size: 20))
                    .foregroundColor(transactionColor)
            }
            
            // Details
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(transaction.description)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Text(formatDate(transaction.createdAt))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(transactionColor)
                
                Text(transaction.status.displayName)
                    .font(AppFonts.caption)
                    .foregroundColor(transaction.isPending ? AppColors.warning : AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
    }
    
    private var transactionColor: Color {
        switch transaction.type {
        case .earned:
            return AppColors.success
        case .redeemed, .expired:
            return AppColors.error
        case .adjusted:
            return AppColors.warning
        }
    }
    
    private var transactionIcon: String {
        switch transaction.type {
        case .earned: return "arrow.up.circle.fill"
        case .redeemed: return "arrow.down.circle.fill"
        case .expired: return "clock.badge.exclamationmark"
        case .adjusted: return "arrow.left.arrow.right.circle.fill"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: LoyaltyTransaction
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text("\(transaction.points > 0 ? "+" : "")\(transaction.points)")
                .font(AppFonts.callout)
                .fontWeight(.semibold)
                .foregroundColor(transaction.type == .earned ? AppColors.success : AppColors.error)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(transaction.description)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.primaryText)
                
                Text(formatDate(transaction.createdAt))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.tertiaryText)
            }
            
            Spacer()
            
            if transaction.isPending {
                Text("Pending")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.warning)
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Campaign Card
struct CampaignCard: View {
    let campaign: Campaign
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Campaign Image Placeholder
            ZStack {
                Rectangle()
                    .fill(AppColors.lightGray)
                    .frame(height: 120)
                    .cornerRadius(AppSpacing.smallCornerRadius)
                
                Image(systemName: "tag.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.mediumGray)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(campaign.title)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Text(campaign.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                if let callToAction = campaign.callToAction {
                    Button(action: {}) {
                        Text(callToAction)
                            .font(AppFonts.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColors.primaryRed)
                            .cornerRadius(AppSpacing.smallCornerRadius)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
}

// MARK: - Loyalty QR View
struct LoyaltyQRView: View {
    @Environment(\.dismiss) private var dismiss
    let loyaltyQR: LoyaltyQR?
    
    @State private var timeRemaining: TimeInterval = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                // QR Code Placeholder
                ZStack {
                    Rectangle()
                        .fill(AppColors.white)
                        .frame(width: 250, height: 250)
                        .cornerRadius(AppSpacing.cornerRadius)
                        .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
                    
                    if let qr = loyaltyQR {
                        VStack(spacing: AppSpacing.md) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 150))
                                .foregroundColor(AppColors.black)
                            
                            Text(qr.customerName)
                                .font(AppFonts.callout)
                                .foregroundColor(AppColors.primaryText)
                            
                            Text("\(qr.currentPoints) Points")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                VStack(spacing: AppSpacing.sm) {
                    Text("Show this code to the cashier")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    if loyaltyQR != nil {
                        Text("Expires in \(Int(timeRemaining))s")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.warning)
                    }
                }
                
                Button(action: {
                    // Refresh QR code
                }) {
                    Text("Refresh Code")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppColors.secondaryBackground)
            .navigationTitle("Show at Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        if let qr = loyaltyQR {
            timeRemaining = qr.timeRemaining
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    RewardsView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

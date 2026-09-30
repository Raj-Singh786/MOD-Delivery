import SwiftUI
import CoreImage.CIFilterBuiltins
import Combine

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
    @State private var selectedReward: Reward? = nil
    
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
            .sheet(item: $selectedReward, onDismiss: handlePendingNavigation) { reward in
                RewardDetailView(
                    reward: reward,
                    loyaltySummary: loyaltySummary,
                    onRedeem: { await loadData() }
                )
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
                    .foregroundColor(AppColors.black)
            }
            
            // Pending Points
            if summary.pendingPoints > 0 {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.warmOrange)
                    
                    Text("+\(summary.pendingPoints) Points Pending")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.black)
                }
            }
            
            // Progress to Next Reward
            if let pointsToNext = summary.pointsToNextReward {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("\(pointsToNext) points until next reward")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.black)
                        
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
                gradient: Gradient(colors: [AppColors.lightGray, AppColors.darkGray]),
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
                    RewardCard(reward: reward, onTap: {
                        selectedReward = reward
                    })
                    .padding(.horizontal, AppSpacing.lg)
                    .buttonStyle(.plain)
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
    
    
    private func handlePendingNavigation() {
        if let tab = appRouter.pendingTab {
            appRouter.pendingTab = nil
            appRouter.selectTab(tab)
        }
        if appRouter.pendingCartOpen {
            appRouter.pendingCartOpen = false
            appRouter.showCartScreen()
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
//struct RewardCard: View {
//    let reward: Reward
//    let onTap: () -> Void
//    @State private var isRedeeming: Bool = false
//    
//    var body: some View {
//        Button(action: onTap) {
//            VStack(alignment: .leading, spacing: AppSpacing.md) {
//                // Reward Image Placeholder
//                ZStack {
//                    Rectangle()
//                        .fill(AppColors.lightGray)
//                        .frame(height: 120)
//                        .cornerRadius(AppSpacing.smallCornerRadius)
//                    
//                    Image(systemName: "gift.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(AppColors.mediumGray)
//                }
//                
//                VStack(alignment: .leading, spacing: AppSpacing.xs) {
//                    Text(reward.name)
//                        .font(AppFonts.callout)
//                        .foregroundColor(AppColors.primaryText)
//                    
//                    Text(reward.description)
//                        .font(AppFonts.caption)
//                        .foregroundColor(AppColors.secondaryText)
//                        .lineLimit(2)
//                    
//                    HStack {
//                        Text("\(reward.pointsRequired) Points")
//                            .font(AppFonts.callout)
//                            .fontWeight(.semibold)
//                            .foregroundColor(AppColors.primaryRed)
//                        
//                        Spacer()
//                    }
//                }
//                
//                Button(action: onTap) {
//                    Text("Redeem")
//                        .font(AppFonts.subheadline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, AppSpacing.sm)
//                        .background(AppColors.primaryRed)
//                        .cornerRadius(AppSpacing.smallCornerRadius)
//                }
//                .disabled(isRedeeming)
//            }
//            .padding(AppSpacing.md)
//            .background(AppColors.white)
//            .cornerRadius(AppSpacing.cornerRadius)
//            .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
//        }
//        .buttonStyle(.plain)
//    }
//}

// MARK: - Reward Card
struct RewardCard: View {
    let reward: Reward
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Reward image (falls back to the gift icon if no asset is found)
                RewardImage(imageName: reward.image, iconSize: 40)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(reward.name)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)

                    Text(reward.description)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)

                    Text("\(reward.pointsRequired) Points")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                }

                // Visual button only; the whole card is already tappable
                Text("Redeem")
                    .font(AppFonts.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.smallCornerRadius)
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reward Preview Card
struct RewardPreviewCard: View {
    let reward: Reward

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            RewardImage(imageName: reward.image)
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))

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



// MARK: - Reward Detail View (redesigned)
// Replace the old `struct RewardDetailView` in RewardsView.swift with this one.
struct RewardDetailView: View {
    let reward: Reward
    let loyaltySummary: LoyaltySummary?
    var onRedeem: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showConfirm: Bool = false
    @State private var redeemed: Bool = false
    @State private var isRedeeming: Bool = false
    @State private var showCheckoutQR: Bool = false

    // MARK: - Derived values
    private var currentPoints: Int { loyaltySummary?.availablePoints ?? 0 }
    private var canRedeem: Bool { currentPoints >= reward.pointsRequired }
    private var pointsAfter: Int { max(0, currentPoints - reward.pointsRequired) }

    // reward.image is treated as an asset name (NOT an SF Symbol). Falls back to "pizza".
    private var resolvedImageName: String {
        if let name = reward.image, !name.isEmpty, UIImage(named: name) != nil {
            return name
        }
        return "pizza"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.secondaryBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    heroImage
                    titleSection
                    detailsCard
                    howToRedeemCard
                    termsCard

                    Color.clear.frame(height: 150) // room for sticky bottom bar
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
            }

            bottomBar
        }
        .overlay(alignment: .topTrailing) { closeButton }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showCheckoutQR) {
            if let summary = loyaltySummary {
                EnhancedLoyaltyQRView(
                    loyaltyQR: LoyaltyQR.mock(from: summary),
                    reward: reward,
                    onClose: {
                        showCheckoutQR = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            dismiss()
                        }
                    }                )
            }
        }
    }

    // MARK: - Hero Image
    private var heroImage: some View {
        // Color.clear + overlay keeps the photo from stretching the layout
        Color.clear
            .frame(height: 230)
            .overlay(
                Image(resolvedImageName)
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.6)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("MOD REWARDS")
                            .font(.system(size: 13, weight: .heavy))
                            .tracking(0.6)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(AppColors.primaryRed))

                    Text("\(reward.pointsRequired) Points")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.white.opacity(0.95)))
                }
                .padding(14)
            }
            .overlay(alignment: .bottom) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "F6C244"))
                        Text("Most Popular Reward")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.black.opacity(0.45)))

                    Spacer()

                    Text("Tier 1 Perk")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.black.opacity(0.45)))
                }
                .padding(14)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    // MARK: - Close Button
    private var closeButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppColors.primaryText)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color.white.opacity(0.9)))
        }
        .buttonStyle(.plain)
        .padding(.top, 26)
        .padding(.trailing, AppSpacing.lg + 8)
    }

    // MARK: - Title
    private var titleSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text(reward.name)
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)

            Text(reward.description)
                .font(.system(size: 17))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.sm)
    }

    // MARK: - Reward Details Card
    private var detailsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Reward Details")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(AppColors.primaryText)

                Spacer()

                if loyaltySummary != nil {
                    HStack(spacing: 5) {
                        Image(systemName: canRedeem ? "checkmark" : "xmark")
                            .font(.system(size: 11, weight: .bold))
                        Text(canRedeem ? "Ready to Redeem" : "Not enough points")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(canRedeem ? AppColors.success : AppColors.error)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill((canRedeem ? AppColors.success : AppColors.error).opacity(0.14))
                    )
                }
            }
            .padding(.bottom, AppSpacing.md)

            Divider()

            // Required points
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(AppColors.primaryRed)
                Text("Required Points:")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
                Text("\(reward.pointsRequired)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryRed)
            }
            .padding(.vertical, AppSpacing.md)

            Divider()

            // Current balance
            HStack(alignment: .top) {
                Text("Current Balance:")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.secondaryText)
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(currentPoints.formatted())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    if canRedeem {
                        Text("\(pointsAfter.formatted()) pts remaining after")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
            }
            .padding(.vertical, AppSpacing.md)

            if let location = reward.eligibleLocation {
                Divider()

                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(AppColors.secondaryText)
                    Text("Eligible Location:")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                    Text(location)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.top, AppSpacing.md)
            }

            if let expiry = reward.expiryDate {
                Divider().padding(.top, AppSpacing.md)

                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.secondaryText)
                    Text("Expires:")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                    Text(formatDate(expiry))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                }
                .padding(.top, AppSpacing.md)
            }
        }
        .padding(AppSpacing.lg)
        .modifier(DetailCardStyle())
    }

    // MARK: - How To Redeem
    private var howToRedeemCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("HOW TO REDEEM")
                .font(.system(size: 14, weight: .bold))
                .tracking(0.8)
                .foregroundColor(AppColors.secondaryText)

            stepRow(number: 1,
                    text: Text("Tap ") + Text("Redeem").bold().foregroundColor(AppColors.primaryRed) + Text(" below to activate your reward"))
            stepRow(number: 2,
                    text: Text("Show your QR code to the cashier at checkout"))
            stepRow(number: 3,
                    text: Text("Enjoy your reward!"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .modifier(DetailCardStyle())
    }

    private func stepRow(number: Int, text: Text) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.primaryRed)
                .frame(width: 32, height: 32)
                .background(Circle().fill(AppColors.primaryRed.opacity(0.1)))

            text
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 5)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Terms & Conditions
    private var termsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Terms & Conditions")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppColors.primaryText)

            if let terms = reward.termsAndConditions, !terms.isEmpty {
                Text(terms)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            } else {
                ForEach([
                    "Valid on qualifying orders only",
                    "Cannot be combined with selected offers",
                    "Backend confirms redemption status before use"
                ], id: \.self) { line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(line)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .modifier(DetailCardStyle())
    }

    // MARK: - Sticky Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: AppSpacing.md) {
                if !redeemed {
                    Button(action: { showConfirm = true }) {
                        HStack(spacing: 10) {
                            Text("Redeem for \(reward.pointsRequired) Points")
                                .font(.system(size: 18, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(canRedeem ? AppColors.primaryRed : AppColors.lightGray)
                        )
                        .shadow(color: canRedeem ? AppColors.primaryRed.opacity(0.35) : .clear,
                                radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canRedeem || isRedeeming)
                    .confirmationDialog("Confirm Redemption", isPresented: $showConfirm, titleVisibility: .visible) {
                        Button("Confirm", role: .destructive) {
                            isRedeeming = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                redeemed = true
                                isRedeeming = false
                                Task { await onRedeem() }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }

                    Button(action: { dismiss() }) {
                        Text("Save for Later")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Reward Ready!")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(AppColors.success)

                    Button(action: { showCheckoutQR = true }) {
                        Text("Show at Checkout")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(AppColors.primaryRed)
                            )
                            .shadow(color: AppColors.primaryRed.opacity(0.35), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(AppColors.white.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Shared card style for the detail sheet
private struct DetailCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

// MARK: - CornerRadius for specific corners (helper extension)
fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}



// MARK: - Reward Redemption Confirmation
// Replaces the old `EnhancedLoyaltyQRView` in RewardsView.swift (delete the old struct).
// The init stays `EnhancedLoyaltyQRView(loyaltyQR:reward:)`, `onClose` is optional.
struct EnhancedLoyaltyQRView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var cartManager: CartManager

    let loyaltyQR: LoyaltyQR?
    let reward: Reward
    /// Called to close the whole redemption flow (this sheet + the reward detail sheet).
    var onClose: () -> Void = {}

    @State private var voucherCode: String = EnhancedLoyaltyQRView.makeVoucherCode()
    @State private var expiresAt: Date = Date().addingTimeInterval(15 * 60)
    @State private var now: Date = Date()
    @State private var isApplied: Bool = false
    @State private var isCodeCopied: Bool = false
    @State private var showDetails: Bool = true

    private let redeemedAt = Date()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let brown = Color(hex: "7A4E1D")

    // MARK: - Derived values

    private var secondsRemaining: Int { max(0, Int(expiresAt.timeIntervalSince(now))) }
    private var isExpired: Bool { secondsRemaining == 0 }
    private var currentPoints: Int { loyaltyQR?.currentPoints ?? 0 }
    private var balanceAfter: Int { max(0, currentPoints - reward.pointsRequired) }

    // ADAPT: change to your CartManager's item-count property if it's named differently
    private var bagCount: Int { cartManager.cart.items.count }

    // Free drink item that gets added to the bag (looks in your mock menu)
    private var freeDrinkItem: MenuItem? {
        MockData.menuItems.first {
            $0.name.localizedCaseInsensitiveContains("drink") ||
            $0.name.localizedCaseInsensitiveContains("soda") ||
            $0.name.localizedCaseInsensitiveContains("tea")
        }
    }

    private var resolvedImageName: String {
        if let name = reward.image, !name.isEmpty, UIImage(named: name) != nil { return name }
        return "pizza"
    }

    private var timerText: String {
        isExpired ? "Expired" : String(format: "%02d:%02d", secondsRemaining / 60, secondsRemaining % 60)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    successHeader
                    voucherCard
                    actionButtons
                    infoBox
                    voucherDetailsCard
                    footerLinks

                    Color.clear.frame(height: AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
            }
        }
        .background(AppColors.secondaryBackground.ignoresSafeArea())
        .onReceive(ticker) { now = $0 }
        .presentationDetents([.large])
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: closeFlow) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("Reward Redemption Confirmation")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(2)
                .padding(.leading, 4)

            Spacer()

            Image(systemName: "person.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(AppColors.primaryRed.opacity(0.8)))
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.sm)
    }

    // MARK: - Success Header

    private var successHeader: some View {
        VStack(spacing: AppSpacing.md) {
            ZStack {
                Circle().fill(brown.opacity(0.15)).frame(width: 76, height: 76)
                Circle().fill(brown).frame(width: 50, height: 50)
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            HStack(spacing: 6) {
                Circle().fill(brown).frame(width: 7, height: 7)
                Text("REWARD ACTIVATED")
                    .font(.system(size: 12, weight: .heavy))
                    .tracking(0.5)
                    .foregroundColor(brown)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(hex: "F8DDBB")))

            Text("You redeemed \(reward.name)")
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.primaryRed.opacity(0.7))
                Text("-\(reward.pointsRequired) pts deducted")
                    .font(.system(size: 14, weight: .semibold))
                Text("|").foregroundColor(AppColors.tertiaryText)
                Text("Bal: ").font(.system(size: 14)) +
                Text("\(balanceAfter.formatted()) pts").font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(AppColors.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.black.opacity(0.06)))
        }
    }

    // MARK: - Voucher Card

    private var voucherCard: some View {
        VStack(spacing: 0) {
            // Top: item + timer
            HStack(spacing: AppSpacing.md) {
                Color.clear
                    .frame(width: 68, height: 68)
                    .overlay(Image(resolvedImageName).resizable().scaledToFill())
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("PERK UNLOCKED")
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(0.4)
                            .foregroundColor(brown)

                        Spacer()

                        HStack(spacing: 5) {
                            Circle().fill(AppColors.primaryRed).frame(width: 6, height: 6)
                            Text(timerText)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(AppColors.primaryRed)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppColors.primaryRed.opacity(0.12)))
                    }

                    Text(reward.name)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(1)

                    Text(reward.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                }
            }
            .padding(AppSpacing.lg)

            // Dashed tear line with notches
            ZStack {
                DashedLine()
                    .stroke(AppColors.primaryRed.opacity(0.35),
                            style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                    .frame(height: 1)
                    .padding(.horizontal, AppSpacing.lg)

                HStack {
                    Circle().fill(AppColors.secondaryBackground).frame(width: 22, height: 22).offset(x: -11)
                    Spacer()
                    Circle().fill(AppColors.secondaryBackground).frame(width: 22, height: 22).offset(x: 11)
                }
            }

            // Barcode + code
            VStack(spacing: AppSpacing.md) {
                VStack(spacing: AppSpacing.md) {
                    if let barcode = Self.barcodeImage(for: voucherCode) {
                        Image(uiImage: barcode)
                            .resizable()
                            .interpolation(.none)
                            .frame(height: 64)
                            .padding(AppSpacing.md)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                    }

                    HStack(spacing: 12) {
                        Text(voucherCode)
                            .font(.system(size: 22, weight: .bold, design: .monospaced))
                            .tracking(2)
                            .foregroundColor(AppColors.primaryText)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)

                        Button(action: copyCode) {
                            Image(systemName: isCodeCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isCodeCopied ? AppColors.success : AppColors.secondaryText)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color.black.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.05))
                .opacity(isExpired ? 0.4 : 1)

                Text("Scan barcode at checkout or show code to the squad member at register or drive-thru window.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.sm)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 6)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Button(action: applyToBag) {
            HStack(spacing: 10) {
                Image(systemName: isApplied ? "checkmark.circle.fill" : "bag")
                    .font(.system(size: 16, weight: .semibold))
                Text(isApplied ? "Applied to Bag" : "Apply to Current Bag")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule().fill(isExpired ? AppColors.lightGray : AppColors.primaryRed)
            )
            .shadow(color: isExpired ? .clear : AppColors.primaryRed.opacity(0.3),
                    radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .disabled(isExpired || isApplied)
    }

    // MARK: - Info Box

    private var infoBox: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: "storefront")
                .font(.system(size: 15))
                .foregroundColor(brown)
                .frame(width: 36, height: 36)
                .background(Circle().fill(brown.opacity(0.12)))

            VStack(alignment: .leading, spacing: 3) {
                Text("Dining In or Drive-Thru?")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.primaryText)

                Text("Cashier will scan the ticket barcode above or enter your alphanumeric code directly into POS.")
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.md)
        .background(Color.black.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    // MARK: - Voucher Details

    private var voucherDetailsCard: some View {
        VStack(spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showDetails.toggle() } }) {
                HStack {
                    Text("Voucher Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                        .rotationEffect(.degrees(showDetails ? 0 : -90))
                }
            }
            .buttonStyle(.plain)

            if showDetails {
                VStack(spacing: AppSpacing.lg) {
                    detailRow("Reward Item", reward.name)
                    detailRow("Redeemed At", "Today, \(redeemedAt.formatted(date: .omitted, time: .shortened))")
                    detailRow("Applicable Stores", reward.eligibleLocation ?? "All participating MOD locations")
                    detailRow("Terms", "Single use. Max 1 per order")
                }
                .padding(.top, AppSpacing.lg)
                .transition(.opacity)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(AppColors.secondaryText)
            Spacer(minLength: AppSpacing.md)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Footer

    private var footerLinks: some View {
        HStack {
            Button(action: backToMenu) {
                Text("Back to Menu")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            Button(action: goToBag) {
                Text("View Current Bag (\(bagCount))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(brown)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - Actions / Navigation

    private func copyCode() {
        UIPasteboard.general.string = voucherCode
        isCodeCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isCodeCopied = false }
    }

    /// Adds the free drink to the cart, then closes the sheets and opens the bag.
    private func applyToBag() {
        guard !isExpired, !isApplied else { return }

        if let item = freeDrinkItem {
            // NOTE: make sure this line is priced at $0 (see the note in the chat)
            cartManager.addItem(CartItem(menuItem: item, quantity: 1))
        }

        isApplied = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        // Brief pause so the "Applied to Bag" state is visible, then go to the bag
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            goToBag()
        }
    }

    private func goToBag() {
        appRouter.pendingCartOpen = true
        closeFlow()
    }

    private func backToMenu() {
        appRouter.pendingTab = .menu
        closeFlow()
    }

    private func closeFlow() {
        onClose()                       // the parent closes both sheets
    }

    // MARK: - Static helpers

    private static func makeVoucherCode() -> String {
        let chars = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let suffix = String((0..<4).map { _ in chars.randomElement()! })
        return "MOD-DRK-\(suffix)"
    }

    private static func barcodeImage(for code: String) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(code.utf8)
        filter.quietSpace = 0
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 3, y: 3)),
              let cgImage = CIContext().createCGImage(output, from: output.extent)
        else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Dashed line shape
private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

// Assumes Reward struct has expiryDate: Date?, eligibleLocation: String?, termsAndConditions: String?, termsAndConditionsList: [String]?, image: String? properties. If not, add them in model.

// Add memberID to LoyaltyQR if not present, add a static mock initializer to create one from LoyaltySummary for demo purposes.
extension LoyaltyQR {
    static func mock(from summary: LoyaltySummary) -> LoyaltyQR {
        LoyaltyQR(
            qrCode: "MOCK-QR-\(summary.availablePoints)",
            customerName: "Member \(summary.availablePoints)",
            currentPoints: summary.availablePoints,
            expiresAt: Date().addingTimeInterval(60)
        )
    }
}





// MARK: - Reward Image
struct RewardImage: View {
    let imageName: String?
    var iconSize: CGFloat = 30

    private var assetName: String? {
        if let name = imageName, !name.isEmpty, UIImage(named: name) != nil {
            return name
        }
        return nil
    }

    var body: some View {
        // Color.clear + overlay keeps the photo from stretching the layout
        Color.clear
            .overlay(
                Group {
                    if let name = assetName {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            AppColors.lightGray
                            Image(systemName: "gift.fill")
                                .font(.system(size: iconSize))
                                .foregroundColor(AppColors.mediumGray)
                        }
                    }
                }
            )
            .clipped()
    }
}




#Preview {
    RewardsView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}


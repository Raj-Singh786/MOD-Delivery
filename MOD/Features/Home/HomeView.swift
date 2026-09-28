import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var cartManager: CartManager
    
    @State private var offerBanners: [OfferBanner] = []
    @State private var loyaltySummary: LoyaltySummary?
    @State private var popularItems: [MenuItem] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    private let restaurantRepository = MockRestaurantRepository.shared
    private let loyaltyRepository = MockLoyaltyRepository.shared
    private let menuRepository = MockMenuRepository.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Loading...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Top Navigation
                            topNavigationBar
                            
                            // Order Type Selector
                            orderTypeSelector
                            
                            // Location Permission Banner
                            if !appState.isLocationEnabled {
                                locationPermissionBanner
                            }
                            
                            // Offer Banners
                            offerBannersSection
                            
                            // Loyalty Summary
                            loyaltySummarySection
                            
                            // Popular Items
                            popularItemsSection
                            
                            // Active Offers
                            activeOffersSection
                            
                            // Bottom spacing for tab bar
                            Color.clear
                                .frame(height: 100)
                        }
                    }
                    .refreshable {
                        await loadData()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Top Navigation Bar
    
    private var topNavigationBar: some View {
        HStack {
            // Location Button
            Button(action: {
                appRouter.showRestaurantFinderScreen()
            }) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "location.fill")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryRed)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.isLocationEnabled ? "Current Location" : "Select Location")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(appState.userLocation)
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Profile Button
            Button(action: {
                appRouter.showProfileScreen()
            }) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.white)
    }
    
    // MARK: - Order Type Handler
    
    private func handleOrderTypeSelection(_ orderType: OrderType) {
        appState.setOrderType(orderType)
        
        switch orderType {
        case .takeaway, .dineIn:
            appRouter.showRestaurantSelectionScreen(orderType: orderType)
        case .delivery:
            break
        }
    }
    
    // MARK: - Order Type Selector
    
    private var orderTypeSelector: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(OrderType.allCases, id: \.self) { orderType in
                    OrderTypeButton(
                        orderType: orderType,
                        isSelected: appState.selectedOrderType == orderType,
                        action: {
                            handleOrderTypeSelection(orderType)
                        }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.white)
    }
    
    // MARK: - Location Permission Banner
    
    private var locationPermissionBanner: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primaryRed)
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Find MOD Pizza Near You")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Enable location to discover nearby restaurants and offers.")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
            
            HStack(spacing: AppSpacing.md) {
                PrimaryButton(title: "Allow Location", action: {
                    // Request location permission
                    appState.setLocationEnabled(true)
                })
                
                SecondaryButton(title: "Choose Manually", action: {
                    appRouter.showRestaurantFinderScreen()
                })
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Offer Banners Section
    
    private var offerBannersSection: some View {
        VStack(spacing: AppSpacing.md) {
            if !offerBanners.isEmpty {
                TabView {
                    ForEach(offerBanners) { banner in
                        OfferBannerView(banner: banner)
                    }
                }
                .frame(height: 200)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Loyalty Summary Section
    
    private var loyaltySummarySection: some View {
        VStack(spacing: AppSpacing.md) {
            if let summary = loyaltySummary {
                VStack(spacing: AppSpacing.md) {
                    HStack {
                        Text("Your MOD Rewards")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            appRouter.selectTab(.rewards)
                        }) {
                            Text("View Rewards")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primaryRed)
                        }
                    }
                    
                    HStack(spacing: AppSpacing.lg) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("\(summary.availablePoints)")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.primaryRed)
                            
                            Text("Available Points")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("+\(summary.pendingPoints)")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.warmOrange)
                            
                            Text("Pending")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                    }
                    
                    if let pointsToNext = summary.pointsToNextReward {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("\(pointsToNext) points until ₹100 Off")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                            
                            ProgressView(value: Double(summary.availablePoints), total: Double(summary.availablePoints + pointsToNext))
                                .tint(AppColors.primaryRed)
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .cardStyle()
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.top, AppSpacing.md)
    }
    
    // MARK: - Popular Items Section
    
    private var popularItemsSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Popular at MOD")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: {
                    appRouter.selectTab(.menu)
                }) {
                    Text("View All")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(popularItems.prefix(5)) { item in
                        MenuItemCard(item: item)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Active Offers Section
    
    private var activeOffersSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Latest Offers")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: {
                    appRouter.selectTab(.rewards)
                }) {
                    Text("View All")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(.horizontal, AppSpacing.lg)
            
            // Placeholder for offers
            VStack(spacing: AppSpacing.md) {
                Text("No active offers right now")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let banners = restaurantRepository.getOfferBanners()
            async let loyalty = loyaltyRepository.getLoyaltySummary()
            async let items = menuRepository.getMenuItems()
            
            let (bannersResult, loyaltyResult, itemsResult) = try await (banners, loyalty, items)
            
            await MainActor.run {
                self.offerBanners = bannersResult
                self.loyaltySummary = loyaltyResult
                self.popularItems = itemsResult.filter { $0.isPopular }
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

// MARK: - Order Type Button
struct OrderTypeButton: View {
    let orderType: OrderType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: orderType.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : AppColors.primaryRed)
                
                Text(orderType.displayName)
                    .font(AppFonts.caption)
                    .foregroundColor(isSelected ? .white : AppColors.primaryRed)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .fill(isSelected ? AppColors.primaryRed : AppColors.secondaryBackground)
            )
        }
    }
}

// MARK: - Offer Banner View
struct OfferBannerView: View {
    let banner: OfferBanner
    
    var body: some View {
        ZStack {
            // Background color from banner or default
            Group {
                if let backgroundColor = banner.backgroundColor {
                    Color(hex: backgroundColor)
                } else {
                    AppColors.primaryRed
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.md) {
                Spacer()
                
                VStack(spacing: AppSpacing.sm) {
                    Text(banner.title)
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if !banner.subtitle.isEmpty {
                        Text(banner.subtitle)
                            .font(AppFonts.title)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    Text(banner.description)
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text(banner.callToAction)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryRed)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.md)
                        .background(.white)
                        .cornerRadius(AppSpacing.cornerRadius)
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    @State private var isFavorite: Bool = false

    // Use the item's image if it exists in Assets, otherwise fall back to "pizza"
    private var imageName: String {
        if let name = item.image, UIImage(named: name) != nil {
            return name
        }
        return "pizza"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(AppColors.lightGray)

                Image(imageName)
                    .resizable()
                    .scaledToFill()

                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(isFavorite ? AppColors.primaryRed : AppColors.white)
                        .padding(AppSpacing.sm)
                        .background(Circle().fill(AppColors.shadow))
                }
                .padding(AppSpacing.xs)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.name)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                
                Text(item.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                if let calories = item.calories {
                    Text("\(calories) cal")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                HStack {
                    Text("₹\(Int(item.basePrice))")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
        }
        .frame(width: 140)
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () async -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.error)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Something went wrong")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text(message)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            PrimaryButton(title: "Try Again", action: {
                Task { await retryAction() }
            })
                .padding(.horizontal, AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.primaryBackground)
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
        .environmentObject(CartManager.shared)
}

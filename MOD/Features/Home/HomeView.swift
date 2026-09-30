import SwiftUI

// MARK: - Quick Action Model
enum QuickAction: CaseIterable, Identifiable {
    case deals, rewards, trackOrder, reorder

    var id: Self { self }

    var title: String {
        switch self {
        case .deals:      return "Deals"
        case .rewards:    return "Rewards"
        case .trackOrder: return "Track Order"
        case .reorder:    return "Reorder"
        }
    }

    var icon: String {
        switch self {
        case .deals:      return "tag.fill"
        case .rewards:    return "gift.fill"
        case .trackOrder: return "map.fill"
        case .reorder:    return "arrow.clockwise.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .deals:      return Color(hex: "E2693A")
        case .rewards:    return Color(hex: "2F7D4A")
        case .trackOrder: return Color(hex: "3B82F6")
        case .reorder:    return Color(hex: "C23FD6")
        }
    }

    var tileBackground: Color {
        switch self {
        case .deals:      return Color(hex: "F7E3D0")
        case .rewards:    return Color(hex: "E1E8D0")
        case .trackOrder: return Color(hex: "DDE6E8")
        case .reorder:    return Color(hex: "F5DCE6")
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var cartManager: CartManager
    
    @State private var offerBanners: [OfferBanner] = []
    @State private var loyaltySummary: LoyaltySummary?
    @State private var popularItems: [MenuItem] = []
    @State private var latestOffers: [LatestOffer] = []
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
                            
                            // Quick Actions (NEW)
                            quickActionsSection
                            
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
        HStack(spacing: AppSpacing.md) {
            // Location Button
            Button(action: {
                appRouter.showRestaurantFinderScreen()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "location.north.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.primaryRed)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColors.primaryRed.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(AppColors.primaryRed.opacity(0.12), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(appState.isLocationEnabled ? "Current Location" : "Select Location")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppColors.secondaryText)

                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.tertiaryText)
                        }

                        Text(appState.userLocation)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(1)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Profile Button
            Button(action: {
                appRouter.showProfileScreen()
            }) {
                Image(systemName: "person")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppColors.primaryRed.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppColors.primaryRed.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.md)
        // no white background: header sits on the soft page background
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
        HStack(spacing: 4) {
            ForEach(OrderType.allCases, id: \.self) { orderType in
                OrderTypeButton(
                    orderType: orderType,
                    isSelected: appState.selectedOrderType == orderType,
                    action: { handleOrderTypeSelection(orderType) }
                )
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.black.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appState.selectedOrderType)
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
    
    // MARK: - Quick Actions Section (NEW)
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Quick Actions")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.lg)
            
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                ForEach(QuickAction.allCases) { action in
                    HomeQuickActionTile(action: action) {
                        handleQuickAction(action)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.top, AppSpacing.xl)
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .deals:
            appRouter.selectTab(.rewards)
        case .rewards:
            appRouter.selectTab(.rewards)
        case .trackOrder:
            // TODO: connect to your order tracking screen,
            // e.g. appRouter.showOrderTrackingScreen()
            break
        case .reorder:
            // TODO: connect to your past orders screen / reorder flow,
            // e.g. appRouter.showOrderHistoryScreen()
            break
        }
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
                            Text("+\(summary.pendingPoints) PTS")
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.warmOrange)
                            
                            Text("Pending Verification")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                    }
                    
                    if let pointsToNext = summary.pointsToNextReward {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            let progress = Int((Double(summary.availablePoints) / Double(summary.availablePoints + pointsToNext)) * 100)
                            Text("\(pointsToNext) points until $100 Off")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                            
                            HStack {
                                ProgressView(value: Double(summary.availablePoints), total: Double(summary.availablePoints + pointsToNext))
                                    .tint(AppColors.primaryRed)
                                
                                Spacer()
                                
                                Text("\(progress)%")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .cardStyle()
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.top, AppSpacing.xl)
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
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest Offers")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(AppColors.primaryText)

                    Text("Exclusive deals handpicked for you")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.tertiaryText)
                }

                Spacer()

                Button(action: { appRouter.selectTab(.rewards) }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 15, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(AppColors.primaryRed)
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, AppSpacing.lg)

            if !latestOffers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(Array(latestOffers.enumerated()), id: \.element.id) { index, offer in
                            LatestOfferCard(
                                offer: offer,
                                style: index % 2 == 0 ? .red : .dark
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
            } else {
                Text("No active offers right now")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .padding(AppSpacing.xl)
                    .frame(maxWidth: .infinity)
                    .background(AppColors.white)
                    .cornerRadius(AppSpacing.cornerRadius)
                    .padding(.horizontal, AppSpacing.lg)
            }
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
                self.latestOffers = MockData.latestOffers.filter { $0.isActive }
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

// MARK: - Quick Action Button (NEW)
// MARK: - Home Quick Action Tile
struct HomeQuickActionTile: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: action.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(action.tint)
                    .frame(width: 72, height: 72)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(action.tileBackground)
                    )

                Text(action.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(QuickActionPressStyle())
        .accessibilityLabel(action.title)
    }
}

// Subtle press animation for the tiles
struct QuickActionPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Order Type Button
struct OrderTypeButton: View {
    let orderType: OrderType
    let isSelected: Bool
    let action: () -> Void

    // Outline-style icons to match the new design
    private var iconName: String {
        switch orderType {
        case .delivery: return "bicycle"
        case .takeaway: return "bag"
        case .dineIn:   return "fork.knife"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .semibold))

                Text(orderType.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? .white : Color.black.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColors.primaryRed,
                                        AppColors.primaryRed.opacity(0.75)
                                            .mix(with: .black, by: 0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppColors.primaryRed.opacity(0.35),
                                    radius: 8, x: 0, y: 4)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Offer Banner View
struct OfferBannerView: View {
    @EnvironmentObject var appRouter: AppRouter
    let banner: OfferBanner

    private var baseColor: Color {
        if let hex = banner.backgroundColor {
            return Color(hex: hex)
        }
        return AppColors.primaryRed
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: AppSpacing.sm) {
                Spacer()

                VStack(spacing: AppSpacing.xs) {
                    Text(banner.title)
                        .font(AppFonts.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if !banner.subtitle.isEmpty {
                        Text(banner.subtitle)
                            .font(AppFonts.title)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                if let des = banner.description, !des.isEmpty {
                    Text(des)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button(action: {
                    appRouter.navigateToMenu()
                }) {
                    Text(banner.callToAction)
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.sm)
                        .background(.white)
                        .cornerRadius(AppSpacing.cornerRadius)
                }

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius))
    }

    // Blurred pizza image over the red, with a dark fade toward the bottom-right
    private var backgroundLayer: some View {
        ZStack {
            baseColor

            // Color.clear + overlay keeps the image from expanding the banner's size
            Color.clear
                .overlay(
                    Image("pizza")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 10)
                        .opacity(0.3)
                        .blendMode(.overlay)
                )
                .clipped()

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.45)],
                startPoint: .top,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    @State private var isFavorite: Bool = false

    private let cardWidth: CGFloat = 220
    private let imageHeight: CGFloat = 190
    private let bestsellerColor = Color(hex: "E0913A")

    // Use the item's image if it exists in Assets, otherwise fall back to "pizza"
    private var imageName: String {
        if let name = item.image, UIImage(named: name) != nil {
            return name
        }
        return "pizza"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageSection
            infoSection
        }
        .frame(width: cardWidth)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    // MARK: - Image + overlays
    private var imageSection: some View {
        // Color.clear + overlay keeps the image from expanding the card's width
        Color.clear
            .frame(height: imageHeight)
            .overlay(
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
            .overlay(alignment: .topTrailing) {
                Button(action: { isFavorite.toggle() }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isFavorite ? AppColors.primaryRed : AppColors.primaryText.opacity(0.7))
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white.opacity(0.9)))
                }
                .buttonStyle(.plain)
                .padding(12)
            }
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 8) {
                    if item.isPopular {
                        Text("BESTSELLER")
                            .font(.system(size: 12, weight: .heavy))
                            .tracking(0.8)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(bestsellerColor))
                    }

                    if let calories = item.calories {
                        Text("\(calories) cal")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.black.opacity(0.55)))
                    }
                }
                .padding(12)
            }
    }

    // MARK: - Title, description, price
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)

            Text(item.description)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .lineSpacing(3)
                .lineLimit(2, reservesSpace: true) // keeps all cards the same height

            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)
                .padding(.top, 4)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("$\(Int(item.basePrice))")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(AppColors.primaryRed)

                if item.isCustomizable {
                    Text("starts at")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.tertiaryText)
                }

                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 18)
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

// MARK: - Latest Offer Card

enum OfferCardStyle {
    case red, dark

    var gradient: LinearGradient {
        switch self {
        case .red:
            return LinearGradient(
                colors: [Color(hex: "A0281F"), Color(hex: "7A130F"), Color(hex: "5E0D0A")],
                startPoint: .topTrailing, endPoint: .bottomLeading)
        case .dark:
            return LinearGradient(
                colors: [Color(hex: "2E2E2E"), Color(hex: "1C1C1C")],
                startPoint: .topTrailing, endPoint: .bottomLeading)
        }
    }

    var badgeBackground: Color {
        switch self {
        case .red:  return Color(hex: "F6C244")
        case .dark: return AppColors.primaryRed
        }
    }

    var badgeForeground: Color {
        switch self {
        case .red:  return Color(hex: "3A2A00")
        case .dark: return .white
        }
    }

    var borderColor: Color {
        switch self {
        case .red:  return Color(hex: "B0352B")
        case .dark: return Color.white.opacity(0.12)
        }
    }

    var buttonForeground: Color {
        switch self {
        case .red:  return Color(hex: "7A130F")
        case .dark: return .black
        }
    }
}

struct LatestOfferCard: View {
    let offer: LatestOffer
    var style: OfferCardStyle = .red
    @State private var isCodeCopied = false

    private let gold = Color(hex: "F6C244")

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Badge + timer
            HStack {
                Text(offer.title.uppercased())
                    .font(.system(size: 13, weight: .heavy))
                    .tracking(1.2)
                    .foregroundColor(style.badgeForeground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(style.badgeBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(gold)
                    Text(offer.timeRemaining)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.22))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // Heading + details
            VStack(alignment: .leading, spacing: 6) {
                Text(offer.title)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(offer.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(3)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)

            // Code + Apply
            HStack {
                Button(action: copyCode) {
                    Text(isCodeCopied ? "COPIED" : offer.promoCode)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundColor(isCodeCopied ? .green : gold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.35),
                                              style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        )
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: { /* apply code to cart */ }) {
                    Text("Apply Code")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(style.buttonForeground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 11)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.lg)
        .frame(width: 320)
        .background(style.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(style.borderColor, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    private func copyCode() {
        UIPasteboard.general.string = offer.promoCode
        isCodeCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isCodeCopied = false }
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

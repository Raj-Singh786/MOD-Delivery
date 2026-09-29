import SwiftUI
import Combine

// MARK: - App Router
@MainActor
class AppRouter: ObservableObject {
    @Published var currentTab: AppTab = .home
    @Published var selectedRestaurant: Restaurant?
    @Published var showProfile: Bool = false
    @Published var showCart: Bool = false
    @Published var showCheckout: Bool = false
    @Published var showPizzaBuilder: Bool = false
    @Published var selectedMenuItem: MenuItem?
    @Published var showRestaurantFinder: Bool = false
    @Published var showRestaurantSelection: Bool = false
    @Published var selectedOrderTypeForSelection: OrderType?
    @Published var showOrderTracking: Bool = false
    @Published var trackingOrderId: String?
    
    // Navigation paths for deep linking
    @Published var homePath: NavigationPath = NavigationPath()
    @Published var menuPath: NavigationPath = NavigationPath()
    @Published var rewardsPath: NavigationPath = NavigationPath()
    
    
    @Published var pendingCartOpen: Bool = false
    @Published var pendingTab: AppTab?
    
    enum AppTab: String, CaseIterable {
        case home = "home"
        case menu = "menu"
        case rewards = "rewards"
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .menu: return "Menu"
            case .rewards: return "Rewards"
            }
        }
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .menu: return "list.bullet"
            case .rewards: return "gift.fill"
            }
        }
    }
    
    // MARK: - Tab Navigation
    
    func selectTab(_ tab: AppTab) {
        currentTab = tab
    }
    
    // MARK: - Feature Navigation
    
    func showProfileScreen() {
        showProfile = true
    }
    
    func hideProfileScreen() {
        showProfile = false
    }
    
    func showCartScreen() {
        if showCart {
            // Flag is stuck as true: reset it, then present again
            Task {
                showCart = false
                try? await Task.sleep(nanoseconds: 250_000_000)
                showCart = true
            }
        } else {
            showCart = true
        }
    }
    
    func hideCartScreen() {
        showCart = false
    }
    
    func showCheckoutScreen() {
        showCheckout = true
    }
    
    func hideCheckoutScreen() {
        showCheckout = false
    }
    
    func showPizzaBuilderScreen(menuItem: MenuItem) {
        selectedMenuItem = menuItem
        showPizzaBuilder = true
    }
    
    func hidePizzaBuilderScreen() {
        selectedMenuItem = nil
        showPizzaBuilder = false
    }
    
    func showRestaurantFinderScreen() {
        showRestaurantFinder = true
    }
    
    func hideRestaurantFinderScreen() {
        showRestaurantFinder = false
    }
    
    func showRestaurantSelectionScreen(orderType: OrderType) {
        selectedOrderTypeForSelection = orderType
        showRestaurantSelection = true
    }
    
    func hideRestaurantSelectionScreen() {
        showRestaurantSelection = false
        selectedOrderTypeForSelection = nil
    }
    
    func showOrderTrackingScreen(orderId: String) {
        trackingOrderId = orderId
        showOrderTracking = true
    }
    
    func hideOrderTrackingScreen() {
        trackingOrderId = nil
        showOrderTracking = false
    }
    
    // MARK: - Path Navigation
    
    func navigateToHome() {
        currentTab = .home
        homePath = NavigationPath()
    }
    
    func navigateToMenu() {
        currentTab = .menu
        menuPath = NavigationPath()
    }
    
    func navigateToRewards() {
        currentTab = .rewards
        rewardsPath = NavigationPath()
    }
    
    // MARK: - Reset
    
    func resetNavigation() {
        currentTab = .home
        homePath = NavigationPath()
        menuPath = NavigationPath()
        rewardsPath = NavigationPath()
        showProfile = false
        showCart = false
        showCheckout = false
        showPizzaBuilder = false
        selectedMenuItem = nil
        showRestaurantFinder = false
        showRestaurantSelection = false
        selectedOrderTypeForSelection = nil
        showOrderTracking = false
        trackingOrderId = nil
    }
}

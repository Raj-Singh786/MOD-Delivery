import SwiftUI

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        TabView(selection: $appRouter.currentTab) {
            HomeView()
                .tabItem {
                    Label(AppRouter.AppTab.home.title, systemImage: AppRouter.AppTab.home.icon)
                }
                .tag(AppRouter.AppTab.home)
            
            MenuView()
                .tabItem {
                    Label(AppRouter.AppTab.menu.title, systemImage: AppRouter.AppTab.menu.icon)
                }
                .tag(AppRouter.AppTab.menu)
            
            RewardsView()
                .tabItem {
                    Label(AppRouter.AppTab.rewards.title, systemImage: AppRouter.AppTab.rewards.icon)
                }
                .tag(AppRouter.AppTab.rewards)
        }
        .tint(AppColors.primaryRed)
        .overlay(
            cartButton
                .padding(.trailing, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl),
            alignment: .bottomTrailing
        )
        .sheet(isPresented: $appRouter.showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $appRouter.showCart) {
            CartView()
        }
        .sheet(isPresented: $appRouter.showCheckout) {
            CheckoutView()
        }
        .sheet(isPresented: $appRouter.showPizzaBuilder) {
            if let menuItem = appRouter.selectedMenuItem {
                PizzaBuilderView(menuItem: menuItem)
            }
        }
        .sheet(isPresented: $appRouter.showRestaurantFinder) {
            RestaurantFinderView()
        }
        .sheet(isPresented: $appRouter.showRestaurantSelection) {
            if let orderType = appRouter.selectedOrderTypeForSelection {
                RestaurantSelectionView(orderType: orderType)
            }
        }
        .sheet(isPresented: $appRouter.showOrderTracking) {
            if let orderId = appRouter.trackingOrderId {
                OrderTrackingView(orderId: orderId)
            }
        }
    }
    
    // MARK: - Cart Button
    
    private var cartButton: some View {
        Button(action: {
            appRouter.showCartScreen()
        }) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryRed)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
                
                Image(systemName: "cart.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                if cartManager.cart.itemCount > 0 {
                    Circle()
                        .fill(AppColors.warmOrange)
                        .frame(width: 20, height: 20)
                        .offset(x: 16, y: -16)
                    
                    Text("\(cartManager.cart.itemCount)")
                        .font(AppFonts.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(x: 16, y: -16)
                }
            }
        }
    }
}



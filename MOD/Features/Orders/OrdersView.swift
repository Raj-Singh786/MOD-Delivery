import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var selectedTab: OrderTab = .active
    @State private var activeOrders: [Order] = []
    @State private var pastOrders: [Order] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    private let orderRepository = MockOrderRepository.shared
    
    enum OrderTab: String, CaseIterable {
        case active = "active"
        case past = "past"
        
        var displayName: String {
            switch self {
            case .active: return "Active"
            case .past: return "Past"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Loading orders...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else {
                    VStack(spacing: 0) {
                        // Tab Selector
                        orderTabSelector
                        
                        // Orders List
                        ScrollView {
                            VStack(spacing: AppSpacing.md) {
                                if selectedTab == .active {
                                    if activeOrders.isEmpty {
                                        emptyOrdersView(type: .active)
                                    } else {
                                        ForEach(activeOrders) { order in
                                            OrderCard(order: order)
                                                .padding(.horizontal, AppSpacing.lg)
                                        }
                                    }
                                } else {
                                    if pastOrders.isEmpty {
                                        emptyOrdersView(type: .past)
                                    } else {
                                        ForEach(pastOrders) { order in
                                            OrderCard(order: order)
                                                .padding(.horizontal, AppSpacing.lg)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, AppSpacing.md)
                        }
                    }
                }
            }
            .navigationTitle("My Orders")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadData()
            }
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Order Tab Selector
    
    private var orderTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(OrderTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.displayName)
                        .font(AppFonts.callout)
                        .foregroundColor(selectedTab == tab ? AppColors.primaryRed : AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            selectedTab == tab ? Color.clear : Color.clear
                        )
                }
            }
        }
        .background(AppColors.white)
        .overlay(
            VStack {
                Spacer()
                if selectedTab == .active {
                    Rectangle()
                        .fill(AppColors.primaryRed)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                } else {
                    Rectangle()
                        .fill(AppColors.primaryRed)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .offset(x: selectedTab == .active ? 0 : UIScreen.main.bounds.width / 2)
                }
            }
        )
    }
    
    // MARK: - Empty Orders View
    
    private func emptyOrdersView(type: OrderTab) -> some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image(systemName: type == .active ? "clock.badge.questionmark" : "clock.badge.checkmark")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text(type == .active ? "No Active Orders" : "No Past Orders")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text(type == .active ? "Your active orders will appear here." : "Your order history will appear here.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            if type == .active {
                PrimaryButton(title: "Start Ordering", action: {
                    appRouter.selectTab(.home)
                })
                .padding(.horizontal, AppSpacing.xl)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let active = orderRepository.getActiveOrders()
            async let past = orderRepository.getPastOrders()
            
            let (activeResult, pastResult) = try await (active, past)
            
            await MainActor.run {
                self.activeOrders = activeResult
                self.pastOrders = pastResult
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

// MARK: - Order Card
struct OrderCard: View {
    let order: Order
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Order Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Order #\(order.orderNumber)")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(formatDate(order.createdAt))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Spacer()
                
                // Status Badge
                StatusBadge(status: order.status)
            }
            
            // Items Summary
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                ForEach(order.items.prefix(2)) { item in
                    Text(item.displayName)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                if order.items.count > 2 {
                    Text("+ \(order.items.count - 2) more items")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
            
            // Total
            HStack {
                Text("Total")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("₹\(Int(order.total))")
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }
            
            // Actions
            HStack(spacing: AppSpacing.md) {
                if order.status.isActive {
                    Button(action: {
                        appRouter.showOrderTrackingScreen(orderId: order.id)
                    }) {
                        Text("Track Order")
                            .font(AppFonts.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.sm)
                            .background(AppColors.primaryRed)
                            .cornerRadius(AppSpacing.smallCornerRadius)
                    }
                }
                
                Button(action: {
                    // View order details
                }) {
                    Text("View Details")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
                
                if order.status.isCompleted {
                    Button(action: {
                        // Reorder
                    }) {
                        Text("Reorder")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.displayName)
            .font(AppFonts.caption)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(statusColor)
            .cornerRadius(AppSpacing.smallCornerRadius)
    }
    
    private var statusColor: Color {
        switch status {
        case .placed, .confirmed:
            return AppColors.info
        case .preparing, .ready:
            return AppColors.warning
        case .outForDelivery:
            return AppColors.primaryRed
        case .delivered, .completed:
            return AppColors.success
        case .cancelled:
            return AppColors.error
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(AppRouter())
        .environmentObject(AppState.shared)
}

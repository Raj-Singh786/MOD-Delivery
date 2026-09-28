import SwiftUI

struct OrderTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appRouter: AppRouter
    
    let orderId: String
    
    @State private var order: Order?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    private let orderRepository = MockOrderRepository.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Loading order status...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else if let order = order {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: AppSpacing.xl) {
                                // Order Info
                                orderInfoSection(order: order)
                                
                                // Progress Timeline
                                progressTimelineSection(order: order)
                                
                                // Estimated Time
                                estimatedTimeSection(order: order)
                                
                                // Order Details
                                orderDetailsSection(order: order)
                                
                                // Loyalty Points
                                if let points = order.loyaltyPointsEarned {
                                    loyaltyPointsSection(points: points)
                                }
                                
                                // Bottom spacing
                                Color.clear
                                    .frame(height: 100)
                            }
                            .padding(.vertical, AppSpacing.md)
                        }
                        
                        // Action Buttons
                        actionButtonsSection(order: order)
                    }
                }
            }
            .navigationTitle("Track Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Order Info Section
    
    private func orderInfoSection(order: Order) -> some View {
        VStack(spacing: AppSpacing.md) {
            // Success Animation
            ZStack {
                Circle()
                    .fill(AppColors.success.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.success)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("Order #\(order.orderNumber)")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Your order has been received")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Progress Timeline Section
    
    private func progressTimelineSection(order: Order) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Order Progress")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: 0) {
                ForEach(Array(OrderStatus.allCases.enumerated()), id: \.element) { index, status in
                    TimelineStep(
                        status: status,
                        currentStatus: order.status,
                        isLast: index == OrderStatus.allCases.count - 1
                    )
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Estimated Time Section
    
    private func estimatedTimeSection(order: Order) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Estimated Ready Time")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            if let estimatedTime = order.estimatedTime {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text(formatTime(estimatedTime))
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                }
            } else {
                Text("Calculating...")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Order Details Section
    
    private func orderDetailsSection(order: Order) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Order Details")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(order.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(item.displayName)
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primaryText)
                            
                            if let calories = item.totalCalories {
                                Text("\(calories) cal")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.tertiaryText)
                            }
                        }
                        
                        Spacer()
                        
                        Text("x\(item.quantity)")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("₹\(Int(item.totalPrice))")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Subtotal")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("₹\(Int(order.subtotal))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryText)
                }
                
                if order.deliveryFee > 0 {
                    HStack {
                        Text("Delivery Fee")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                        
                        Text("₹\(Int(order.deliveryFee))")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                
                HStack {
                    Text("Tax")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("₹\(Int(order.tax))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryText)
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text("₹\(Int(order.total))")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Loyalty Points Section
    
    private func loyaltyPointsSection(points: Int) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.gold)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("+\(points) Points Pending")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Points will be added to your rewards after order completion")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Action Buttons Section
    
    private func actionButtonsSection(order: Order) -> some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.md) {
                if order.status.isCompleted {
                    PrimaryButton(title: "Order Again", action: {
                        // Reorder logic
                        dismiss()
                        appRouter.selectTab(.home)
                    })
                    
                    SecondaryButton(title: "View Order Details", action: {
                        // View details logic
                    })
                } else {
                    Button(action: {
                        // Contact support
                    }) {
                        Text("Need Help?")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let orderData = try await orderRepository.getOrder(orderId: orderId)
            
            await MainActor.run {
                self.order = orderData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Timeline Step
struct TimelineStep: View {
    let status: OrderStatus
    let currentStatus: OrderStatus
    let isLast: Bool
    
    private var isCompleted: Bool {
        let statusOrder: [OrderStatus] = [
            .placed, .confirmed, .preparing, .ready, .outForDelivery, .delivered, .completed
        ]
        
        guard let currentIndex = statusOrder.firstIndex(of: currentStatus),
              let stepIndex = statusOrder.firstIndex(of: status) else {
            return false
        }
        
        return stepIndex <= currentIndex
    }
    
    private var isCurrent: Bool {
        status == currentStatus
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Circle
            ZStack {
                Circle()
                    .fill(isCompleted ? AppColors.success : AppColors.lightGray)
                    .frame(width: 20, height: 20)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Label
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(status.displayName)
                    .font(AppFonts.subheadline)
                    .foregroundColor(isCompleted ? AppColors.primaryText : AppColors.tertiaryText)
                
                if isCurrent {
                    Text("In Progress")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            
            Spacer()
            
            // Line
            if !isLast {
                Rectangle()
                    .fill(isCompleted ? AppColors.success : AppColors.lightGray)
                    .frame(width: 2, height: 40)
                    .offset(x: -30, y: 20)
            }
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

#Preview {
    OrderTrackingView(orderId: "test-order-id")
        .environmentObject(AppRouter())
}

import SwiftUI

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var selectedAddress: Address?
    @State private var selectedPaymentMethod: PaymentMethod?
    @State private var showAddressPicker: Bool = false
    @State private var showPaymentPicker: Bool = false
    @State private var showRestaurantPicker: Bool = false
    @State private var showLogin: Bool = false
    @State private var isProcessingOrder: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Order Type
                        orderTypeSection
                        
                        // Restaurant
                        restaurantSection
                        
                        // Items Summary
                        itemsSummarySection
                        
                        // Address (for delivery)
                        if cartManager.cart.orderType == .delivery {
                            addressSection
                        }
                        
                        // Contact
                        contactSection
                        
                        // Payment
                        paymentSection
                        
                        // Order Summary
                        orderSummarySection
                        
                        // Bottom spacing
                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.vertical, AppSpacing.md)
                }
                
                // Place Order Button
                placeOrderButton
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddressPicker) {
                AddressPickerView(selectedAddress: $selectedAddress)
            }
            .sheet(isPresented: $showPaymentPicker) {
                PaymentPickerView(selectedPaymentMethod: $selectedPaymentMethod)
            }
            .sheet(isPresented: $showRestaurantPicker) {
                RestaurantPickerView(selectedRestaurant: $cartManager.cart.restaurant)
            }
            .sheet(isPresented: $showLogin) {
                LoginView(onLoginComplete: {
                    showLogin = false
                })
                .environmentObject(appState)
                .environmentObject(appRouter)
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Order Type Section
    
    private var orderTypeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Order Type")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(OrderType.allCases, id: \.self) { orderType in
                    OrderTypeChip(
                        orderType: orderType,
                        isSelected: cartManager.cart.orderType == orderType,
                        action: {
                            cartManager.setOrderType(orderType)
                        }
                    )
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Restaurant Section
    
    private var restaurantSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Restaurant")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            if let restaurant = cartManager.cart.restaurant {
                RestaurantInfoCard(restaurant: restaurant, action: {
                    showRestaurantPicker = true
                })
            } else {
                Button(action: {
                    showRestaurantPicker = true
                }) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text("Select Restaurant")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Items Summary Section
    
    private var itemsSummarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Items (\(cartManager.cart.itemCount))")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(cartManager.cart.items.prefix(3)) { item in
                    HStack {
                        Text(item.displayName)
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Text("x\(item.quantity)")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("₹\(Int(item.totalPrice))")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryText)
                    }
                }
                
                if cartManager.cart.items.count > 3 {
                    Text("+ \(cartManager.cart.items.count - 3) more items")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Address Section
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Delivery Address")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            if let address = selectedAddress {
                AddressCard(address: address, action: {
                    showAddressPicker = true
                })
            } else {
                Button(action: {
                    showAddressPicker = true
                }) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text("Add Delivery Address")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Contact Section
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Contact Information")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.sm) {
                TextField("Name", text: .constant(""))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
                
                TextField("Mobile Number", text: .constant(""))
                    .keyboardType(.phonePad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Payment Section
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Payment Method")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            
            if let paymentMethod = selectedPaymentMethod {
                PaymentMethodCard(paymentMethod: paymentMethod, action: {
                    showPaymentPicker = true
                })
            } else {
                Button(action: {
                    showPaymentPicker = true
                }) {
                    HStack {
                        Image(systemName: "creditcard.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text("Select Payment Method")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Order Summary Section
    
    private var orderSummarySection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Subtotal")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("₹\(Int(cartManager.cart.subtotal))")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.primaryText)
            }
            
            if cartManager.deliveryFee > 0 {
                HStack {
                    Text("Delivery Fee")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("₹\(Int(cartManager.deliveryFee))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            HStack {
                Text("Tax (5%)")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("₹\(Int(cartManager.tax))")
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
                
                Text("₹\(Int(cartManager.total))")
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Place Order Button
    
    private var placeOrderButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.md) {
                // Check if login required
                if !appState.isAuthenticated {
                    VStack(spacing: AppSpacing.sm) {
                        Text("Almost Ready!")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("Login with your mobile number to continue with your order.")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        PrimaryButton(title: "Continue with OTP", action: {
                            showLogin = true
                        })
                    }
                    .padding(AppSpacing.lg)
                } else {
                    HStack {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Total")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                            
                            Text("₹\(Int(cartManager.total))")
                                .font(AppFonts.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryRed)
                        }
                        
                        Spacer()
                        
                        PrimaryButton(
                            title: "Place Order",
                            action: placeOrder,
                            isLoading: isProcessingOrder,
                            isDisabled: !isCheckoutValid
                        )
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
    
    // MARK: - Validation
    
    private var isCheckoutValid: Bool {
        cartManager.cart.restaurant != nil &&
        (cartManager.cart.orderType != .delivery || selectedAddress != nil) &&
        selectedPaymentMethod != nil
    }
    
    // MARK: - Place Order
    
    private func placeOrder() {
        isProcessingOrder = true
        
        Task {
            do {
                // Create order
                let order = Order(
                    orderNumber: "MOD\(Int.random(in: 10000...99999))",
                    orderType: cartManager.cart.orderType,
                    restaurant: cartManager.cart.restaurant!,
                    items: cartManager.cart.items,
                    subtotal: cartManager.cart.subtotal,
                    deliveryFee: cartManager.deliveryFee,
                    tax: cartManager.tax,
                    total: cartManager.total,
                    customer: appState.currentUser,
                    address: selectedAddress,
                    paymentMethod: selectedPaymentMethod
                )
                
                let createdOrder = try await MockOrderRepository.shared.createOrder(order: order)
                
                await MainActor.run {
                    isProcessingOrder = false
                    cartManager.clearCart()
                    dismiss()
                    appRouter.showOrderTrackingScreen(orderId: createdOrder.id)
                }
            } catch {
                await MainActor.run {
                    isProcessingOrder = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Order Type Chip
struct OrderTypeChip: View {
    let orderType: OrderType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: orderType.icon)
                    .font(.system(size: 16))
                
                Text(orderType.displayName)
                    .font(AppFonts.subheadline)
            }
            .foregroundColor(isSelected ? .white : AppColors.primaryText)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primaryRed : AppColors.secondaryBackground)
            )
        }
    }
}

// MARK: - Restaurant Info Card
struct RestaurantInfoCard: View {
    let restaurant: Restaurant
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(restaurant.name)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(restaurant.distanceString)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(AppSpacing.md)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppSpacing.cornerRadius)
        }
    }
}

// MARK: - Address Card
struct AddressCard: View {
    let address: Address
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(address.fullName)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(address.fullAddress)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(AppSpacing.md)
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppSpacing.cornerRadius)
        }
    }
}

// MARK: - Payment Method Card
struct PaymentMethodCard: View {
    let paymentMethod: PaymentMethod
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(paymentMethod.displayName)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    if let lastFour = paymentMethod.lastFour {
                        Text("•••• \(lastFour)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(AppSpacing.md)
            .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
        }
    }
}

// MARK: - Address Picker View (Placeholder)
struct AddressPickerView: View {
    @Binding var selectedAddress: Address?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Address Picker")
                    .font(AppFonts.headline)
                
                // Placeholder for address selection
                Text("Select or add an address")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Select Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Payment Picker View (Placeholder)
struct PaymentPickerView: View {
    @Binding var selectedPaymentMethod: PaymentMethod?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Payment Picker")
                    .font(AppFonts.headline)
                
                // Placeholder for payment method selection
                Text("Select a payment method")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Select Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Restaurant Picker View (Placeholder)
struct RestaurantPickerView: View {
    @Binding var selectedRestaurant: Restaurant?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Restaurant Picker")
                    .font(AppFonts.headline)
                
                // Placeholder for restaurant selection
                Text("Select a restaurant")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Select Restaurant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CheckoutView()
        .environmentObject(CartManager.shared)
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

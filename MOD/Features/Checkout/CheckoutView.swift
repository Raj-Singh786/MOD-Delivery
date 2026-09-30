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
    //@State private var showLogin: Bool = false
    @State private var isProcessingOrder: Bool = false
    @State private var errorMessage: String?
    
    
    @State private var savedAddresses: [Address] = []
    @State private var customerName: String = ""
    @State private var customerPhone: String = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
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
            .onAppear { syncOrderType() }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddressPicker) {
                AddressPickerView(selectedAddress: $selectedAddress,
                                  savedAddresses: $savedAddresses)
            }
            .sheet(isPresented: $showPaymentPicker) {
                PaymentPickerView(selectedPaymentMethod: $selectedPaymentMethod,
                                  orderType: cartManager.cart.orderType)
            }
            .sheet(isPresented: $showRestaurantPicker) {
                RestaurantPickerView(selectedRestaurant: $cartManager.cart.restaurant)
            }
//            .sheet(isPresented: $showLogin) {
//                LoginView(onLoginComplete: {
//                    showLogin = false
//                })
//                .environmentObject(appState)
//                .environmentObject(appRouter)
//            }
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

            HStack(spacing: AppSpacing.xs) {
                Image(systemName: cartManager.cart.orderType.icon)
                    .font(.system(size: 16))

                Text(cartManager.cart.orderType.displayName)
                    .font(AppFonts.subheadline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(Capsule().fill(AppColors.primaryRed))
        }
        .frame(maxWidth: .infinity, alignment: .leading)   // keeps the card full width
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
                TextField("Name", text: $customerName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(AppSpacing.md)
                    .background(AppColors.secondaryBackground)
                    .cornerRadius(AppSpacing.cornerRadius)
                
                TextField("Mobile Number", text: $customerPhone)
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
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
    
    private func syncOrderType() {
        let selected: OrderType? = appState.selectedOrderType
        if let selected, cartManager.cart.orderType != selected {
            cartManager.setOrderType(selected)
        }
    }
    
    // MARK: - Validation
    
    private var isCheckoutValid: Bool {
        cartManager.cart.restaurant != nil &&
        (cartManager.cart.orderType != .delivery || selectedAddress != nil) &&
        selectedPaymentMethod != nil &&
        !customerName.trimmingCharacters(in: .whitespaces).isEmpty &&
        customerPhone.filter(\.isNumber).count == 10
    }
    
    // MARK: - Place Order
    
    private func placeOrder() {
        guard let restaurant = cartManager.cart.restaurant else { return }
        isProcessingOrder = true

        Task {
            do {
                let order = Order(
                    orderNumber: "MOD\(Int.random(in: 10000...99999))",
                    orderType: cartManager.cart.orderType,
                    restaurant: restaurant,
                    items: cartManager.cart.items,
                    subtotal: cartManager.cart.subtotal,
                    deliveryFee: cartManager.deliveryFee,
                    tax: cartManager.tax,
                    total: cartManager.total,
                    customer: Customer(name: customerName.trimmingCharacters(in: .whitespaces),
                                       mobileNumber: customerPhone),
                    address: selectedAddress,
                    paymentMethod: selectedPaymentMethod
                )

                let createdOrder = try await MockOrderRepository.shared.createOrder(order: order)

                await MainActor.run {
                    isProcessingOrder = false
                    cartManager.clearCart()
                    dismiss()
                    appRouter.hideCheckoutScreen()
                    appRouter.hideCartScreen()
                }

                // Wait for the sheets to finish closing, then open tracking
                try? await Task.sleep(nanoseconds: 600_000_000)

                await MainActor.run {
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
//struct AddressPickerView: View {
//    @Binding var selectedAddress: Address?
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Address Picker")
//                    .font(AppFonts.headline)
//                
//                // Placeholder for address selection
//                Text("Select or add an address")
//                    .font(AppFonts.subheadline)
//                    .foregroundColor(AppColors.secondaryText)
//            }
//            .navigationTitle("Select Address")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}

// MARK: - Payment Picker View (Placeholder)
//struct PaymentPickerView: View {
//    @Binding var selectedPaymentMethod: PaymentMethod?
//    @Environment(\.dismiss) private var dismiss
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Payment Picker")
//                    .font(AppFonts.headline)
//                
//                // Placeholder for payment method selection
//                Text("Select a payment method")
//                    .font(AppFonts.subheadline)
//                    .foregroundColor(AppColors.secondaryText)
//            }
//            .navigationTitle("Select Payment")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}

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

//MARK: - Extension Method for Address Picker and payment picker



// MARK: - Payment Picker

private struct PaymentOption: Identifiable {
    let id: String
    let type: PaymentMethod.PaymentType
    let title: String
    let subtitle: String
    let icon: String
    let lastFour: String?
}

struct PaymentPickerView: View {
    @Binding var selectedPaymentMethod: PaymentMethod?
    var orderType: OrderType = .delivery
    @Environment(\.dismiss) private var dismiss

    private var options: [PaymentOption] {
        [
            PaymentOption(id: "pay_upi", type: .upi, title: "UPI",
                          subtitle: "PhonePe, Paytm, BHIM and more",
                          icon: "indianrupeesign.circle.fill", lastFour: nil),
            PaymentOption(id: "pay_card", type: .creditCard, title: "Visa Card",
                          subtitle: "Saved credit / debit card",
                          icon: "creditcard.fill", lastFour: "4242"),
            PaymentOption(id: "pay_gpay", type: .googlePay, title: "Google Pay",
                          subtitle: "Pay with your Google Pay account",
                          icon: "g.circle.fill", lastFour: nil),
            PaymentOption(id: "pay_cash", type: .cash,
                          title: orderType == .delivery ? "Cash on Delivery" : "Pay at Restaurant",
                          subtitle: orderType == .delivery ? "Pay when your order arrives" : "Pay when you pick up",
                          icon: "banknote.fill", lastFour: nil)
        ]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(options) { option in
                        optionRow(option)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                        Text("Payments are secure and encrypted")
                    }
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.tertiaryText)
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Select Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func optionRow(_ option: PaymentOption) -> some View {
        let isSelected = selectedPaymentMethod?.id == option.id

        return Button(action: {
            selectedPaymentMethod = PaymentMethod(
                id: option.id,
                type: option.type,
                displayName: option.title,
                lastFour: option.lastFour
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { dismiss() }
        }) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: option.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(AppColors.primaryRed.opacity(0.1)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.lastFour.map { "\(option.title) •••• \($0)" } ?? option.title)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    Text(option.subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.tertiaryText)
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .stroke(isSelected ? AppColors.primaryRed : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Address Picker

struct AddressPickerView: View {
    @Binding var selectedAddress: Address?
    @Binding var savedAddresses: [Address]
    @Environment(\.dismiss) private var dismiss
    @State private var showAddForm = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    if savedAddresses.isEmpty {
                        emptyState
                    } else {
                        ForEach(savedAddresses) { address in
                            addressRow(address)
                        }
                    }

                    Button(action: { showAddForm = true }) {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Address")
                                .font(AppFonts.callout)
                        }
                        .foregroundColor(AppColors.primaryRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                                .stroke(AppColors.primaryRed, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Select Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddForm) {
                AddAddressView { newAddress in
                    savedAddresses.append(newAddress)
                    selectedAddress = newAddress
                    // Close the picker after the form finishes dismissing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { dismiss() }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 50))
                .foregroundColor(AppColors.lightGray)
            Text("No saved addresses")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
            Text("Add a delivery address to continue.")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }

    private func typeIcon(_ type: Address.AddressType) -> String {
        switch type {
        case .home:  return "house.fill"
        case .work:  return "briefcase.fill"
        case .other: return "mappin.circle.fill"
        }
    }

    private func addressRow(_ address: Address) -> some View {
        let isSelected = selectedAddress?.id == address.id

        return Button(action: {
            selectedAddress = address
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { dismiss() }
        }) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                Image(systemName: typeIcon(address.type))
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.primaryRed.opacity(0.1)))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(address.fullName) · \(address.type.rawValue.capitalized)")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    Text(address.fullAddress)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.leading)
                    Text(address.mobileNumber)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }

                Spacer()

                VStack(spacing: AppSpacing.md) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.tertiaryText)

                    Button(action: { delete(address) }) {
                        Image(systemName: "trash")
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .stroke(isSelected ? AppColors.primaryRed : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func delete(_ address: Address) {
        savedAddresses.removeAll { $0.id == address.id }
        if selectedAddress?.id == address.id {
            selectedAddress = nil
        }
    }
}

// MARK: - Add Address Form

struct AddAddressView: View {
    let onSave: (Address) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var type: Address.AddressType = .home
    @State private var fullName = ""
    @State private var mobile = ""
    @State private var line1 = ""
    @State private var landmark = ""
    @State private var city = ""
    @State private var state = ""
    @State private var pincode = ""

    private func filled(_ text: String) -> Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var isValid: Bool {
        filled(fullName) &&
        mobile.filter(\.isNumber).count == 10 &&
        filled(line1) &&
        filled(city) &&
        filled(state) &&
        pincode.filter(\.isNumber).count == 6
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    Picker("Type", selection: $type) {
                        Text("Home").tag(Address.AddressType.home)
                        Text("Work").tag(Address.AddressType.work)
                        Text("Other").tag(Address.AddressType.other)
                    }
                    .pickerStyle(.segmented)

                    field("Full Name", text: $fullName)
                    field("Mobile Number (10 digits)", text: $mobile, keyboard: .numberPad)
                    field("House / Flat / Street", text: $line1)
                    field("Landmark (optional)", text: $landmark)
                    field("City", text: $city)
                    field("State", text: $state)
                    field("Pincode (6 digits)", text: $pincode, keyboard: .numberPad)

                    PrimaryButton(title: "Save Address", action: save, isDisabled: !isValid)
                        .padding(.top, AppSpacing.md)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColors.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Add Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func field(_ placeholder: String, text: Binding<String>,
                       keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textFieldStyle(PlainTextFieldStyle())
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
    }

    private func save() {
        let trimmedLandmark = landmark.trimmingCharacters(in: .whitespaces)

        let address = Address(
            type: type,
            fullName: fullName.trimmingCharacters(in: .whitespaces),
            mobileNumber: mobile,
            addressLine1: line1.trimmingCharacters(in: .whitespaces),
            city: city.trimmingCharacters(in: .whitespaces),
            state: state.trimmingCharacters(in: .whitespaces),
            postalCode: pincode,
            landmark: trimmedLandmark.isEmpty ? nil : trimmedLandmark
        )
        onSave(address)
        dismiss()
    }
}

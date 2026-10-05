import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var appState: AppState
    
    @State private var upsellItems: [MenuItem] = []
    @State private var showEditPizza: Bool = false
    @State private var editingCartItem: CartItem?
    
    private let menuRepository = MockMenuRepository.shared
    
    @State private var availablePoints: Int = 0
    private let loyaltyRepository = MockLoyaltyRepository.shared
    
    @State private var couponCodeInput: String = ""
    @State private var showCouponError: Bool = false
    @State private var couponErrorMessage: String = ""
    
    
    private var pointsDiscountBanner: some View {
        let cost = CartManager.pointsDiscountCost
        let applied = cartManager.pointsRedeemed > 0
        let canAfford = availablePoints >= cost

        return HStack(spacing: AppSpacing.sm) {
            Image(systemName: applied ? "checkmark.seal.fill" : "star.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(Color(hex: "F6C244"))

            Text(applied ? "$5 off applied · \(cost) pts"
                 : canAfford ? "Get $5 off using \(cost) pts"
                 : "Need \(cost) pts for $5 off (you have \(availablePoints))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if applied { cartManager.removePointsDiscount() }
                    else { cartManager.applyPointsDiscount() }
                }
            }) {
                Text(applied ? "Remove" : "Apply")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "7A130F"))
                    .padding(.horizontal, 14)
                    .frame(height: 28)
                    .background(Capsule().fill(Color.white))
            }
            .buttonStyle(.plain)
            .disabled(!applied && !canAfford)
            .opacity(!applied && !canAfford ? 0.5 : 1)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)                                  // ← 40pt banner
        .background(
            LinearGradient(colors: [Color(hex: "A0281F"), Color(hex: "7A130F")],
                           startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Coupon Code Section
    
    private var couponCodeSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "tag.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryRed)
                
                Text("Apply Coupon Code")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                if let appliedCode = cartManager.appliedCouponCode {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            cartManager.removeCouponCode()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                            Text("Remove")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "7A130F"))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if let appliedCode = cartManager.appliedCouponCode {
                HStack {
                    Text("Code Applied: \(appliedCode)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.success)
                    
                    Spacer()
                    
                    Text("-$\(Int(cartManager.couponDiscount))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppColors.success)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.success.opacity(0.1))
                .cornerRadius(8)
            } else {
                HStack(spacing: AppSpacing.sm) {
                    TextField("Enter coupon code", text: $couponCodeInput)
                        .font(.system(size: 14))
                        .textFieldStyle(.plain)
                        .autocapitalization(.allCharacters)
                        .disableAutocorrection(true)
                        .onChange(of: couponCodeInput) { _, newValue in
                            couponCodeInput = newValue.uppercased()
                            showCouponError = false
                        }
                    
                    Button(action: {
                        applyCouponCode()
                    }) {
                        Text("Apply")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(couponCodeInput.isEmpty ? Color.gray : AppColors.primaryRed)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(couponCodeInput.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.white)
                .cornerRadius(8)
                
                if showCouponError {
                    Text(couponErrorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.error)
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.md)
    }
    
    private func applyCouponCode() {
        let validation = cartManager.validateCouponCode(couponCodeInput)
        
        if validation.isValid {
            if cartManager.applyCouponCode(couponCodeInput) {
                couponCodeInput = ""
                showCouponError = false
            }
        } else {
            showCouponError = true
            couponErrorMessage = validation.message ?? "Invalid coupon code"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if cartManager.cart.isEmpty {
                    emptyCartView
                } else {
                    VStack(spacing: 0) {
                        // Cart Items
                        ScrollView {
                            VStack(spacing: AppSpacing.md) {
                                // Cart Items
                                ForEach(cartManager.cart.items) { item in
                                    CartItemRow(
                                        item: item,
                                        onEdit: {
                                            editingCartItem = item
                                            showEditPizza = true
                                        },
                                        onRemove: {
                                            cartManager.removeItem(item.id)
                                        }
                                    )
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                
                                // Upsell Section
                                if !upsellItems.isEmpty {
                                    upsellSection
                                }
                                
                                // Loyalty Section
                                loyaltySection
                                
                                // Coupon Code Section
                                couponCodeSection
                                
                                pointsDiscountBanner
                                
                                // Order Summary
                                orderSummary
                                
                                // Bottom spacing
                                Color.clear
                                    .frame(height: 100)
                            }
                            .padding(.vertical, AppSpacing.md)
                        }
                        
                        // Checkout Button
                        checkoutButton
                    }
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                if !cartManager.cart.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") {
                            cartManager.clearCart()
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditPizza) {
                if let item = editingCartItem {
                    EditPizzaCartItemView(cartItem: item)
                }
            }
        }
        .task {
            await loadUpsellItems()
            if let summary = try? await loyaltyRepository.getLoyaltySummary() {
                availablePoints = summary.availablePoints
            }
        }
    }
    
    // MARK: - Empty Cart View
    
    private var emptyCartView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 80))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("Your Cart Is Empty")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Let's add something delicious.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            PrimaryButton(title: "Browse Menu", action: {
                dismiss()
                appRouter.selectTab(.menu)
            })
            .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
    }
    
    // MARK: - Upsell Section
    
    private var upsellSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Complete Your Meal")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.lg)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(upsellItems) { item in
                        UpsellItemCard(item: item)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Loyalty Section
    
    private var loyaltySection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppColors.gold)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("MOD Rewards")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    if appState.isAuthenticated {
                        Text("You may earn approximately +\(cartManager.estimatedPoints) points from this order")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    } else {
                        Text("Login at checkout to earn and manage your rewards.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                    appRouter.selectTab(.rewards)
                }) {
                    Text("View Rewards")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Order Summary
    
    private var orderSummary: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Subtotal")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("$\(Int(cartManager.cart.subtotal))")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.primaryText)
            }
            
            if cartManager.pointsDiscount > 0 {
                       HStack {
                           Text("Points discount (\(CartManager.pointsDiscountCost) pts)")
                               .font(AppFonts.subheadline)
                               .foregroundColor(AppColors.success)
                           
                           Spacer()
                           
                           Text("-$\(Int(cartManager.pointsDiscount))")
                               .font(AppFonts.subheadline)
                               .foregroundColor(AppColors.success)
                       }
                   }
            
            if cartManager.couponDiscount > 0 {
                HStack {
                    Text("Coupon discount (\(cartManager.appliedCouponCode ?? ""))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.success)
                    
                    Spacer()
                    
                    Text("-$\(Int(cartManager.couponDiscount))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.success)
                }
            }
            
            if cartManager.deliveryFee > 0 {
                HStack {
                    Text("Delivery Fee")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text("$\(Int(cartManager.deliveryFee))")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryText)
                }
            }
            
            HStack {
                Text("Tax (5%)")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text("$\(Int(cartManager.tax))")
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
                
                Text("$\(Int(cartManager.total))")
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
    }
    
    // MARK: - Checkout Button
    
    private var checkoutButton: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("\(cartManager.cart.itemCount) Items")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("$\(Int(cartManager.total))")
                            .font(AppFonts.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryRed)
                    }
                    
                    Spacer()
                    
                    PrimaryButton(title: "Checkout", action: {
                        dismiss()
                        appRouter.showCheckoutScreen()
                    }, isDisabled: !cartManager.isValidForCheckout)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
    
    // MARK: - Load Upsell Items
    
    private func loadUpsellItems() async {
        do {
            let items = try await menuRepository.getMenuItems()
            await MainActor.run {
                self.upsellItems = items.filter { item in
                    !cartManager.cart.items.contains { $0.menuItem.id == item.id } &&
                    (item.categoryId == "cat3" || item.categoryId == "cat6") // Sides and Beverages
                }.prefix(5).map { $0 }
            }
        } catch {
            // Handle error silently
        }
    }
}

// MARK: - Cart Item Row
// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    let onEdit: () -> Void
    let onRemove: () -> Void
    @EnvironmentObject var cartManager: CartManager

    // "Mozzarella, Pepperoni, Basil" — all toppings in one line
    private var toppingsText: String? {
        guard let config = item.pizzaConfiguration else { return nil }
        let ids = config.cheese.map(\.ingredientId)
            + config.meats.map(\.ingredientId)
            + config.vegetables.map(\.ingredientId)
        let names = ids.compactMap { id in
            MockData.ingredients.first { $0.id == id }?.name
        }
        return names.isEmpty ? nil : names.joined(separator: ", ")
    }

    private var estimatedPoints: Int {
        Int(item.totalPrice * Constants.loyaltyPointsPerRupee)
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Product photo
                RewardImage(imageName: item.menuItem.image, iconSize: 28, fallbackIcon: "fork.knife")
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(item.displayName)
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(2)

                        Spacer(minLength: 8)

                        Text("$\(Int(item.totalPrice))")
                            .font(AppFonts.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primaryRed)
                    }

                    if let config = item.pizzaConfiguration {
                        Text("\(config.size.displayName) · \(config.crust.displayName)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }

                    if let toppings = toppingsText {
                        Text(toppings)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.tertiaryText)
                            .lineLimit(2)
                    }

                    Text("+\(estimatedPoints) pts")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppColors.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(AppColors.success.opacity(0.12)))
                        .padding(.top, 2)
                }
            }

            Divider()

            // Quantity and actions
            HStack {
                QuantityStepper(quantity: Binding(
                    get: { item.quantity },
                    set: { cartManager.updateQuantity(item.id, quantity: $0) }
                ))

                Spacer()

                if item.pizzaConfiguration != nil {
                    Button(action: onEdit) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primaryRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(AppColors.primaryRed.opacity(0.1)))
                    }
                    .buttonStyle(.plain)
                }

                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.error)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(AppColors.error.opacity(0.1)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
}


// MARK: - Upsell Item Card
struct UpsellItemCard: View {
    let item: MenuItem
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            RewardImage(imageName: item.image, iconSize: 30, fallbackIcon: "fork.knife")
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.name)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)

                Text("$\(Int(item.basePrice))")
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }

            Button(action: {
                let cartItem = CartItem(menuItem: item, quantity: 1)
                cartManager.addItem(cartItem)
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primaryRed)
            }
        }
        .frame(width: 110)
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

// MARK: - Edit Pizza Cart Item View
struct EditPizzaCartItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    
    let cartItem: CartItem
    @State private var configuration: PizzaConfiguration
    
    init(cartItem: CartItem) {
        self.cartItem = cartItem
        self._configuration = State(initialValue: cartItem.pizzaConfiguration ?? PizzaConfiguration(
            menuItemId: cartItem.menuItem.id
        ))
    }
    
    var body: some View {
        NavigationView {
            PizzaBuilderView(menuItem: cartItem.menuItem)
                .onDisappear {
                    // Update cart item with new configuration
                    let updatedItem = CartItem(
                        id: cartItem.id,
                        menuItem: cartItem.menuItem,
                        pizzaConfiguration: configuration,
                        quantity: cartItem.quantity,
                        unitPrice: cartItem.unitPrice,
                        specialInstructions: cartItem.specialInstructions,
                        addedAt: cartItem.addedAt
                    )
                    cartManager.editItem(cartItem.id, newItem: updatedItem)
                }
        }
    }
}

// MARK: - Points Discount Banner


#Preview {
    CartView()
        .environmentObject(CartManager.shared)
        .environmentObject(AppRouter())
        .environmentObject(AppState.shared)
}





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
struct CartItemRow: View {
    let item: CartItem
    let onEdit: () -> Void
    let onRemove: () -> Void
    @EnvironmentObject var cartManager: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Item Header
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(item.displayName)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    if let config = item.pizzaConfiguration {
                        Text("\(config.size.displayName) \(config.crust.displayName)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Text("$\(Int(item.totalPrice))")
                    .font(AppFonts.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryRed)
            }
            
            // Added estimated points text
            let estimatedPoints = Int(item.totalPrice * Constants.loyaltyPointsPerRupee)
            Text("+\(estimatedPoints) pts")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.success)
            
            // Item Details
            if let config = item.pizzaConfiguration {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    if !config.cheese.isEmpty {
                        Text(config.cheese.compactMap { cheese in
                            MockData.ingredients.first { $0.id == cheese.ingredientId }?.name
                        }.joined(separator: ", "))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if !config.meats.isEmpty {
                        Text(config.meats.compactMap { meat in
                            MockData.ingredients.first { $0.id == meat.ingredientId }?.name
                        }.joined(separator: ", "))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    }
                    
                    if !config.vegetables.isEmpty {
                        Text(config.vegetables.compactMap { veg in
                            MockData.ingredients.first { $0.id == veg.ingredientId }?.name
                        }.joined(separator: ", "))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            
            // Quantity and Actions
            HStack {
                QuantityStepper(quantity: Binding(
                    get: { item.quantity },
                    set: { cartManager.updateQuantity(item.id, quantity: $0) }
                ))
                
                Spacer()
                
                if item.pizzaConfiguration != nil {
                    Button(action: onEdit) {
                        Text("Edit")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
                
                Button(action: onRemove) {
                    Text("Remove")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.error)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
    }
}

// MARK: - Upsell Item Card
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

#Preview {
    CartView()
        .environmentObject(CartManager.shared)
        .environmentObject(AppRouter())
        .environmentObject(AppState.shared)
}

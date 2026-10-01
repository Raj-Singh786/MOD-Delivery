import SwiftUI

struct PizzaBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cartManager: CartManager
    
    @State private var configuration: PizzaConfiguration
    @State private var showSauceSection: Bool = false
    @State private var showCheeseSection: Bool = false
    @State private var showMeatSection: Bool = false
    @State private var showVeggieSection: Bool = false
    @State private var showFinishingSauceSection: Bool = false
    @State private var specialInstructions: String = ""
    
    private let menuItem: MenuItem
    
    init(menuItem: MenuItem) {
        self.menuItem = menuItem
        self._configuration = State(initialValue: PizzaConfiguration(
            menuItemId: menuItem.id,
            size: .regular,
            crust: .thin
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Pizza Preview
                    pizzaPreviewSection
                    
                    // Scrollable Content
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            // Size & Crust
                            sizeCrustSection
                            
                            // Sauce
                            sauceSection
                            
                            // Cheese
                            cheeseSection
                            
                            // Meat
                            meatSection
                            
                            // Veggies
                            veggieSection
                            
                            // Finishing Sauce
                            finishingSauceSection
                            
                            // Cooking Instructions
                            cookingInstructionsSection
                            
                            // Special Instructions
                            specialInstructionsSection
                            
                            // Bottom spacing for sticky footer
                            Color.clear
                                .frame(height: 200)
                        }
                        .padding(.vertical, AppSpacing.md)
                    }
                    
                    // Sticky Footer
                    stickyFooter
                }
            }
            .navigationTitle("Margherita Pizza")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Single source of truth for size + crust pricing
    private func sizeCrustPrice(size: PizzaSize, crust: PizzaCrust) -> Int {
        var price = Int(menuItem.basePrice)      // Regular + Thin = the menu price

        if size == .small { price -= 100 }
        else if size == .large { price += 100 }

        if crust == .thick { price += 50 }
        else if crust == .cauliflower || crust == .glutenFree { price += 100 }

        return price
    }
    
    
    // MARK: - Pizza Preview Section

    private var pizzaPreviewSection: some View {
        VStack(spacing: AppSpacing.md) {
            MenuItemImage(imageName: menuItem.image)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(AppColors.primaryRed, lineWidth: 4)
                )
                .shadow(color: AppColors.shadow, radius: 6, x: 0, y: 3)
            
            Text("\(configuration.totalCalories) Cals")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.secondaryText)
            
            Text("40+ Toppings • 8 Finishing Sauces • Unlimited Creativity")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
    }
    
    // MARK: - Size & Crust Section
    
    private var sizeCrustChoices: [(size: PizzaSize, crust: PizzaCrust, calories: Int)] {
        [
            (.small,   .thin,        300),
            (.regular, .thin,        500),
            (.regular, .thick,       600),
            (.regular, .cauliflower, 450),
            (.regular, .glutenFree,  480)
        ]
    }

    private var sizeCrustSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Choose Your Size & Crust")

            VStack(spacing: AppSpacing.sm) {
                ForEach(Array(sizeCrustChoices.enumerated()), id: \.offset) { _, choice in
                    SizeCrustOption(
                        size: choice.size,
                        crust: choice.crust,
                        price: sizeCrustPrice(size: choice.size, crust: choice.crust),
                        calories: choice.calories,
                        isSelected: configuration.size == choice.size &&
                                    configuration.crust == choice.crust,
                        action: {
                            configuration.size = choice.size
                            configuration.crust = choice.crust
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
    
    // MARK: - Sauce Section
    
    private var sauceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Choose Your Sauce")
            
            let sauceIngredients = MockData.ingredients.filter { $0.category == .sauce }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(sauceIngredients) { ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        isSelected: configuration.sauce?.ingredientId == ingredient.id,
                        quantity: configuration.sauce?.quantity ?? .regular,
                        onQuantityChange: { quantity in
                            configuration.sauce = PizzaConfiguration.SelectedIngredient(
                                ingredientId: ingredient.id,
                                quantity: quantity
                            )
                        },
                        onToggle: {
                            if configuration.sauce?.ingredientId == ingredient.id {
                                configuration.sauce = nil
                            } else {
                                configuration.sauce = PizzaConfiguration.SelectedIngredient(
                                    ingredientId: ingredient.id,
                                    quantity: .regular
                                )
                            }
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
    
    // MARK: - Cheese Section
    
    private var cheeseSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Choose Your Cheese")
            
            let cheeseIngredients = MockData.ingredients.filter { $0.category == .cheese }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(cheeseIngredients) { ingredient in
                    let isSelected = configuration.cheese.contains { $0.ingredientId == ingredient.id }
                    let quantity = configuration.cheese.first { $0.ingredientId == ingredient.id }?.quantity ?? .regular
                    
                    IngredientRow(
                        ingredient: ingredient,
                        isSelected: isSelected,
                        quantity: quantity,
                        onQuantityChange: { newQuantity in
                            if let index = configuration.cheese.firstIndex(where: { $0.ingredientId == ingredient.id }) {
                                configuration.cheese[index].quantity = newQuantity
                            }
                        },
                        onToggle: {
                            if isSelected {
                                configuration.cheese.removeAll { $0.ingredientId == ingredient.id }
                            } else {
                                configuration.cheese.append(PizzaConfiguration.SelectedIngredient(
                                    ingredientId: ingredient.id,
                                    quantity: .regular
                                ))
                            }
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
    
    // MARK: - Meat Section
    
    private var meatSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Meat")
            
            let meatIngredients = MockData.ingredients.filter { $0.category == .meat }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(meatIngredients) { ingredient in
                    let isSelected = configuration.meats.contains { $0.ingredientId == ingredient.id }
                    let quantity = configuration.meats.first { $0.ingredientId == ingredient.id }?.quantity ?? .regular
                    
                    IngredientRow(
                        ingredient: ingredient,
                        isSelected: isSelected,
                        quantity: quantity,
                        onQuantityChange: { newQuantity in
                            if let index = configuration.meats.firstIndex(where: { $0.ingredientId == ingredient.id }) {
                                configuration.meats[index].quantity = newQuantity
                            }
                        },
                        onToggle: {
                            if isSelected {
                                configuration.meats.removeAll { $0.ingredientId == ingredient.id }
                            } else {
                                configuration.meats.append(PizzaConfiguration.SelectedIngredient(
                                    ingredientId: ingredient.id,
                                    quantity: .regular
                                ))
                            }
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
    
    // MARK: - Veggie Section
    
    private var veggieSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Veggies, Herbs & Good Stuff")
            
            let veggieIngredients = MockData.ingredients.filter { $0.category == .vegetable }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(veggieIngredients) { ingredient in
                    let isSelected = configuration.vegetables.contains { $0.ingredientId == ingredient.id }
                    let quantity = configuration.vegetables.first { $0.ingredientId == ingredient.id }?.quantity ?? .regular
                    
                    IngredientRow(
                        ingredient: ingredient,
                        isSelected: isSelected,
                        quantity: quantity,
                        onQuantityChange: { newQuantity in
                            if let index = configuration.vegetables.firstIndex(where: { $0.ingredientId == ingredient.id }) {
                                configuration.vegetables[index].quantity = newQuantity
                            }
                        },
                        onToggle: {
                            if isSelected {
                                configuration.vegetables.removeAll { $0.ingredientId == ingredient.id }
                            } else {
                                configuration.vegetables.append(PizzaConfiguration.SelectedIngredient(
                                    ingredientId: ingredient.id,
                                    quantity: .regular
                                ))
                            }
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
    
    // MARK: - Finishing Sauce Section
    
    private var finishingSauceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Finishing Sauce")
            
            let finishingSauces = MockData.ingredients.filter { $0.category == .finishingSauce }
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(finishingSauces) { ingredient in
                    FinishingSauceRow(
                        ingredient: ingredient,
                        isSelected: configuration.finishingSauce?.ingredientId == ingredient.id,
                        placement: configuration.finishingSauce?.placement ?? .onTop,
                        onPlacementChange: { placement in
                            configuration.finishingSauce = PizzaConfiguration.SelectedFinishingSauce(
                                ingredientId: ingredient.id,
                                placement: placement
                            )
                        },
                        onToggle: {
                            if configuration.finishingSauce?.ingredientId == ingredient.id {
                                configuration.finishingSauce = nil
                            } else {
                                configuration.finishingSauce = PizzaConfiguration.SelectedFinishingSauce(
                                    ingredientId: ingredient.id,
                                    placement: .onTop
                                )
                            }
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
    
    // MARK: - Cooking Instructions Section
    
    private var cookingInstructionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Cooking Instructions")
            
            HStack(spacing: AppSpacing.md) {
                CookingInstructionButton(
                    title: "Light Bake",
                    isSelected: configuration.cookingInstruction == .lightBake,
                    action: {
                        configuration.cookingInstruction = configuration.cookingInstruction == .lightBake ? nil : .lightBake
                    }
                )
                
                CookingInstructionButton(
                    title: "Extra Crispy",
                    isSelected: configuration.cookingInstruction == .extraCrispy,
                    action: {
                        configuration.cookingInstruction = configuration.cookingInstruction == .extraCrispy ? nil : .extraCrispy
                    }
                )
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Special Instructions Section
    
    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Special Instructions")
            
            TextField("Add any special request...", text: $specialInstructions, axis: .vertical)
                .font(AppFonts.body)
                .foregroundColor(AppColors.primaryText)
                .padding(AppSpacing.md)
                .background(AppColors.secondaryBackground)
                .cornerRadius(AppSpacing.cornerRadius)
                .lineLimit(3...5)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Sticky Footer
    
    private var stickyFooter: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: AppSpacing.md) {
                // Summary
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("\(configuration.size.displayName) \(configuration.crust.displayName)")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text("\(configuration.totalCalories) Cals")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    QuantityStepper(quantity: $configuration.quantity)
                }
                
                // Add to Cart Button
                PrimaryButton(
                    title: "Add to Cart - $\(calculatePrice())",
                    action: addToCart,
                    isDisabled: !isValidConfiguration
                )
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateUnitPrice() -> Int {
        var unitPrice = sizeCrustPrice(size: configuration.size, crust: configuration.crust)

        // Toppings (simplified: ₹20 each, same as before)
        let selectedIngredients = configuration.cheese.count
            + configuration.meats.count
            + configuration.vegetables.count
        unitPrice += selectedIngredients * 20

        return unitPrice
    }

    private func calculatePrice() -> Int {
        calculateUnitPrice() * configuration.quantity
    }
    
    
    private var isValidConfiguration: Bool {
        // Validate that at least some selections are made
        return true
    }
    
    private func addToCart() {
        let cartItem = CartItem(
            menuItem: menuItem,
            pizzaConfiguration: configuration,
            quantity: configuration.quantity,
            unitPrice: Double(calculateUnitPrice()),
            specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
        )
        
        cartManager.addItem(cartItem)
        dismiss()
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(AppFonts.callout)
            .fontWeight(.semibold)
            .foregroundColor(AppColors.primaryText)
    }
}

// MARK: - Size Crust Option
struct SizeCrustOption: View {
    let size: PizzaSize
    let crust: PizzaCrust
    let price: Int
    let calories: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(size.displayName)")
                        .font(AppFonts.callout)
                        .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.primaryText)
                    
                    Text(crust.displayName)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("$\(price)")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("\(calories) Cals")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primaryRed)
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius)
                    .fill(isSelected ? AppColors.primaryRed.opacity(0.1) : AppColors.secondaryBackground)
            )
        }
    }
}

// MARK: - Ingredient Row
struct IngredientRow: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let quantity: IngredientQuantity
    let onQuantityChange: (IngredientQuantity) -> Void
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                IngredientImage(ingredient: ingredient)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(ingredient.name)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                    
                    if let calories = ingredient.calories {
                        Text("\(calories) Cals")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.tertiaryText)
                    }
                }
                
                Spacer()
                
                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.tertiaryText)
                }
            }
            
            if isSelected {
                HStack(spacing: AppSpacing.xs) {
                    ForEach(IngredientQuantity.allCases, id: \.self) { qty in
                        QuantityChip(
                            title: qty.displayName,
                            isSelected: quantity == qty,
                            action: { onQuantityChange(qty) }
                        )
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius)
                .fill(isSelected ? AppColors.primaryRed.opacity(0.1) : AppColors.secondaryBackground)
        )
    }
}

// MARK: - Quantity Chip
struct QuantityChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.caption)
                .foregroundColor(isSelected ? .white : AppColors.primaryText)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.primaryRed : AppColors.white)
                )
        }
    }
}

// MARK: - Finishing Sauce Row
struct FinishingSauceRow: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let placement: PizzaConfiguration.FinishingSaucePlacement
    let onPlacementChange: (PizzaConfiguration.FinishingSaucePlacement) -> Void
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                IngredientImage(ingredient: ingredient)
                
                Text(ingredient.name)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.tertiaryText)
                }
            }
            
            if isSelected {
                HStack(spacing: AppSpacing.md) {
                    PlacementOption(
                        title: "On Top",
                        isSelected: placement == .onTop,
                        action: { onPlacementChange(.onTop) }
                    )
                    
                    PlacementOption(
                        title: "Side Cup",
                        isSelected: placement == .sideCup,
                        action: { onPlacementChange(.sideCup) }
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius)
                .fill(isSelected ? AppColors.primaryRed.opacity(0.1) : AppColors.secondaryBackground)
        )
    }
}

// MARK: - Placement Option
struct PlacementOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? AppColors.primaryRed : AppColors.tertiaryText)
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryText)
            }
        }
    }
}

// MARK: - Cooking Instruction Button
struct CookingInstructionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.subheadline)
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

#Preview {
    PizzaBuilderView(menuItem: MockData.menuItems[0])
        .environmentObject(CartManager.shared)
}


// MARK: - Ingredient Image Reusable Images
struct IngredientImage: View {
    let ingredient: Ingredient
    var size: CGFloat = 48
    
    // "Pepper Jack" -> "pepper_jack" (must match the name in Assets)
    private var assetName: String {
        ingredient.image
    }
    
    private var fallbackSymbol: String {
        switch ingredient.category {
        case .sauce, .finishingSauce: return "drop.fill"
        case .cheese: return "square.grid.2x2.fill"
        case .meat: return "fork.knife"
        case .vegetable: return "leaf.fill"
        default: return "fork.knife"
        }
    }
    
    var body: some View {
        Group {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    AppColors.lightGray.opacity(0.4)
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: size * 0.4))
                        .foregroundColor(AppColors.primaryRed)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))
    }
}

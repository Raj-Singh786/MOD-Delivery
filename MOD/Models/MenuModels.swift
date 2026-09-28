import Foundation

// MARK: - Menu Category
struct MenuCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let image: String?
    let sortOrder: Int
    let isActive: Bool
    
    init(id: String = UUID().uuidString,
         name: String,
         description: String? = nil,
         image: String? = nil,
         sortOrder: Int = 0,
         isActive: Bool = true) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
        self.sortOrder = sortOrder
        self.isActive = isActive
    }
}

// MARK: - Menu Item
struct MenuItem: Codable, Identifiable {
    let id: String
    let categoryId: String
    let name: String
    let description: String
    let image: String?
    let basePrice: Double
    let calories: Int?
    let isCustomizable: Bool
    let isVegetarian: Bool
    let isSpicy: Bool
    let isPopular: Bool
    let isAvailable: Bool
    let preparationTime: Int? // in minutes
    let allergens: [String]?
    let sortOrder: Int
    
    init(id: String = UUID().uuidString,
         categoryId: String,
         name: String,
         description: String,
         image: String? = nil,
         basePrice: Double,
         calories: Int? = nil,
         isCustomizable: Bool = false,
         isVegetarian: Bool = false,
         isSpicy: Bool = false,
         isPopular: Bool = false,
         isAvailable: Bool = true,
         preparationTime: Int? = nil,
         allergens: [String]? = nil,
         sortOrder: Int = 0) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.description = description
        self.image = image
        self.basePrice = basePrice
        self.calories = calories
        self.isCustomizable = isCustomizable
        self.isVegetarian = isVegetarian
        self.isSpicy = isSpicy
        self.isPopular = isPopular
        self.isAvailable = isAvailable
        self.preparationTime = preparationTime
        self.allergens = allergens
        self.sortOrder = sortOrder
    }
}

// MARK: - Pizza Size
enum PizzaSize: String, Codable, CaseIterable {
    case small = "small"
    case regular = "regular"
    case large = "large"
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .regular: return "Regular"
        case .large: return "Large"
        }
    }
    
    var sizeInches: String {
        switch self {
        case .small: return "6\""
        case .regular: return "11\""
        case .large: return "13\""
        }
    }
}

// MARK: - Pizza Crust
enum PizzaCrust: String, Codable, CaseIterable {
    case thin = "thin"
    case thick = "thick"
    case cauliflower = "cauliflower"
    case glutenFree = "gluten_free"
    
    var displayName: String {
        switch self {
        case .thin: return "Thin Crust"
        case .thick: return "Extra Thick"
        case .cauliflower: return "Cauliflower"
        case .glutenFree: return "Gluten Friendly"
        }
    }
    
    var isAlternative: Bool {
        switch self {
        case .thin, .thick: return false
        case .cauliflower, .glutenFree: return true
        }
    }
}

// MARK: - Ingredient Quantity
enum IngredientQuantity: String, Codable, CaseIterable {
    case light = "light"
    case regular = "regular"
    case extra = "extra"
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .regular: return "Regular"
        case .extra: return "Extra"
        }
    }
    
    var priceMultiplier: Double {
        switch self {
        case .light: return 0.5
        case .regular: return 1.0
        case .extra: return 1.5
        }
    }
}

// MARK: - Ingredient
struct Ingredient: Codable, Identifiable {
    let id: String
    let name: String
    let image: String
    let category: IngredientCategory
    let calories: Int?
    let isVegetarian: Bool
    let isSpicy: Bool
    let basePrice: Double
    let isAvailable: Bool
    
    enum IngredientCategory: String, Codable {
        case sauce = "sauce"
        case cheese = "cheese"
        case meat = "meat"
        case vegetable = "vegetable"
        case finishingSauce = "finishing_sauce"
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         image: String,
         category: IngredientCategory,
         calories: Int? = nil,
         isVegetarian: Bool = true,
         isSpicy: Bool = false,
         basePrice: Double = 0,
         isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.image = image
        self.category = category
        self.calories = calories
        self.isVegetarian = isVegetarian
        self.isSpicy = isSpicy
        self.basePrice = basePrice
        self.isAvailable = isAvailable
    }
}

// MARK: - Pizza Configuration
struct PizzaConfiguration: Codable, Identifiable {
    let id: String
    let menuItemId: String
    var size: PizzaSize
    var crust: PizzaCrust
    var sauce: SelectedIngredient?
    var cheese: [SelectedIngredient]
    var meats: [SelectedIngredient]
    var vegetables: [SelectedIngredient]
    var finishingSauce: SelectedFinishingSauce?
    var cookingInstruction: CookingInstruction?
    var specialInstructions: String?
    var quantity: Int
    
    struct SelectedIngredient: Codable {
        let ingredientId: String
        var quantity: IngredientQuantity
    }
    
    struct SelectedFinishingSauce: Codable {
        let ingredientId: String
        var placement: FinishingSaucePlacement
    }
    
    enum FinishingSaucePlacement: String, Codable {
        case onTop = "on_top"
        case sideCup = "side_cup"
    }
    
    enum CookingInstruction: String, Codable {
        case lightBake = "light_bake"
        case extraCrispy = "extra_crispy"
    }
    
    var totalCalories: Int {
        var total = 0
        // Base calories based on size
        switch size {
        case .small: total += 300
        case .regular: total += 500
        case .large: total += 700
        }
        
        // Add ingredient calories (simplified for now)
        // In production, this would look up actual ingredient data
        return total
    }
    
    init(id: String = UUID().uuidString,
         menuItemId: String,
         size: PizzaSize = .regular,
         crust: PizzaCrust = .thin,
         sauce: SelectedIngredient? = nil,
         cheese: [SelectedIngredient] = [],
         meats: [SelectedIngredient] = [],
         vegetables: [SelectedIngredient] = [],
         finishingSauce: SelectedFinishingSauce? = nil,
         cookingInstruction: CookingInstruction? = nil,
         specialInstructions: String? = nil,
         quantity: Int = 1) {
        self.id = id
        self.menuItemId = menuItemId
        self.size = size
        self.crust = crust
        self.sauce = sauce
        self.cheese = cheese
        self.meats = meats
        self.vegetables = vegetables
        self.finishingSauce = finishingSauce
        self.cookingInstruction = cookingInstruction
        self.specialInstructions = specialInstructions
        self.quantity = quantity
    }
}

// MARK: - Cart Item
struct CartItem: Codable, Identifiable {
    let id: String
    let menuItem: MenuItem
    let pizzaConfiguration: PizzaConfiguration?
    var quantity: Int
    let unitPrice: Double
    var totalPrice: Double
    let specialInstructions: String?
    let addedAt: Date
    
    var displayName: String {
        if pizzaConfiguration != nil {
            return "Custom \(menuItem.name)"
        }
        return menuItem.name
    }
    
    var totalCalories: Int? {
        if let config = pizzaConfiguration {
            return config.totalCalories * quantity
        }
        return (menuItem.calories ?? 0) * quantity
    }
    
    init(id: String = UUID().uuidString,
         menuItem: MenuItem,
         pizzaConfiguration: PizzaConfiguration? = nil,
         quantity: Int = 1,
         unitPrice: Double? = nil,
         specialInstructions: String? = nil,
         addedAt: Date = Date()) {
        self.id = id
        self.menuItem = menuItem
        self.pizzaConfiguration = pizzaConfiguration
        self.quantity = quantity
        self.unitPrice = unitPrice ?? menuItem.basePrice
        self.totalPrice = self.unitPrice * Double(quantity)
        self.specialInstructions = specialInstructions
        self.addedAt = addedAt
    }
}

// MARK: - Cart
struct Cart: Codable {
    var items: [CartItem]
    var orderType: OrderType
    var restaurant: Restaurant?
    var address: Address?
    var specialInstructions: String?
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var isEmpty: Bool {
        items.isEmpty
    }
    
    mutating func addItem(_ item: CartItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += item.quantity
            items[index].totalPrice = items[index].unitPrice * Double(items[index].quantity)
        } else {
            items.append(item)
        }
    }
    
    mutating func removeItem(_ itemId: String) {
        items.removeAll { $0.id == itemId }
    }
    
    mutating func updateQuantity(_ itemId: String, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if quantity <= 0 {
                removeItem(itemId)
            } else {
                items[index].quantity = quantity
                items[index].totalPrice = items[index].unitPrice * Double(quantity)
            }
        }
    }
    
    mutating func clear() {
        items.removeAll()
    }
    
    init(items: [CartItem] = [],
         orderType: OrderType = .delivery,
         restaurant: Restaurant? = nil,
         address: Address? = nil,
         specialInstructions: String? = nil) {
        self.items = items
        self.orderType = orderType
        self.restaurant = restaurant
        self.address = address
        self.specialInstructions = specialInstructions
    }
}

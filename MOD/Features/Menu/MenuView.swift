import SwiftUI

struct MenuView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var cartManager: CartManager
    
    @State private var categories: [MenuCategory] = []
    @State private var menuItems: [MenuItem] = []
    @State private var selectedCategory: MenuCategory?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var searchText: String = ""
    
    private let menuRepository = MockMenuRepository.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Loading menu...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else {
                    VStack(spacing: 0) {
                        // Search Bar
                        searchBar
                        
                        // Category Selector
                        categorySelector
                        
                        // Menu Items
                        if filteredItems.isEmpty {
                            emptyState
                        } else {
                            menuItemsList
                        }
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadData()
            }
        }
        .task {
            await loadData()
        }
        .searchable(text: $searchText, prompt: "Search Pizza, Drinks, Sides...")
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.tertiaryText)
                
                TextField("Search menu...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
    }
    
    // MARK: - Category Selector
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                CategoryChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: {
                        selectedCategory = nil
                    }
                )
                
                ForEach(categories) { category in
                    CategoryChip(
                        title: category.name,
                        isSelected: selectedCategory?.id == category.id,
                        action: {
                            selectedCategory = category
                        }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.lg)
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    // MARK: - Menu Items List
    
    private var menuItemsList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(filteredItems) { item in
                    MenuItemRow(item: item)
                        .padding(.horizontal, AppSpacing.lg)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No items found")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Try a different search or category")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filtered Items
    
    private var filteredItems: [MenuItem] {
        var items = menuItems
        
        // Filter by category
        if let category = selectedCategory {
            items = items.filter { $0.categoryId == category.id }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let categoriesData = menuRepository.getCategories()
            async let itemsData = menuRepository.getMenuItems()
            
            let (categoriesResult, itemsResult) = try await (categoriesData, itemsData)
            
            await MainActor.run {
                self.categories = categoriesResult
                self.menuItems = itemsResult
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

// MARK: - Category Chip
struct CategoryChip: View {
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
                        .fill(isSelected ? AppColors.primaryRed : AppColors.white)
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.primaryRed, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Menu Item Row
struct MenuItemRow: View {
    let item: MenuItem
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var appRouter: AppRouter
    @State private var isFavorite: Bool = false
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Item Image
            ZStack {
                // Item Image
                MenuItemImage(imageName: item.image)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius))            }
            
            // Item Details
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(item.name)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: {
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isFavorite ? AppColors.primaryRed : AppColors.tertiaryText)
                    }
                }
                
                Text(item.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(2)
                
                HStack(spacing: AppSpacing.sm) {
                    if let calories = item.calories {
                        Text("\(calories) cal")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    
                    if item.isVegetarian {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.success)
                    }
                    
                    if item.isSpicy {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.warning)
                    }
                }
                
                HStack {
                    Text("₹\(Int(item.basePrice))")
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryRed)
                    
                    Spacer()
                    
                    if item.isCustomizable {
                        Button(action: {
                            appRouter.showPizzaBuilderScreen(menuItem: item)
                        }) {
                            Text("Customize")
                                .font(AppFonts.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.primaryRed)
                                .cornerRadius(AppSpacing.smallCornerRadius)
                        }
                    } else {
                        Button(action: {
                            addToCart()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.primaryRed)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
    
    private func addToCart() {
        let cartItem = CartItem(
            menuItem: item,
            quantity: 1
        )
        cartManager.addItem(cartItem)
    }
}

#Preview {
    MenuView()
        .environmentObject(AppRouter())
        .environmentObject(CartManager.shared)
}



struct MenuItemImage: View {
    let imageName: String?
    var fallback: String = "pizza"

    // Use the item's image if it exists in Assets, otherwise fall back
    private var resolvedName: String {
        if let name = imageName, UIImage(named: name) != nil {
            return name
        }
        return fallback
    }

    var body: some View {
        Image(resolvedName)
            .resizable()
            .scaledToFill()
    }
}

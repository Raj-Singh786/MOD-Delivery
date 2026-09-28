import SwiftUI
import MapKit

struct RestaurantFinderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var restaurants: [Restaurant] = []
    @State private var searchText: String = ""
    @State private var selectedView: FinderView = .list
    @State private var selectedRestaurant: Restaurant?
    @State private var region: MKCoordinateRegion = MKCoordinateRegion()
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var showRestaurantDetails: Bool = false
    
    private let restaurantRepository = MockRestaurantRepository.shared
    private let locationService = LocationService.shared
    
    enum FinderView: String, CaseIterable {
        case list = "list"
        case map = "map"
        
        var displayName: String {
            switch self {
            case .list: return "List"
            case .map: return "Map"
            }
        }
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .map: return "map.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if isLoading {
                    LoadingView(message: "Finding restaurants...")
                } else if let errorMessage = errorMessage {
                    ErrorView(message: errorMessage, retryAction: loadData)
                } else {
                    VStack(spacing: 0) {
                        // Search Bar
                        searchBar
                        
                        // View Toggle
                        viewToggle
                        
                        // Content
                        if selectedView == .list {
                            listView
                        } else {
                            mapView
                        }
                    }
                }
            }
            .navigationTitle("Find Restaurants")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Use current location
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showRestaurantDetails) {
                if let restaurant = selectedRestaurant {
                    RestaurantDetailsView(restaurant: restaurant)
                }
            }
        }
        .task {
            await loadData()
        }
        .searchable(text: $searchText, prompt: "Search restaurants...")
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.tertiaryText)
                
                TextField("Search restaurants...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
    }
    
    // MARK: - View Toggle
    
    private var viewToggle: some View {
        HStack(spacing: 0) {
            ForEach(FinderView.allCases, id: \.self) { view in
                Button(action: {
                    selectedView = view
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: view.icon)
                            .font(.system(size: 16))
                        
                        Text(view.displayName)
                            .font(AppFonts.subheadline)
                    }
                    .foregroundColor(selectedView == view ? .white : AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        selectedView == view ? AppColors.primaryRed : Color.clear
                    )
                }
            }
        }
        .background(AppColors.white)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - List View
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(filteredRestaurants) { restaurant in
                    RestaurantListCard(restaurant: restaurant) {
                        selectedRestaurant = restaurant
                        showRestaurantDetails = true
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                
                if filteredRestaurants.isEmpty {
                    emptySearchView
                }
                
                // Bottom spacing
                Color.clear
                    .frame(height: 100)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: filteredRestaurants) { restaurant in
                MapMarker(coordinate: restaurant.location.coordinate, tint: AppColors.primaryRed)
            }
            .ignoresSafeArea()
            
            // Floating restaurant cards
            VStack {
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(filteredRestaurants.prefix(3)) { restaurant in
                            RestaurantMapCard(restaurant: restaurant) {
                                selectedRestaurant = restaurant
                                showRestaurantDetails = true
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.bottom, AppSpacing.xl)
            }
        }
    }
    
    // MARK: - Empty Search View
    
    private var emptySearchView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No restaurants found")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Try a different search or location")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filtered Restaurants
    
    private var filteredRestaurants: [Restaurant] {
        if searchText.isEmpty {
            return restaurants
        }
        
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText) ||
            restaurant.city.localizedCaseInsensitiveContains(searchText) ||
            restaurant.address.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let restaurantsData = try await restaurantRepository.getRestaurants()
            
            await MainActor.run {
                self.restaurants = restaurantsData
                
                // Set map region to first restaurant
                if let firstRestaurant = restaurantsData.first {
                    self.region = MKCoordinateRegion(
                        center: firstRestaurant.location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )
                }
                
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

// MARK: - Restaurant List Card
struct RestaurantListCard: View {
    let restaurant: Restaurant
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                // Restaurant Header
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(restaurant.name)
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(restaurant.address)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    OpenStatusBadge(isOpen: restaurant.isOpenNow)
                }
                
                // Restaurant Info
                HStack(spacing: AppSpacing.lg) {
                    // Distance
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(restaurant.distanceString)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    // Rating
                    if restaurant.rating != nil {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.gold)
                            
                            Text(restaurant.ratingString)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    // Order Types
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(restaurant.availableOrderTypes.prefix(2), id: \.self) { orderType in
                            Image(systemName: orderType.icon)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.tertiaryText)
                        }
                    }
                }
                
                // Opening Hours
                if let hours = restaurant.currentOpeningHours {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.tertiaryText)
                        
                        Text(hours.isClosed ? "Closed" : "Open until \(hours.closeTime)")
                            .font(AppFonts.caption)
                            .foregroundColor(hours.isClosed ? AppColors.error : AppColors.success)
                    }
                }
                
                // Select Button
                Button(action: onSelect) {
                    Text("Select Restaurant")
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(AppColors.primaryRed)
                        .cornerRadius(AppSpacing.smallCornerRadius)
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Restaurant Map Card
struct RestaurantMapCard: View {
    let restaurant: Restaurant
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(restaurant.name)
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(1)
            
            Text(restaurant.distanceString)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.secondaryText)
            
            Button(action: onSelect) {
                Text("Select")
                    .font(AppFonts.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.smallCornerRadius)
            }
        }
        .frame(width: 140)
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Status Badge
struct OpenStatusBadge: View {
    let isOpen: Bool
    
    var body: some View {
        Text(isOpen ? "Open" : "Closed")
            .font(AppFonts.caption)
            .foregroundColor(.white)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(isOpen ? AppColors.success : AppColors.error)
            .cornerRadius(AppSpacing.smallCornerRadius)
    }
}

// MARK: - Restaurant Details View
struct RestaurantDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    let restaurant: Restaurant
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Restaurant Image Placeholder
                    ZStack {
                        Rectangle()
                            .fill(AppColors.lightGray)
                            .frame(height: 200)
                            .cornerRadius(AppSpacing.cornerRadius)
                        
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.mediumGray)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Restaurant Info
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(restaurant.name)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(restaurant.fullAddress)
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        HStack(spacing: AppSpacing.lg) {
                            // Distance
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.tertiaryText)
                                
                                Text(restaurant.distanceString)
                                    .font(AppFonts.subheadline)
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            
                            // Rating
                            if let rating = restaurant.rating {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.gold)
                                    
                                    Text(restaurant.ratingString)
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    if let totalRatings = restaurant.totalRatings {
                                        Text("(\(totalRatings))")
                                            .font(AppFonts.caption)
                                            .foregroundColor(AppColors.tertiaryText)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Order Types
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Available Order Types")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        HStack(spacing: AppSpacing.md) {
                            ForEach(restaurant.availableOrderTypes, id: \.self) { orderType in
                                OrderTypeBadge(orderType: orderType)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Opening Hours
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Opening Hours")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        VStack(spacing: AppSpacing.sm) {
                            ForEach(restaurant.openingHours, id: \.day) { hours in
                                HStack {
                                    Text(hours.day.displayName)
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.secondaryText)
                                        .frame(width: 60, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    if hours.isClosed {
                                        Text("Closed")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.error)
                                    } else {
                                        Text("\(hours.openTime) - \(hours.closeTime)")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.primaryText)
                                    }
                                }
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                    .background(AppColors.white)
                    .cornerRadius(AppSpacing.cornerRadius)
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Contact
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("Contact")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.primaryText)
                        
                        HStack(spacing: AppSpacing.md) {
                            Button(action: {
                                // Call restaurant
                            }) {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(AppColors.primaryRed)
                                    
                                    Text(restaurant.phoneNumber)
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.primaryText)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Select Button
                    VStack(spacing: AppSpacing.md) {
                        PrimaryButton(title: "Select This Restaurant", action: {
                            appState.setSelectedRestaurant(restaurant)
                            dismiss()
                        })
                        
                        SecondaryButton(title: "View on Map", action: {
                            // Show map
                        })
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Bottom spacing
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.vertical, AppSpacing.md)
            }
            .navigationTitle("Restaurant Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Order Type Badge
struct OrderTypeBadge: View {
    let orderType: OrderType
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: orderType.icon)
                .font(.system(size: 14))
            
            Text(orderType.displayName)
                .font(AppFonts.caption)
        }
        .foregroundColor(.white)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.primaryRed)
        .cornerRadius(AppSpacing.smallCornerRadius)
    }
}

#Preview {
    RestaurantFinderView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

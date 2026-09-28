import SwiftUI

struct RestaurantSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @StateObject private var viewModel: RestaurantSelectionViewModel
    @State private var selectedView: ViewMode = .list
    @State private var showZipCodeEntry: Bool = false
    @State private var zipCodeInput: String = ""
    
    enum ViewMode: String, CaseIterable {
        case list = "List"
        case map = "Map"
        
        var icon: String {
            switch self {
            case .list: return "list.bullet"
            case .map: return "map.fill"
            }
        }
    }
    
    init(orderType: OrderType) {
        _viewModel = StateObject(wrappedValue: RestaurantSelectionViewModel(orderType: orderType))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    mainContent
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(AppColors.primaryText)
                    }
                }
            }
            .sheet(isPresented: $showZipCodeEntry) {
                zipCodeEntrySheet
            }
        }
        .task {
            await viewModel.loadRestaurants()
        }
    }
    
    // MARK: - Main Content
    
    @ViewBuilder
    private var mainContent: some View {
        VStack(spacing: 0) {
            locationSection
            searchBar
            viewToggle
            filterSortBar
            
            if selectedView == .list {
                listView
            } else {
                mapView
            }
        }
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.primaryRed)
                    
                    if viewModel.hasLocationPermission {
                        Text(viewModel.locationButtonText)
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryText)
                    } else {
                        Text("Location unavailable")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                
                Spacer()
                
                if !viewModel.hasLocationPermission {
                    Button(action: {
                        Task {
                            await viewModel.requestLocationPermission()
                        }
                    }) {
                        Text("Enable Location")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.primaryRed)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.xs)
                            .background(AppColors.primaryRed.opacity(0.1))
                            .cornerRadius(AppSpacing.smallCornerRadius)
                    }
                }
            }
            
            if !viewModel.hasLocationPermission {
                HStack(spacing: AppSpacing.sm) {
                    Text("Enable location to find restaurants near you.")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Button(action: {
                        showZipCodeEntry = true
                    }) {
                        Text("Enter ZIP Code")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.white)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.tertiaryText)
                
                TextField("Search city, state or ZIP code", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.search)
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
            ForEach(ViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring()) {
                        selectedView = mode
                    }
                }) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 16))
                        
                        Text(mode.rawValue)
                            .font(AppFonts.subheadline)
                    }
                    .foregroundColor(selectedView == mode ? .white : AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(
                        selectedView == mode ? AppColors.primaryRed : Color.clear
                    )
                }
            }
        }
        .background(AppColors.white)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Filter/Sort Bar
    
    private var filterSortBar: some View {
        HStack {
            Menu {
                ForEach(RestaurantSelectionViewModel.SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        viewModel.selectedSortOption = option
                    }) {
                        HStack {
                            Text(option.rawValue)
                            if viewModel.selectedSortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSortOption.rawValue)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.primaryText)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.tertiaryText)
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.white)
                .cornerRadius(AppSpacing.smallCornerRadius)
            }
            
            Spacer()
            
            if viewModel.orderType == .takeaway {
                filterButton(.pickup)
            } else if viewModel.orderType == .dineIn {
                filterButton(.dineIn)
            }
            
            filterButton(.openNow)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.sm)
    }
    
    private func filterButton(_ filter: RestaurantSelectionViewModel.FilterOption) -> some View {
        Button(action: {
            viewModel.toggleFilter(filter)
        }) {
            HStack(spacing: AppSpacing.xs) {
                if viewModel.activeFilters.contains(filter) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 14))
                }
                Text(filter.rawValue)
                    .font(AppFonts.caption)
            }
            .foregroundColor(viewModel.activeFilters.contains(filter) ? AppColors.primaryRed : AppColors.primaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(viewModel.activeFilters.contains(filter) ? AppColors.primaryRed.opacity(0.1) : AppColors.white)
            .cornerRadius(AppSpacing.smallCornerRadius)
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                if viewModel.filteredRestaurants.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.filteredRestaurants.prefix(viewModel.isShowingAllRestaurants ? Int.max : 5)) { restaurant in
                        RestaurantCard(
                            restaurant: restaurant,
                            orderType: viewModel.orderType,
                            onSelect: {
                                viewModel.selectRestaurant(restaurant)
                                viewModel.selectRestaurantForOrder()
                                dismiss()
                            },
                            onViewMap: {
                                withAnimation {
                                    selectedView = .map
                                    viewModel.selectedRestaurant = restaurant
                                }
                            }
                        )
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    
                    if !viewModel.isShowingAllRestaurants && viewModel.filteredRestaurants.count > 5 {
                        Button(action: {
                            withAnimation {
                                viewModel.showAllRestaurants()
                            }
                        }) {
                            Text("View All Restaurants")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primaryRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                                .background(AppColors.white)
                                .cornerRadius(AppSpacing.cornerRadius)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
                
                Color.clear
                    .frame(height: 100)
            }
            .padding(.vertical, AppSpacing.md)
        }
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        RestaurantMapView(
            restaurants: viewModel.filteredRestaurants,
            selectedRestaurant: $viewModel.selectedRestaurant,
            region: $viewModel.mapRegion,
            onSelectRestaurant: { restaurant in
                viewModel.selectRestaurant(restaurant)
                viewModel.selectRestaurantForOrder()
                dismiss()
            }
        )
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "mappin.circle.slash")
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text("No MOD Pizza locations found")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text("Try searching another city, state or ZIP code.")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            Button(action: {
                viewModel.searchText = ""
            }) {
                Text("Search Again")
                    .font(AppFonts.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppColors.primaryRed)
            
            Text("Finding restaurants...")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(AppColors.error)
            
            VStack(spacing: AppSpacing.sm) {
                Text("We couldn't load restaurants")
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text(message)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            Button(action: {
                Task {
                    await viewModel.loadRestaurants()
                }
            }) {
                Text("Try Again")
                    .font(AppFonts.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, AppSpacing.xl)
    }
    
    // MARK: - ZIP Code Entry Sheet
    
    private var zipCodeEntrySheet: some View {
        NavigationView {
            VStack(spacing: AppSpacing.xl) {
                VStack(spacing: AppSpacing.sm) {
                    Text("Enter ZIP Code")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Search for restaurants by ZIP code")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                TextField("ZIP Code", text: $zipCodeInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .padding(.horizontal, AppSpacing.xl)
                
                Spacer()
                
                PrimaryButton(title: "Search", action: {
                    Task {
                        await viewModel.searchByZipCode(zipCodeInput)
                        showZipCodeEntry = false
                    }
                })
                .padding(.horizontal, AppSpacing.xl)
                
                SecondaryButton(title: "Cancel", action: {
                    showZipCodeEntry = false
                })
                .padding(.horizontal, AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.xl)
            .navigationTitle("Search by ZIP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showZipCodeEntry = false
                    }
                }
            }
        }
    }
}

#Preview {
    RestaurantSelectionView(orderType: .takeaway)
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

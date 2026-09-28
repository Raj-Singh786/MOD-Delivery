import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
class RestaurantSelectionViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var selectedRestaurant: Restaurant?
    @Published var userLocation: CLLocation?
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var isShowingAllRestaurants: Bool = false
    
    let orderType: OrderType
    private let restaurantRepository: RestaurantRepositoryProtocol
    private let locationService: LocationServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption: String, CaseIterable {
        case nearest = "Nearest"
        case fastestPickup = "Fastest Pickup"
        case openNow = "Open Now"
    }
    
    @Published var selectedSortOption: SortOption = .nearest
    
    enum FilterOption: String, CaseIterable {
        case openNow = "Open Now"
        case pickup = "Pickup"
        case dineIn = "Dine-In"
        case delivery = "Delivery"
    }
    
    @Published var activeFilters: Set<FilterOption> = []
    
    init(orderType: OrderType,
         restaurantRepository: RestaurantRepositoryProtocol = MockRestaurantRepository.shared,
         locationService: LocationServiceProtocol = LocationService.shared) {
        self.orderType = orderType
        self.restaurantRepository = restaurantRepository
        self.locationService = locationService
        
        setupSearchBinding()
        setupSortBinding()
        setupFilterBinding()
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .combineLatest($restaurants, $activeFilters)
            .map { searchText, restaurants, filters in
                self.filterAndSortRestaurants(restaurants: restaurants, 
                                             searchText: searchText, 
                                             filters: filters)
            }
            .assign(to: &$filteredRestaurants)
    }
    
    private func setupSortBinding() {
        $selectedSortOption
            .combineLatest($filteredRestaurants)
            .map { sortOption, restaurants in
                self.sortRestaurants(restaurants: restaurants, by: sortOption)
            }
            .assign(to: &$filteredRestaurants)
    }
    
    private func setupFilterBinding() {
        $activeFilters
            .combineLatest($restaurants, $searchText)
            .map { filters, restaurants, searchText in
                self.filterAndSortRestaurants(restaurants: restaurants, 
                                             searchText: searchText, 
                                             filters: filters)
            }
            .assign(to: &$filteredRestaurants)
    }
    
    func loadRestaurants() async {
        isLoading = true
        errorMessage = nil
        
        do {
            locationPermissionStatus = locationService.authorizationStatus
            
            if locationPermissionStatus == .authorizedWhenInUse || 
               locationPermissionStatus == .authorizedAlways {
                let location = try await locationService.getCurrentLocation()
                userLocation = location
            }
            
            let restaurantsData = try await restaurantRepository.getRestaurants(
                location: userLocation,
                radius: 50000
            )
            
            await MainActor.run {
                self.restaurants = restaurantsData
                self.filteredRestaurants = filterAndSortRestaurants(
                    restaurants: restaurantsData,
                    searchText: searchText,
                    filters: activeFilters
                )
                
                if let firstRestaurant = restaurantsData.first {
                    self.mapRegion = MKCoordinateRegion(
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
    
    func requestLocationPermission() async {
        do {
            try await locationService.requestAuthorization()
            locationPermissionStatus = locationService.authorizationStatus
            
            if locationPermissionStatus == .authorizedWhenInUse || 
               locationPermissionStatus == .authorizedAlways {
                await loadRestaurants()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func searchByZipCode(_ zipCode: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let restaurantsData = try await restaurantRepository.searchRestaurants(
                query: zipCode,
                location: nil
            )
            
            await MainActor.run {
                self.restaurants = restaurantsData
                self.filteredRestaurants = restaurantsData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func selectRestaurant(_ restaurant: Restaurant) {
        selectedRestaurant = restaurant
    }
    
    func toggleFilter(_ filter: FilterOption) {
        if activeFilters.contains(filter) {
            activeFilters.remove(filter)
        } else {
            activeFilters.insert(filter)
        }
    }
    
    func showAllRestaurants() {
        isShowingAllRestaurants = true
        filteredRestaurants = restaurants
    }
    
    func selectRestaurantForOrder() {
        guard let restaurant = selectedRestaurant else { return }
        
        AppState.shared.setSelectedRestaurant(restaurant)
        AppState.shared.setOrderType(orderType)
    }
    
    private func filterAndSortRestaurants(restaurants: [Restaurant], 
                                         searchText: String, 
                                         filters: Set<FilterOption>) -> [Restaurant] {
        var filtered = restaurants
        
        if !searchText.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.city.localizedCaseInsensitiveContains(searchText) ||
                restaurant.state.localizedCaseInsensitiveContains(searchText) ||
                restaurant.zipCode.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if !filters.isEmpty {
            if filters.contains(.openNow) {
                filtered = filtered.filter { $0.isOpenNow }
            }
            
            if filters.contains(.pickup) {
                filtered = filtered.filter { $0.availableOrderTypes.contains(.takeaway) }
            }
            
            if filters.contains(.dineIn) {
                filtered = filtered.filter { $0.availableOrderTypes.contains(.dineIn) }
            }
            
            if filters.contains(.delivery) {
                filtered = filtered.filter { $0.availableOrderTypes.contains(.delivery) }
            }
        }
        
        return sortRestaurants(restaurants: filtered, by: selectedSortOption)
    }
    
    private func sortRestaurants(restaurants: [Restaurant], by sortOption: SortOption) -> [Restaurant] {
        switch sortOption {
        case .nearest:
            return restaurants.sorted { ($0.distance ?? Double.infinity) < ($1.distance ?? Double.infinity) }
        case .fastestPickup:
            return restaurants.sorted { ($0.estimatedPickupTime ?? Int.max) < ($1.estimatedPickupTime ?? Int.max) }
        case .openNow:
            return restaurants.sorted { $0.isOpenNow && !$1.isOpenNow }
        }
    }
    
    var navigationTitle: String {
        switch orderType {
        case .takeaway:
            return "Choose a pickup location"
        case .dineIn:
            return "Choose a restaurant"
        case .delivery:
            return "Choose a restaurant"
        }
    }
    
    var subtitle: String {
        switch orderType {
        case .takeaway:
            return "Select a MOD Pizza near you"
        case .dineIn:
            return "Find a MOD Pizza near you"
        case .delivery:
            return "Find a MOD Pizza near you"
        }
    }
    
    var locationButtonText: String {
        if let location = userLocation {
            return "Current Location"
        }
        return "Location unavailable"
    }
    
    var hasLocationPermission: Bool {
        locationPermissionStatus == .authorizedWhenInUse || 
        locationPermissionStatus == .authorizedAlways
    }
}

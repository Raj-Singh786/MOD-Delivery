import SwiftUI
import MapKit

struct RestaurantMapView: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?
    @Binding var region: MKCoordinateRegion
    let onSelectRestaurant: (Restaurant) -> Void
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: restaurants) { restaurant in
                MapAnnotation(coordinate: restaurant.location.coordinate) {
                    RestaurantAnnotation(
                        restaurant: restaurant,
                        isSelected: selectedRestaurant?.id == restaurant.id,
                        onTap: {
                            withAnimation(.spring()) {
                                selectedRestaurant = restaurant
                                onSelectRestaurant(restaurant)
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if let selected = selectedRestaurant {
                    RestaurantMapBottomCard(
                        restaurant: selected,
                        onSelect: {
                            onSelectRestaurant(selected)
                        }
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                    .transition(.move(edge: .bottom))
                }
            }
        }
    }
}

struct RestaurantAnnotation: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppColors.primaryRed : AppColors.white)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: isSelected ? 24 : 20))
                    .foregroundColor(isSelected ? .white : AppColors.primaryRed)
            }
        }
    }
}

struct RestaurantMapBottomCard: View {
    let restaurant: Restaurant
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(restaurant.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(shortLocationName)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(restaurant.isOpenNow ? AppColors.success : AppColors.error)
                        .frame(width: 8, height: 8)
                    
                    Text(restaurant.isOpenNow ? "Open" : "Closed")
                        .font(AppFonts.caption)
                        .foregroundColor(restaurant.isOpenNow ? AppColors.success : AppColors.error)
                }
            }
            
            HStack(spacing: AppSpacing.lg) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.tertiaryText)
                    
                    Text(distanceString)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                if let rating = restaurant.rating {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.gold)
                        
                        Text(String(format: "%.1f", rating))
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            
            PrimaryButton(title: "Select", action: onSelect)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 8, x: 0, y: 4)
    }
    
    private var shortLocationName: String {
        let locationName = restaurant.name.replacingOccurrences(of: "MOD Pizza - ", with: "")
        return locationName
    }
    
    private var distanceString: String {
        guard let distance = restaurant.distance else { return "" }
        let distanceInMiles = distance * 0.621371
        if distanceInMiles < 1 {
            return String(format: "%.1f mi", distanceInMiles)
        }
        return String(format: "%.1f mi", distanceInMiles)
    }
}

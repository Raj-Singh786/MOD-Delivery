import SwiftUI

struct RestaurantCard: View {
    let restaurant: Restaurant
    let orderType: OrderType
    let onSelect: () -> Void
    let onViewMap: () -> Void
    
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
            
            Divider()
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(restaurant.fullAddress)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
                
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
            }
            
            if orderType == .takeaway {
                takeawayInfo
            } else if orderType == .dineIn {
                dineInInfo
            }
            
            Divider()
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(restaurant.availableOrderTypes, id: \.self) { type in
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: type.icon)
                            .font(.system(size: 12))
                        
                        Text(type.displayName)
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColors.primaryRed)
                    .cornerRadius(AppSpacing.smallCornerRadius)
                }
            }
            
            HStack(spacing: AppSpacing.md) {
                SecondaryButton(title: "View on Map", action: onViewMap)
                
                PrimaryButton(title: primaryButtonTitle, action: onSelect)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
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
    
    @ViewBuilder
    private var takeawayInfo: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.tertiaryText)
                
                if let pickupTime = restaurant.estimatedPickupTime {
                    Text("Pickup in \(pickupTime)–\(pickupTime + 5) min")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                } else {
                    Text("Pickup time unavailable")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
    }
    
    @ViewBuilder
    private var dineInInfo: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.success)
                
                Text("Dine-In Available")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
    }
    
    private var primaryButtonTitle: String {
        switch orderType {
        case .takeaway:
            return "Choose Pickup"
        case .dineIn:
            return "Choose Restaurant"
        case .delivery:
            return "Choose Restaurant"
        }
    }
}

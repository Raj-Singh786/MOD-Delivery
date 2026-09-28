import SwiftUI

struct ProductCard: View {
    let item: MenuItem
    @State private var isFavorite: Bool = false
    let onAdd: () -> Void
    let onCustomize: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Image placeholder
            ZStack {
                Rectangle()
                    .fill(AppColors.lightGray)
                    .frame(height: 140)
                    .cornerRadius(AppSpacing.smallCornerRadius)
                
                Image(systemName: "pizza")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.mediumGray)
                
                // Favorite button
                Button(action: {
                    withAnimation(.spring()) {
                        isFavorite.toggle()
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(isFavorite ? AppColors.primaryRed : AppColors.white)
                }
                .padding(AppSpacing.sm)
                .background(Circle().fill(AppColors.shadow))
                .position(x: 150, y: 20)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.name)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                
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
                        Button(action: onCustomize) {
                            Text("Customize")
                                .font(AppFonts.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, AppSpacing.sm)
                                .background(AppColors.primaryRed)
                                .cornerRadius(AppSpacing.smallCornerRadius)
                        }
                    } else {
                        Button(action: onAdd) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.primaryRed)
                        }
                    }
                }
            }
        }
        .frame(width: 160)
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .shadow(color: AppColors.shadow, radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ProductCard(
        item: MockData.menuItems[0],
        onAdd: {},
        onCustomize: {}
    )
}

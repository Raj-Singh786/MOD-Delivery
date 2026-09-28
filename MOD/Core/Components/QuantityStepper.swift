import SwiftUI

struct QuantityStepper: View {
    @Binding var quantity: Int
    let minQuantity: Int
    let maxQuantity: Int
    
    init(quantity: Binding<Int>, minQuantity: Int = 1, maxQuantity: Int = 99) {
        self._quantity = quantity
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: {
                if quantity > minQuantity {
                    quantity -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(quantity > minQuantity ? AppColors.primaryRed : AppColors.mediumGray)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.lightGray)
                    )
            }
            .disabled(quantity <= minQuantity)
            
            Text("\(quantity)")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryText)
                .frame(minWidth: 24)
            
            Button(action: {
                if quantity < maxQuantity {
                    quantity += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(quantity < maxQuantity ? AppColors.primaryRed : AppColors.mediumGray)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(AppColors.lightGray)
                    )
            }
            .disabled(quantity >= maxQuantity)
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        QuantityStepper(quantity: .constant(1))
        QuantityStepper(quantity: .constant(5))
        QuantityStepper(quantity: .constant(10))
    }
    .padding()
}

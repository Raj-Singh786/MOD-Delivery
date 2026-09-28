import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryRed))
                } else {
                    Text(title)
                        .font(AppFonts.callout)
                        .foregroundColor(isDisabled ? AppColors.mediumGray : AppColors.primaryRed)
                }
            }
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .stroke(isDisabled ? AppColors.mediumGray : AppColors.primaryRed, lineWidth: 2)
            )
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isDisabled ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isDisabled)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        SecondaryButton(title: "Cancel", action: {})
        SecondaryButton(title: "Loading", action: {}, isLoading: true)
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}

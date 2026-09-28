import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(AppFonts.callout)
                        .foregroundColor(.white)
                }
            }
            .frame(height: AppSpacing.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                    .fill(isDisabled ? AppColors.mediumGray : AppColors.primaryRed)
            )
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isDisabled ? 1.0 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isDisabled)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}

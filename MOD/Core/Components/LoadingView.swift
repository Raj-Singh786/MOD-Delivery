import SwiftUI

struct LoadingView: View {
    var message: String? = nil
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryRed))
            
            if let message = message {
                Text(message)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.primaryBackground)
    }
}

#Preview {
    LoadingView(message: "Loading menu...")
}

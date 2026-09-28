import SwiftUI

struct EmptyStateView: View {
    let image: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(image: String, title: String, message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.image = image
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: image)
                .font(.system(size: 60))
                .foregroundColor(AppColors.lightGray)
            
            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primaryText)
                
                Text(message)
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.horizontal, AppSpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.primaryBackground)
    }
}

#Preview {
    EmptyStateView(
        image: "cart.badge.questionmark",
        title: "Your Cart Is Empty",
        message: "Let's add something delicious.",
        actionTitle: "Browse Menu",
        action: {}
    )
}

import SwiftUI

struct AppTheme {
    // Colors
    static let colors = AppColors.self
    
    // Fonts
    static let fonts = AppFonts.self
    
    // Spacing
    static let spacing = AppSpacing.self
    
    // Animation Durations
    static let animationDuration: Double = 0.3
    static let fastAnimationDuration: Double = 0.15
    static let slowAnimationDuration: Double = 0.5
    
    // Standard Animation
    static var standardAnimation: Animation {
        .easeInOut(duration: animationDuration)
    }
    
    static var springAnimation: Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // Card Style
    static var cardStyle: some View {
        RoundedRectangle(cornerRadius: spacing.cornerRadius)
            .fill(colors.white)
            .shadow(color: colors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // Primary Button Style
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFonts.callout)
                .foregroundColor(.white)
                .frame(height: AppSpacing.buttonHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                        .fill(AppColors.primaryRed)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
    
    // Secondary Button Style
    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(AppFonts.callout)
                .foregroundColor(AppColors.primaryRed)
                .frame(height: AppSpacing.buttonHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: AppSpacing.cornerRadius)
                        .stroke(AppColors.primaryRed, lineWidth: 2)
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

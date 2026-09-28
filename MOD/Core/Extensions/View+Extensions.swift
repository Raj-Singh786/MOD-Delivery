import SwiftUI

extension View {
    // Card Style
    func cardStyle() -> some View {
        self
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .shadow(color: AppColors.shadow, radius: 4, x: 0, y: 2)
    }
    
    // Hide Keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Conditional View
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // On Tap Gesture
    func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            TapGesture(count: count)
                .onEnded { _ in
                    action()
                }
        )
    }
}

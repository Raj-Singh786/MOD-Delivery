import SwiftUI

struct AppSpacing {
    // Base spacing unit
    static let unit: CGFloat = 4
    
    // Standard spacing
    static let xs: CGFloat = unit * 1  // 4
    static let sm: CGFloat = unit * 2  // 8
    static let md: CGFloat = unit * 3  // 12
    static let lg: CGFloat = unit * 4  // 16
    static let xl: CGFloat = unit * 5  // 20
    static let xxl: CGFloat = unit * 6  // 24
    static let xxxl: CGFloat = unit * 8 // 32
    
    // Component-specific spacing
    static let cardPadding: CGFloat = lg
    static let sectionSpacing: CGFloat = xl
    static let elementSpacing: CGFloat = md
    static let buttonHeight: CGFloat = 48
    static let inputHeight: CGFloat = 48
    static let iconSize: CGFloat = 24
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
}

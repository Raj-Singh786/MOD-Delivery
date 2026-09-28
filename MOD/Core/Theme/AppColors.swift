import SwiftUI

struct AppColors {
    // Primary Colors - MOD-inspired
    static let primaryRed = Color(red: 0.82, green: 0.22, blue: 0.22)
    static let primaryBurgundy = Color(red: 0.65, green: 0.18, blue: 0.18)
    static let warmOrange = Color(red: 0.98, green: 0.52, blue: 0.15)
    
    // Neutral Colors
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.93)
    static let offWhite = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let white = Color.white
    static let black = Color.black
    static let charcoal = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let darkGray = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let mediumGray = Color(red: 0.6, green: 0.6, blue: 0.6)
    static let lightGray = Color(red: 0.9, green: 0.9, blue: 0.9)
    
    // Semantic Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let warning = Color(red: 0.98, green: 0.72, blue: 0.15)
    static let info = Color(red: 0.2, green: 0.5, blue: 0.9)
    
    // Background Colors
    static let primaryBackground = white
    static let secondaryBackground = offWhite
    static let tertiaryBackground = cream
    
    // Text Colors
    static let primaryText = charcoal
    static let secondaryText = darkGray
    static let tertiaryText = mediumGray
    static let inverseText = white
    
    // UI Element Colors
    static let divider = lightGray
    static let shadow = Color.black.opacity(0.1)
    static let overlay = Color.black.opacity(0.5)
    
    // Loyalty Colors
    static let gold = Color(red: 0.98, green: 0.75, blue: 0.15)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.78)
    static let bronze = Color(red: 0.72, green: 0.45, blue: 0.2)
}

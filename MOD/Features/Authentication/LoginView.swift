import SwiftUI

import SwiftUI

// MARK: - Design tokens (swap these for your AppColors if you have equivalents)
private extension Color {
    static let modBackground  = Color(red: 0.980, green: 0.973, blue: 0.965) // #FAF8F6
    static let modRed         = Color(red: 0.651, green: 0.165, blue: 0.165) // #A62A2A
    static let modText        = Color(red: 0.102, green: 0.102, blue: 0.102) // #1A1A1A
    static let modBrownText   = Color(red: 0.357, green: 0.290, blue: 0.271) // #5B4A45
    static let modSkip        = Color(red: 0.478, green: 0.322, blue: 0.000) // #7A5200
    static let modField       = Color(red: 0.941, green: 0.933, blue: 0.925) // #F0EEEC
    static let modPlaceholder = Color(red: 0.710, green: 0.690, blue: 0.675) // #B5B0AC
    static let modDivider     = Color.black.opacity(0.08)
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    let onLoginComplete: () -> Void
    
    @State private var mobileNumber: String = ""
    @State private var countryCode: String = "+1"
    
    private let countryOptions: [(flag: String, code: String)] = [
        ("🇺🇸", "+1"),
        ("🇮🇳", "+91")
       
    ]
    
    private var selectedFlag: String {
        countryOptions.first(where: { $0.code == countryCode })?.flag ?? "🌐"
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                    logo.padding(.top, 8)
                    header.padding(.top, 24)
                    phoneCard.padding(.top, 32)
                    orDivider.padding(.top, 28)
                    socialButtons.padding(.top, 24)
                    
                    Spacer(minLength: 32)
                    
                    legalText
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 24)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.modBackground.ignoresSafeArea())
    }
    
    // MARK: - Top bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button(action: onLoginComplete) {
                Text("Skip for now")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.modSkip)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
        }
    }
    
    // MARK: - Logo
    private var logo: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 42, height: 42)
                .overlay(
                    Image("shield-icon").resizable().scaledToFit().frame(width: 25, height: 25)
                )
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("MOD")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.modRed)
                Text("PIZZA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.modText)
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome back")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.modText)
            
            Text("Handcrafted artisan pizzas, fresh dough, and your personal favorites await.")
                .font(.system(size: 16))
                .lineSpacing(4)
                .foregroundColor(.modBrownText)
        }
    }
    
    // MARK: - Phone card
    private var phoneCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Phone number")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.modText)
            
            HStack(spacing: 10) {
                countryMenu
                
                TextField(
                    "",
                    text: $mobileNumber,
                    prompt: Text("(415) 555-0132").foregroundColor(.modPlaceholder)
                )
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .font(.system(size: 17))
                .foregroundColor(.modText)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color.modField)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            
            Text("We'll send a 6-digit verification code.")
                .font(.system(size: 12))
                .foregroundColor(.modBrownText)
            
            Button(action: onLoginComplete) {
                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.modRed)
                .clipShape(Capsule())
                .shadow(color: Color.modRed.opacity(0.30), radius: 10, x: 0, y: 6)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
    }
    
    private var countryMenu: some View {
        Menu {
            ForEach(countryOptions, id: \.code) { option in
                Button("\(option.flag)  \(option.code)") {
                    countryCode = option.code
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedFlag)
                    .font(.system(size: 18))
                Text(countryCode)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.modText)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.modBrownText)
            }
            .fixedSize()
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(Color.modField)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
    
    // MARK: - OR divider
    private var orDivider: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Color.modDivider).frame(height: 1)
            Text("OR")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.modBrownText)
            Rectangle().fill(Color.modDivider).frame(height: 1)
        }
    }
    
    // MARK: - Social buttons
    private var socialButtons: some View {
        HStack(spacing: 16) {
            SocialLoginButton(action: {}) {
                // Replace with Image("google_logo") once you add the asset
                Text("G")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.26, green: 0.52, blue: 0.96))
            }
            SocialLoginButton(action: {}) {
                Image(systemName: "applelogo")
                    .font(.system(size: 20))
                    .foregroundColor(.modText)
            }
            SocialLoginButton(action: {}) {
                Image(systemName: "envelope")
                    .font(.system(size: 18))
                    .foregroundColor(.modText)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Legal
    private var legalText: some View {
        (
            Text("By continuing, you agree to MOD Pizza's ")
            + Text("Terms").bold().underline().foregroundColor(.modText)
            + Text(" & ")
            + Text("Privacy Policy").bold().underline().foregroundColor(.modText)
            + Text(".")
        )
        .font(.system(size: 12))
        .foregroundColor(.modBrownText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 8)
    }
}

// MARK: - Social button
struct SocialLoginButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white)
                .frame(width: 52, height: 52)
                .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))
                .overlay(content())
        }
    }
}

#Preview {
    LoginView(onLoginComplete: {})
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

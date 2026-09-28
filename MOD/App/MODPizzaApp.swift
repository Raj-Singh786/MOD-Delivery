import SwiftUI
import AppTrackingTransparency

@main
struct MODPizzaApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var appRouter = AppRouter()
    @StateObject private var cartManager = CartManager.shared
    
    @State private var showLaunchScreen: Bool = true
    @State private var showTrackingPermission: Bool = false
    @State private var showAuthChoice: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                        .onAppear {
                            handleLaunch()
                        }
                } else if showTrackingPermission {
                    TrackingPermissionScreen()
                        .onDisappear {
                            handleTrackingPermissionComplete()
                        }
                } else if showAuthChoice {
                    AuthChoiceScreen()
                        .onDisappear {
                            handleAuthChoiceComplete()
                        }
                } else {
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(appRouter)
                        .environmentObject(cartManager)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showLaunchScreen)
            .animation(.easeInOut(duration: 0.3), value: showTrackingPermission)
            .animation(.easeInOut(duration: 0.3), value: showAuthChoice)
        }
    }
    
    // MARK: - Launch Flow
    
    private func handleLaunch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showLaunchScreen = false
                
                // Show tracking permission if not requested
                if !appState.hasRequestedTrackingPermission {
                    showTrackingPermission = true
                } else {
                    // Show auth choice on first launch
                    if appState.isFirstLaunch {
                        showAuthChoice = true
                    }
                }
            }
        }
    }
    
    private func handleTrackingPermissionComplete() {
        // After tracking permission, show auth choice on first launch
        if appState.isFirstLaunch {
            showAuthChoice = true
        }
    }
    
    private func handleAuthChoiceComplete() {
        appState.markFirstLaunchComplete()
    }
}

// MARK: - Launch Screen
struct LaunchScreen: View {
    var body: some View {
        ZStack {
            AppColors.primaryRed
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: "pizza")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("MOD Pizza")
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}

// MARK: - Tracking Permission Screen
struct TrackingPermissionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primaryRed)
                
                VStack(spacing: AppSpacing.md) {
                    Text("App Tracking")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("We use tracking to improve your experience and show you personalized offers.")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                Spacer()
                
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(title: "Allow Tracking", action: requestTrackingPermission)
                        .padding(.horizontal, AppSpacing.xl)
                    
                    SecondaryButton(title: "Skip for Now", action: { dismiss() })
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                Spacer()
            }
        }
    }
    
    private func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                trackingStatus = status
                AppState.shared.markTrackingPermissionRequested()
                dismiss()
            }
        }
    }
}

// MARK: - Auth Choice Screen
struct AuthChoiceScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                Image(systemName: "pizza")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primaryRed)
                
                VStack(spacing: AppSpacing.md) {
                    Text("Welcome to MOD Pizza")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("Your favorite pizza, just the way you like it.")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }
                
                Spacer()
                
                VStack(spacing: AppSpacing.md) {
                    PrimaryButton(title: "Continue as Guest", action: {
                        dismiss()
                    })
                    .padding(.horizontal, AppSpacing.xl)
                    
                    SecondaryButton(title: "Login with OTP", action: {
                        appRouter.showProfileScreen()
                        dismiss()
                    })
                    .padding(.horizontal, AppSpacing.xl)
                }
                
                Spacer()
            }
        }
    }
}

import SwiftUI

@main
struct MODPizzaApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var appRouter = AppRouter()
    @StateObject private var cartManager = CartManager.shared
    
    @State private var showLaunchScreen: Bool = true
    @State private var showLoginScreen: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreen()
                        .onAppear {
                            handleLaunch()
                        }
                } else if showLoginScreen {
                    LoginView(onLoginComplete: {
                        withAnimation {
                            showLoginScreen = false
                        }
                    })
                    .environmentObject(appState)
                    .environmentObject(appRouter)
                } else {
                    MainTabView()
                        .environmentObject(appState)
                        .environmentObject(appRouter)
                        .environmentObject(cartManager)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showLaunchScreen)
            .animation(.easeInOut(duration: 0.3), value: showLoginScreen)
        }
    }
    
    // MARK: - Launch Flow
    
    private func handleLaunch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showLaunchScreen = false
                showLoginScreen = true
            }
        }
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

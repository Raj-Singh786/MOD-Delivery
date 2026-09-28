import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var showEditProfile: Bool = false
    @State private var showOrders: Bool = false
    @State private var showAddresses: Bool = false
    @State private var showPaymentMethods: Bool = false
    @State private var showFavorites: Bool = false
    @State private var showSettings: Bool = false
    @State private var showHelp: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.secondaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Profile Header
                        profileHeader
                        
                        // Quick Actions
                        quickActionsSection
                        
                        // Menu Sections
                        menuSections
                        
                        // Bottom spacing
                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.vertical, AppSpacing.md)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showEditProfile = true
                    }
                    .disabled(!appState.isAuthenticated)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showOrders) {
                OrdersView()
                    .environmentObject(appRouter)
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showAddresses) {
                AddressesView()
            }
            .sheet(isPresented: $showPaymentMethods) {
                PaymentMethodsView()
            }
            .sheet(isPresented: $showFavorites) {
                FavoritesView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.lightGray)
                    .frame(width: 100, height: 100)
                
                if appState.isAuthenticated, let customer = appState.currentUser {
                    Text(customer.name.prefix(1).uppercased())
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppColors.primaryRed)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.mediumGray)
                }
            }
            
            // Name and Info
            VStack(spacing: AppSpacing.xs) {
                if appState.isAuthenticated, let customer = appState.currentUser {
                    Text(customer.name)
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(customer.mobileNumber)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    if let email = customer.email {
                        Text(email)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.tertiaryText)
                    }
                } else {
                    Text("Guest User")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primaryText)
                    
                    Button(action: {
                        // Show login
                    }) {
                        Text("Login to access your account")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
            }
            
            // Loyalty Points
            if appState.isAuthenticated {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.gold)
                    
                    Text("1,240 Points")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.primaryText)
                }
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .cornerRadius(AppSpacing.cornerRadius)
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                QuickActionButton(
                    icon: "clock.fill",
                    title: "My Orders",
                    action: { showOrders = true }
                )
                
                QuickActionButton(
                    icon: "heart.fill",
                    title: "Favorites",
                    action: { showFavorites = true }
                )
                
                QuickActionButton(
                    icon: "gift.fill",
                    title: "Rewards",
                    action: { appRouter.selectTab(.rewards) }
                )
            }
        }
        .padding(.horizontal, AppSpacing.lg)
    }
    
    // MARK: - Menu Sections
    
    private var menuSections: some View {
        VStack(spacing: AppSpacing.lg) {
            // Account Section
            menuSection(
                title: "Account",
                items: [
                    MenuItem(icon: "person.fill", title: "Personal Information", action: { showEditProfile = true }),
                    MenuItem(icon: "location.fill", title: "Addresses", action: { showAddresses = true }),
                    MenuItem(icon: "creditcard.fill", title: "Payment Methods", action: { showPaymentMethods = true }),
                    MenuItem(icon: "heart.fill", title: "Favorites", action: { showFavorites = true })
                ]
            )
            
            // Preferences Section
            menuSection(
                title: "Preferences",
                items: [
                    MenuItem(icon: "bell.fill", title: "Notifications", action: {}),
                    MenuItem(icon: "gift.fill", title: "Rewards", action: { appRouter.selectTab(.rewards) }),
                    MenuItem(icon: "mappin.circle.fill", title: "Restaurant Preferences", action: {}),
                    MenuItem(icon: "gearshape.fill", title: "Settings", action: { showSettings = true })
                ]
            )
            
            // Support Section
            menuSection(
                title: "Support",
                items: [
                    MenuItem(icon: "questionmark.circle.fill", title: "Help & Support", action: { showHelp = true }),
                    MenuItem(icon: "doc.text.fill", title: "Terms & Conditions", action: {}),
                    MenuItem(icon: "shield.fill", title: "Privacy Policy", action: {})
                ]
            )
            
            // Logout Section
            if appState.isAuthenticated {
                Button(action: {
                    appState.logout()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.error)
                        
                        Text("Logout")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.error)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.tertiaryText)
                    }
                    .padding(AppSpacing.lg)
                    .background(AppColors.white)
                    .cornerRadius(AppSpacing.cornerRadius)
                }
                .padding(.horizontal, AppSpacing.lg)
            }
        }
    }
    
    // MARK: - Menu Section
    
    private func menuSection(title: String, items: [MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.tertiaryText)
                .padding(.horizontal, AppSpacing.lg)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    menuRow(item: item)
                    
                    if index < items.count - 1 {
                        Divider()
                            .padding(.leading, AppSpacing.xl * 2)
                    }
                }
            }
            .background(AppColors.white)
            .cornerRadius(AppSpacing.cornerRadius)
            .padding(.horizontal, AppSpacing.lg)
        }
    }
    
    // MARK: - Menu Row
    
    private func menuRow(item: MenuItem) -> some View {
        Button(action: item.action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryRed)
                    .frame(width: 24)
                
                Text(item.title)
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(AppSpacing.lg)
        }
    }
    
    // MARK: - MenuItem Struct
    
    struct MenuItem {
        let icon: String
        let title: String
        let action: () -> Void
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryRed.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primaryRed)
                }
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var mobileNumber: String = ""
    @State private var dateOfBirth: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Mobile Number", text: $mobileNumber)
                        .keyboardType(.phonePad)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save profile
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let customer = appState.currentUser {
                name = customer.name
                email = customer.email ?? ""
                mobileNumber = customer.mobileNumber
                dateOfBirth = customer.dateOfBirth ?? Date()
            }
        }
    }
}

// MARK: - Addresses View (Placeholder)
struct AddressesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Addresses")
                    .font(AppFonts.headline)
                
                Text("Manage your delivery addresses")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Addresses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Payment Methods View (Placeholder)
struct PaymentMethodsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Payment Methods")
                    .font(AppFonts.headline)
                
                Text("Manage your payment methods")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Payment Methods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Favorites View (Placeholder)
struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Favorites")
                    .font(AppFonts.headline)
                
                Text("Your favorite items")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Settings View (Placeholder)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(AppFonts.headline)
                
                Text("App settings and preferences")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Help View (Placeholder)
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Help & Support")
                    .font(AppFonts.headline)
                
                Text("Get help with your orders")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.secondaryText)
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState.shared)
        .environmentObject(AppRouter())
}

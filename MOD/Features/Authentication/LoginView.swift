import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    @State private var mobileNumber: String = ""
    @State private var countryCode: String = "+91"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showOTPView: Bool = false
    
    private let authenticationService = AuthenticationService.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.xl) {
                    Spacer()
                    
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primaryRed)
                        
                        Text("Welcome Back")
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.primaryText)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: AppSpacing.lg) {
                        VStack(spacing: AppSpacing.sm) {
                            Text("Mobile Number")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.secondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Picker("Country Code", selection: $countryCode) {
                                    Text("+91").tag("+91")
                                    Text("+1").tag("+1")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 80)
                                
                                Divider()
                                
                                TextField("Enter mobile number", text: $mobileNumber)
                                    .keyboardType(.numberPad)
                                    .textContentType(.telephoneNumber)
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.secondaryBackground)
                            .cornerRadius(AppSpacing.cornerRadius)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        PrimaryButton(
                            title: "Continue",
                            action: sendOTP,
                            isLoading: isLoading,
                            isDisabled: !isValidMobileNumber
                        )
                        .padding(.top, AppSpacing.md)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    
                    Spacer()
                    
                    VStack(spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.md) {
                            Rectangle()
                                .fill(AppColors.divider)
                                .frame(height: 1)
                            
                            Text("or")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.tertiaryText)
                            
                            Rectangle()
                                .fill(AppColors.divider)
                                .frame(height: 1)
                        }
                        
                        SecondaryButton(title: "Continue with Apple", action: {})
                        SecondaryButton(title: "Continue with Google", action: {})
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    
                    Spacer()
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showOTPView) {
                OTPVerifyView(mobileNumber: mobileNumber, countryCode: countryCode)
            }
        }
    }
    
    // MARK: - Validation
    
    private var isValidMobileNumber: Bool {
        mobileNumber.count == 10 && mobileNumber.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Actions
    
    private func sendOTP() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authenticationService.sendOTP(
                    mobileNumber: mobileNumber,
                    countryCode: countryCode
                )
                
                await MainActor.run {
                    isLoading = false
                    showOTPView = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - OTP Verify View
struct OTPVerifyView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var appRouter: AppRouter
    
    let mobileNumber: String
    let countryCode: String
    
    @State private var otp: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var canResend: Bool = false
    @State private var resendTimer: Int = 30
    
    private let authenticationService = AuthenticationService.shared
    
    var body: some View {
        ZStack {
            AppColors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                Spacer()
                
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.primaryRed)
                    
                    Text("Verify Your Number")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text("We sent a 6-digit code to\n\(countryCode) XXXXX \(mobileNumber.suffix(2))")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                VStack(spacing: AppSpacing.lg) {
                    HStack(spacing: AppSpacing.md) {
                        ForEach(0..<6, id: \.self) { index in
                            OTPDigit(index: index, otp: $otp)
                        }
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.error)
                    }
                    
                    PrimaryButton(
                        title: "Verify",
                        action: verifyOTP,
                        isLoading: isLoading,
                        isDisabled: otp.count != 6
                    )
                    
                    HStack(spacing: AppSpacing.sm) {
                        Text("Didn't receive the code?")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.secondaryText)
                        
                        Button(action: resendOTP) {
                            Text(canResend ? "Resend Code" : "Resend in \(resendTimer)s")
                                .font(AppFonts.subheadline)
                                .foregroundColor(canResend ? AppColors.primaryRed : AppColors.tertiaryText)
                        }
                        .disabled(!canResend)
                    }
                    
                    Button(action: { dismiss() }) {
                        Text("Change Number")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primaryRed)
                    }
                }
                .padding(.horizontal, AppSpacing.xl)
                
                Spacer()
            }
        }
        .navigationTitle("Verify OTP")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            startResendTimer()
        }
    }
    
    // MARK: - OTP Digit View
    
    struct OTPDigit: View {
        let index: Int
        @Binding var otp: String
        
        var body: some View {
            Text(getDigit())
                .font(AppFonts.title)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.primaryText)
                .frame(width: 50, height: 60)
                .background(AppColors.secondaryBackground)
                .cornerRadius(AppSpacing.smallCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.smallCornerRadius)
                        .stroke(AppColors.primaryRed, lineWidth: 2)
                )
        }
        
        private func getDigit() -> String {
            if index < otp.count {
                let stringIndex = otp.index(otp.startIndex, offsetBy: index)
                return String(otp[stringIndex])
            }
            return ""
        }
    }
    
    // MARK: - Timer
    
    private func startResendTimer() {
        canResend = false
        resendTimer = 30
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                canResend = true
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Actions
    
    private func verifyOTP() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authenticationService.verifyOTP(
                    mobileNumber: mobileNumber,
                    otp: otp
                )
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func resendOTP() {
        Task {
            do {
                _ = try await authenticationService.sendOTP(
                    mobileNumber: mobileNumber,
                    countryCode: countryCode
                )
                
                await MainActor.run {
                    startResendTimer()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    LoginView()
}

import Foundation
import Combine
import Security

// MARK: - Authentication Error
enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case invalidOTP
    case expiredOTP
    case tooManyAttempts
    case accountLocked
    case networkError(Error)
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials"
        case .invalidOTP:
            return "Invalid OTP"
        case .expiredOTP:
            return "OTP has expired"
        case .tooManyAttempts:
            return "Too many attempts. Please try again later."
        case .accountLocked:
            return "Account locked. Please contact support."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError:
            return "Server error occurred"
        case .unknown:
            return "Unknown authentication error"
        }
    }
}

// MARK: - Authentication Request/Response Models
struct OTPRequest: Codable {
    let mobileNumber: String
    let countryCode: String
}

struct OTPVerifyRequest: Codable {
    let mobileNumber: String
    let otp: String
}

struct OTPResponse: Codable {
    let success: Bool
    let message: String
    let token: String?
    let customer: Customer?
}

// MARK: - Authentication Service Protocol
protocol AuthenticationServiceProtocol {
    func sendOTP(mobileNumber: String, countryCode: String) async throws -> OTPResponse
    func verifyOTP(mobileNumber: String, otp: String) async throws -> OTPResponse
    func logout() async throws
    func refreshToken() async throws -> String
    var isAuthenticated: Bool { get }
    var currentUser: Customer? { get }
}

// MARK: - Authentication Service Implementation
class AuthenticationService: AuthenticationServiceProtocol, ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Customer? = nil
    
    private let apiService: APIServiceProtocol
    private let keychainService: KeychainServiceProtocol
    
    private init(apiService: APIServiceProtocol = APIService.shared,
                keychainService: KeychainServiceProtocol = KeychainService.shared) {
        self.apiService = apiService
        self.keychainService = keychainService
        loadSession()
    }
    
    private func loadSession() {
        if let _ = try? keychainService.getToken(key: Constants.userTokenKey),
           let customerData = UserDefaults.standard.data(forKey: "currentUser"),
           let customer = try? JSONDecoder().decode(Customer.self, from: customerData) {
            self.isAuthenticated = true
            self.currentUser = customer
        }
    }
    
    func sendOTP(mobileNumber: String, countryCode: String = "+91") async throws -> OTPResponse {
        // Mock implementation - will be replaced with actual API call
        let _ = OTPRequest(mobileNumber: mobileNumber, countryCode: countryCode)
        
        // TODO: Replace with actual API call
        // return try await apiService.post(endpoint: "/auth/send-otp", body: request, queryParams: nil)
        
        // Mock response
        return OTPResponse(
            success: true,
            message: "OTP sent successfully",
            token: nil,
            customer: nil
        )
    }
    
    func verifyOTP(mobileNumber: String, otp: String) async throws -> OTPResponse {
        // Mock implementation - will be replaced with actual API call
        let _ = OTPVerifyRequest(mobileNumber: mobileNumber, otp: otp)
        
        // TODO: Replace with actual API call
        // return try await apiService.post(endpoint: "/auth/verify-otp", body: request, queryParams: nil)
        
        // Mock validation
        guard otp.count == 6 else {
            throw AuthenticationError.invalidOTP
        }
        
        // Mock response
        let mockCustomer = Customer(
            name: "Raj Kumar",
            email: "raj@example.com",
            mobileNumber: mobileNumber
        )
        
        let mockToken = "mock_jwt_token_\(UUID().uuidString)"
        
        // Save session
        try keychainService.saveToken(key: Constants.userTokenKey, token: mockToken)
        UserDefaults.standard.set(try? JSONEncoder().encode(mockCustomer), forKey: "currentUser")
        
        await MainActor.run {
            self.isAuthenticated = true
            self.currentUser = mockCustomer
        }
        
        return OTPResponse(
            success: true,
            message: "Login successful",
            token: mockToken,
            customer: mockCustomer
        )
    }
    
    func logout() async throws {
        // TODO: Replace with actual API call
        // try await apiService.post(endpoint: "/auth/logout", body: EmptyBody(), queryParams: nil)
        
        // Clear session
        try keychainService.deleteToken(key: Constants.userTokenKey)
        UserDefaults.standard.removeObject(forKey: "currentUser")
        
        await MainActor.run {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func refreshToken() async throws -> String {
        // TODO: Implement token refresh
        return try keychainService.getToken(key: Constants.userTokenKey) ?? ""
    }
}

// MARK: - Keychain Service Protocol
protocol KeychainServiceProtocol {
    func saveToken(key: String, token: String) throws
    func getToken(key: String) throws -> String?
    func deleteToken(key: String) throws
}

// MARK: - Keychain Service Implementation
class KeychainService: KeychainServiceProtocol {
    static let shared = KeychainService()
    
    private init() {}
    
    func saveToken(key: String, token: String) throws {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item first
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw NSError(domain: "KeychainError", code: Int(status))
        }
    }
    
    func getToken(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: "KeychainError", code: Int(status))
        }
    }
}

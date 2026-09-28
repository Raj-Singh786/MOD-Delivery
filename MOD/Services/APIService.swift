import Foundation

// MARK: - API Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case tooManyRequests
    case serverUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .conflict:
            return "Resource conflict"
        case .tooManyRequests:
            return "Too many requests"
        case .serverUnavailable:
            return "Server unavailable"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// MARK: - API Service Protocol
protocol APIServiceProtocol {
    func get<T: Decodable>(endpoint: String, queryParams: [String: String]?) async throws -> T
    func post<T: Decodable, U: Encodable>(endpoint: String, body: U, queryParams: [String: String]?) async throws -> T
    func put<T: Decodable, U: Encodable>(endpoint: String, body: U, queryParams: [String: String]?) async throws -> T
    func delete<T: Decodable>(endpoint: String, queryParams: [String: String]?) async throws -> T
}

// MARK: - API Service Implementation
class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private let baseURL: String
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        self.baseURL = Constants.apiBaseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.apiTimeout
        configuration.timeoutIntervalForResource = Constants.apiTimeout
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    private func buildURL(endpoint: String, queryParams: [String: String]?) throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        if let queryParams = queryParams, !queryParams.isEmpty {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        return url
    }
    
    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        case 409:
            throw APIError.conflict
        case 429:
            throw APIError.tooManyRequests
        case 500...599:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func get<T: Decodable>(endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func post<T: Decodable, U: Encodable>(endpoint: String, body: U, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.encodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func put<T: Decodable, U: Encodable>(endpoint: String, body: U, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            throw APIError.encodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func delete<T: Decodable>(endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        let url = try buildURL(endpoint: endpoint, queryParams: queryParams)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

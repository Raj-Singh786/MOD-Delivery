import Foundation
import CoreLocation
import Combine

// MARK: - Location Error
enum LocationError: Error, LocalizedError {
    case permissionDenied
    case permissionRestricted
    case locationUnknown
    case timeout
    case serviceDisabled
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .permissionRestricted:
            return "Location permission restricted"
        case .locationUnknown:
            return "Location unknown"
        case .timeout:
            return "Location request timed out"
        case .serviceDisabled:
            return "Location services disabled"
        }
    }
}

// MARK: - Location Service Protocol
protocol LocationServiceProtocol {
    var currentLocation: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestAuthorization() async throws
    func getCurrentLocation() async throws -> CLLocation
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

// MARK: - Location Service Implementation
@MainActor
class LocationService: NSObject, LocationServiceProtocol, ObservableObject {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        setupLocationManager()
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
    }
    
    func requestAuthorization() async throws {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Wait for authorization callback
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            try await requestAuthorization()
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.permissionDenied
        }
        
        if let location = currentLocation {
            return location
        }
        
        startUpdatingLocation()
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            
            // Timeout after 10 seconds
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000)
                if self.locationContinuation != nil {
                    self.locationContinuation?.resume(throwing: LocationError.timeout)
                    self.locationContinuation = nil
                }
            }
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else { return }
            self.currentLocation = location
            
            if let continuation = self.locationContinuation {
                continuation.resume(returning: location)
                self.locationContinuation = nil
                self.stopUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let continuation = self.locationContinuation {
                continuation.resume(throwing: error)
                self.locationContinuation = nil
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
}

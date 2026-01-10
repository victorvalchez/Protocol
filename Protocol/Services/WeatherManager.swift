//
//  WeatherManager.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation
import CoreLocation

@Observable
final class WeatherManager: NSObject {
    // MARK: - Published Properties
    var uvIndex: Int = 0
    var cloudCover: Double = 0.0
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let openWeatherService = OpenWeatherService()
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    // MARK: - Computed Properties
    
    /// Calculate required sunlight duration based on cloud cover
    /// - Overcast (>50% cloud cover): 20 minutes
    /// - Clear (≤50% cloud cover): 10 minutes
    var sunlightRequiredMinutes: Int {
        return cloudCover > 0.5 ? 20 : 10
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        // Request location authorization on init
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                  locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetch current weather data from OpenWeatherMap
    @MainActor
    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        
        print("🌤️ Fetching weather...")
        
        // Request location if needed
        if locationManager.authorizationStatus == .notDetermined {
            print("📍 Requesting location authorization...")
            locationManager.requestWhenInUseAuthorization()
            // Wait a bit for authorization
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            print("❌ Location access not authorized: \(locationManager.authorizationStatus.rawValue)")
            errorMessage = "Location access required for weather data"
            isLoading = false
            return
        }
        
        // Request location update if we don't have one
        if locationManager.location == nil && currentLocation == nil {
            print("📍 Requesting location update...")
            locationManager.requestLocation()
            // Wait for location
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
        // Get current location
        guard let location = locationManager.location ?? currentLocation else {
            print("❌ Unable to determine location")
            errorMessage = "Unable to determine location"
            isLoading = false
            return
        }
        
        print("📍 Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        do {
            // Fetch weather from OpenWeatherMap
            let (uvi, clouds) = try await openWeatherService.fetchWeather(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            
            print("✅ Weather fetched: UV \(uvi), Clouds \(clouds)")
            
            // Update properties on main actor
            uvIndex = uvi
            cloudCover = clouds
            
        } catch let error as WeatherError {
            print("❌ Weather error: \(error.errorDescription ?? "Unknown")")
            errorMessage = error.errorDescription
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
        print("📍 Location updated: \(locations.first?.coordinate.latitude ?? 0), \(locations.first?.coordinate.longitude ?? 0)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("🔐 Authorization changed: \(manager.authorizationStatus.rawValue)")
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

//
//  WeatherManager.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation
import WeatherKit
import CoreLocation

@Observable
final class WeatherManager: NSObject {
    // MARK: - Published Properties
    var uvIndex: Int = 0
    var cloudCover: Double = 0.0
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Private Properties
    private let weatherService = WeatherService.shared
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
    }
    
    // MARK: - Public Methods
    
    /// Fetch current weather data
    @MainActor
    func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        
        // Request location if needed
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            errorMessage = "Location access required for weather data"
            isLoading = false
            return
        }
        
        // Get current location
        guard let location = locationManager.location ?? currentLocation else {
            errorMessage = "Unable to determine location"
            isLoading = false
            return
        }
        
        do {
            let weather = try await weatherService.weather(for: location)
            
            // Update properties on main actor
            uvIndex = weather.currentWeather.uvIndex.value
            cloudCover = weather.currentWeather.cloudCover
            
        } catch {
            errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

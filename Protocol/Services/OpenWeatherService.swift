//
//  OpenWeatherService.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation
import CoreLocation

// MARK: - OpenWeather Response Models
struct OpenWeatherResponse: Codable, Sendable {
    let current: CurrentWeather
    
    struct CurrentWeather: Codable, Sendable {
        let uvi: Double
        let clouds: Int
    }
}

// MARK: - OpenWeather Service
final class OpenWeatherService: Sendable {
    private let apiKey: String
    
    init() {
        // Load API key from Secrets.plist
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: path),
              let key = secrets["OPENWEATHER_API_KEY"] as? String else {
            fatalError("OpenWeatherMap API key not found in Secrets.plist")
        }
        self.apiKey = key
    }
    
    /// Fetch weather data from OpenWeatherMap One Call API 3.0
    func fetchWeather(latitude: Double, longitude: Double) async throws -> (uvIndex: Int, cloudCover: Double) {
        // One Call API 3.0 endpoint
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely,hourly,daily,alerts&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        // Make network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check response status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            // Log error for debugging
            if let errorString = String(data: data, encoding: .utf8) {
                print("OpenWeather API Error: \(errorString)")
            }
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Parse JSON
        let decoder = JSONDecoder()
        let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
        
        // Extract UV Index and Cloud Cover
        let uvIndex = Int(weatherResponse.current.uvi.rounded())
        let cloudCover = Double(weatherResponse.current.clouds) / 100.0 // Convert to 0.0-1.0
        
        return (uvIndex, cloudCover)
    }
}

// MARK: - Weather Errors
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError
    case locationUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to parse weather data"
        case .locationUnavailable:
            return "Location unavailable"
        }
    }
}

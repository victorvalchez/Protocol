//
//  SolarViewModel.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation

@Observable
final class SolarViewModel {
    // MARK: - Published Properties
    var uvIndex: Int = 0
    var requiredMinutes: Int = 10
    var currentMinutes: Int = 0
    
    // MARK: - Computed Properties
    
    /// Progress percentage for ring (0.0 to 1.0)
    var progress: Double {
        guard requiredMinutes > 0 else { return 0.0 }
        return min(Double(currentMinutes) / Double(requiredMinutes), 1.0)
    }
    
    /// Formatted required duration
    var requiredDurationText: String {
        "\(requiredMinutes) MIN NEEDED"
    }
    
    /// Status text
    var statusText: String {
        if currentMinutes >= requiredMinutes {
            return "COMPLETE"
        } else {
            return "\(requiredMinutes - currentMinutes) MIN REMAINING"
        }
    }
    
    // MARK: - Public Methods
    
    /// Update from weather manager
    func updateFromWeather(uvIndex: Int, requiredMinutes: Int) {
        self.uvIndex = uvIndex
        self.requiredMinutes = requiredMinutes
    }
    
    /// Update current sun exposure time
    func updateCurrentMinutes(_ minutes: Int) {
        self.currentMinutes = minutes
    }
}

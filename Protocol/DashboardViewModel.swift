//
//  DashboardViewModel.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
//

import Foundation
import SwiftUI

@Observable
final class DashboardViewModel {
    // MARK: - User Properties
    var userName: String = "VICTOR"
    var currentDate: Date = Date()
    
    // MARK: - Health Metrics
    var steps: Int = 4827
    var circadianProgress: Double = 0.65
    var solarExposureMinutes: Double = 45
    
    // MARK: - Caffeine Lock
    var wakeUpTime: Date
    
    // MARK: - Computed Properties
    var isCaffeineLocked: Bool {
        caffeineLockRemainingMinutes > 0
    }
    
    var caffeineLockRemainingMinutes: Int {
        let elapsed = Date().timeIntervalSince(wakeUpTime)
        let remaining = (90 * 60) - elapsed
        return max(0, Int(remaining / 60))
    }
    
    var caffeineLockRemainingSeconds: Int {
        let elapsed = Date().timeIntervalSince(wakeUpTime)
        let remaining = (90 * 60) - elapsed
        return max(0, Int(remaining.truncatingRemainder(dividingBy: 60)))
    }
    
    var formattedGreeting: String {
        let hour = Calendar.current.component(.hour, from: currentDate)
        switch hour {
        case 5..<12:
            return "GOOD MORNING"
        case 12..<17:
            return "GOOD AFTERNOON"
        case 17..<21:
            return "GOOD EVENING"
        default:
            return "GOOD NIGHT"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: currentDate).uppercased()
    }
    
    var circadianWindowText: String {
        let totalMinutes = Int(circadianProgress * 120)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)H \(minutes)M"
        }
        return "\(minutes)M"
    }
    
    // MARK: - Initialization
    init(wakeUpTime: Date? = nil) {
        // Default wake up time: 6:30 AM today
        if let wakeUpTime = wakeUpTime {
            self.wakeUpTime = wakeUpTime
        } else {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = 6
            components.minute = 30
            self.wakeUpTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    // MARK: - HealthKit Integration (Stubs)
    func fetchHealthKitData() async {
        // TODO: Implement HealthKit data fetching
        // - Request authorization
        // - Query step count
        // - Query sleep data for wake time
    }
    
    // MARK: - WeatherKit Integration (Stubs)
    func fetchWeatherData() async {
        // TODO: Implement WeatherKit data fetching
        // - Get sunrise/sunset times
        // - Calculate optimal circadian window
    }
    
    // MARK: - Static Helper for Testing
    static func isCaffeineLocked(wakeUpTime: Date, currentTime: Date = Date()) -> Bool {
        let elapsed = currentTime.timeIntervalSince(wakeUpTime)
        let adenosineClearanceWindow: TimeInterval = 90 * 60 // 90 minutes
        return elapsed < adenosineClearanceWindow
    }
}

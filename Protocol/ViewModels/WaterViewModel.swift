//
//  WaterViewModel.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation

@Observable
final class WaterViewModel {
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let currentIntake = "waterIntake"
        static let lastSavedDate = "waterLastSavedDate"
    }
    
    // MARK: - Published Properties
    var currentIntake: Int = 0 {
        didSet {
            saveIntake()
        }
    }
    var dailyGoal: Int = 4000 // 4L in ml
    var customAmount: String = "250" // User input for custom amount
    
    // MARK: - Computed Properties
    
    /// Progress percentage for ring (0.0 to 1.0)
    var progress: Double {
        guard dailyGoal > 0 else { return 0.0 }
        return min(Double(currentIntake) / Double(dailyGoal), 1.0)
    }
    
    /// Current intake in liters (formatted)
    var currentIntakeText: String {
        let liters = Double(currentIntake) / 1000.0
        return String(format: "%.1f", liters)
    }
    
    /// Daily goal in liters (formatted)
    var dailyGoalText: String {
        let liters = Double(dailyGoal) / 1000.0
        return String(format: "%.0f", liters)
    }
    
    /// Parse custom amount as integer
    private var parsedAmount: Int {
        Int(customAmount) ?? 250
    }
    
    // MARK: - Initialization
    init() {
        loadIntake()
        checkForNewDay()
    }
    
    // MARK: - Public Methods
    
    /// Add water intake using custom amount
    func addWater() {
        let amount = parsedAmount
        currentIntake = min(currentIntake + amount, dailyGoal)
    }
    
    /// Remove water intake using custom amount
    func removeWater() {
        let amount = parsedAmount
        currentIntake = max(currentIntake - amount, 0)
    }
    
    /// Reset daily intake
    func resetDaily() {
        currentIntake = 0
    }
    
    // MARK: - Persistence
    
    private func saveIntake() {
        UserDefaults.standard.set(currentIntake, forKey: Keys.currentIntake)
        UserDefaults.standard.set(Date(), forKey: Keys.lastSavedDate)
    }
    
    private func loadIntake() {
        currentIntake = UserDefaults.standard.integer(forKey: Keys.currentIntake)
    }
    
    private func checkForNewDay() {
        guard let lastSaved = UserDefaults.standard.object(forKey: Keys.lastSavedDate) as? Date else {
            return
        }
        
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastSaved) {
            // New day - reset intake
            resetDaily()
        }
    }
}

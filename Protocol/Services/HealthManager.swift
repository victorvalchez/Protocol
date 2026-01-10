//
//  HealthManager.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation
import HealthKit

@Observable
final class HealthManager {
    // MARK: - Published Properties
    var wakeUpTime: Date?
    var isLoading: Bool = false
    var errorMessage: String?
    var isAuthorized: Bool = false
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    
    // MARK: - Computed Properties
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Public Methods
    
    /// Request authorization for Sleep Analysis data
    @MainActor
    func requestAuthorization() async {
        guard isHealthDataAvailable else {
            errorMessage = "Health data not available on this device"
            return
        }
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            isAuthorized = true
            
            // Fetch wake-up time after authorization
            await fetchWakeUpTime()
        } catch {
            errorMessage = "Authorization failed: \(error.localizedDescription)"
            isAuthorized = false
        }
    }
    
    /// Fetch the most recent sleep session's wake-up time
    @MainActor
    func fetchWakeUpTime() async {
        print("🛏️ HealthManager: Starting fetchWakeUpTime...")
        
        guard isHealthDataAvailable else {
            print("❌ HealthManager: Health data not available")
            errorMessage = "Health data not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Use continuation to properly await the query completion
        await withCheckedContinuation { continuation in
            // Query for most recent sleep session
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { [weak self] _, samples, error in
                Task { @MainActor in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }
                    
                    if let error = error {
                        print("❌ HealthManager: Query error: \(error.localizedDescription)")
                        self.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
                        self.isLoading = false
                        continuation.resume()
                        return
                    }
                    
                    if let sleepSample = samples?.first as? HKCategorySample {
                        // Extract wake-up time (end date of sleep session)
                        self.wakeUpTime = sleepSample.endDate
                        print("✅ HealthManager: Found sleep data - wake-up time: \(sleepSample.endDate)")
                    } else {
                        // Fallback: Use a default wake-up time if no sleep data
                        let calendar = Calendar.current
                        var components = calendar.dateComponents([.year, .month, .day], from: Date())
                        components.hour = 7
                        components.minute = 0
                        self.wakeUpTime = calendar.date(from: components)
                        print("⚠️ HealthManager: No sleep data found, using default 7:00 AM: \(self.wakeUpTime?.description ?? "nil")")
                        self.errorMessage = "No sleep data found, using default wake-up time (7:00 AM)"
                    }
                    
                    self.isLoading = false
                    continuation.resume()
                }
            }
            
            healthStore.execute(query)
        }
        
        print("✅ HealthManager: fetchWakeUpTime completed, wakeUpTime = \(wakeUpTime?.description ?? "nil")")
    }
}

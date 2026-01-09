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
        guard isHealthDataAvailable else {
            errorMessage = "Health data not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        
        // Query for most recent sleep session
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { [weak self] _, samples, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to fetch sleep data: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if let sleepSample = samples?.first as? HKCategorySample {
                    // Extract wake-up time (end date of sleep session)
                    self.wakeUpTime = sleepSample.endDate
                } else {
                    // Fallback: Use a default wake-up time if no sleep data
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: Date())
                    components.hour = 7
                    components.minute = 0
                    self.wakeUpTime = calendar.date(from: components)
                    self.errorMessage = "No sleep data found, using default wake-up time (7:00 AM)"
                }
                
                self.isLoading = false
            }
        }
        
        healthStore.execute(query)
    }
}

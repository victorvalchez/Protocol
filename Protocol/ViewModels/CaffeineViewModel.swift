//
//  CaffeineViewModel.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import Foundation
import Combine

@Observable
final class CaffeineViewModel {
    // MARK: - Published Properties
    var isLocked: Bool = true
    var remainingMinutes: Int = 90
    var remainingSeconds: Int = 0
    
    // MARK: - Private Properties
    private var wakeUpTime: Date?
    private var timer: Timer?
    private let adenosineClearanceWindow: TimeInterval = 90 * 60 // 90 minutes
    
    // MARK: - Computed Properties
    
    /// Formatted countdown string (MM:SS)
    var formattedCountdown: String {
        String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
    }
    
    /// Lock status message
    var lockMessage: String {
        isLocked ? "ADENOSINE CLEARING" : "READY FOR CAFFEINE"
    }
    
    // MARK: - Initialization
    init() {
        // Start timer that updates every second
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Update wake-up time and immediately recalculate lock state
    func updateWakeUpTime(_ time: Date?) {
        print("⏰ CaffeineViewModel: updateWakeUpTime called with: \(time?.description ?? "nil")")
        self.wakeUpTime = time
        // Immediately update state when wake-up time changes
        updateLockState()
        print("⏰ CaffeineViewModel: After update - isLocked: \(isLocked), countdown: \(formattedCountdown)")
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        // Update immediately
        updateLockState()
        
        // Then update every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLockState()
        }
    }
    
    private func updateLockState() {
        guard let wakeUpTime = wakeUpTime else {
            // No wake-up time available - show locked with default time
            isLocked = true
            remainingMinutes = 90
            remainingSeconds = 0
            return
        }
        
        let elapsed = Date().timeIntervalSince(wakeUpTime)
        let remaining = adenosineClearanceWindow - elapsed
        
        if remaining > 0 {
            isLocked = true
            remainingMinutes = Int(remaining / 60)
            remainingSeconds = Int(remaining.truncatingRemainder(dividingBy: 60))
        } else {
            isLocked = false
            remainingMinutes = 0
            remainingSeconds = 0
        }
    }
}

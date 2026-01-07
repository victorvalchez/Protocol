//
//  CaffeineLockTests.swift
//  ProtocolTests
//
//  Created by Víctor Valencia on 7/1/26.
//

import Testing
import Foundation
@testable import Protocol

@Suite("Caffeine Lock Logic")
struct CaffeineLockTests {
    
    @Test("Caffeine is locked within 90 minutes of wake-up")
    func caffeineShouldBeLockedWithin90Minutes() {
        // Given: User woke up 45 minutes ago
        let wakeUpTime = Date().addingTimeInterval(-45 * 60)
        
        // When: Checking if caffeine is locked
        let isLocked = DashboardViewModel.isCaffeineLocked(wakeUpTime: wakeUpTime)
        
        // Then: Caffeine should be locked
        #expect(isLocked == true)
    }
    
    @Test("Caffeine is locked at exactly 89 minutes")
    func caffeineShouldBeLockedAt89Minutes() {
        // Given: User woke up 89 minutes ago
        let wakeUpTime = Date().addingTimeInterval(-89 * 60)
        
        // When: Checking if caffeine is locked
        let isLocked = DashboardViewModel.isCaffeineLocked(wakeUpTime: wakeUpTime)
        
        // Then: Caffeine should still be locked
        #expect(isLocked == true)
    }
    
    @Test("Caffeine is unlocked after 90 minutes")
    func caffeineShouldBeUnlockedAfter90Minutes() {
        // Given: User woke up 91 minutes ago
        let wakeUpTime = Date().addingTimeInterval(-91 * 60)
        
        // When: Checking if caffeine is locked
        let isLocked = DashboardViewModel.isCaffeineLocked(wakeUpTime: wakeUpTime)
        
        // Then: Caffeine should be unlocked
        #expect(isLocked == false)
    }
    
    @Test("Caffeine is unlocked at exactly 90 minutes")
    func caffeineShouldBeUnlockedAtExactly90Minutes() {
        // Given: User woke up exactly 90 minutes ago
        let wakeUpTime = Date().addingTimeInterval(-90 * 60)
        
        // When: Checking if caffeine is locked
        let isLocked = DashboardViewModel.isCaffeineLocked(wakeUpTime: wakeUpTime)
        
        // Then: Caffeine should be unlocked (boundary case)
        #expect(isLocked == false)
    }
    
    @Test("Caffeine lock with custom current time")
    func caffeineLockWithCustomCurrentTime() {
        // Given: Wake up at 7:00 AM, current time is 8:00 AM (60 minutes elapsed)
        let calendar = Calendar.current
        var wakeUpComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        wakeUpComponents.hour = 7
        wakeUpComponents.minute = 0
        let wakeUpTime = calendar.date(from: wakeUpComponents)!
        
        var currentComponents = wakeUpComponents
        currentComponents.hour = 8
        currentComponents.minute = 0
        let currentTime = calendar.date(from: currentComponents)!
        
        // When: Checking if caffeine is locked at 8:00 AM
        let isLocked = DashboardViewModel.isCaffeineLocked(
            wakeUpTime: wakeUpTime,
            currentTime: currentTime
        )
        
        // Then: Caffeine should be locked (only 60 minutes have passed)
        #expect(isLocked == true)
    }
    
    @Test("Caffeine becomes unlocked at 8:31 AM when waking at 7:00 AM")
    func caffeineLockBoundaryWithRealTimes() {
        // Given: Wake up at 7:00 AM
        let calendar = Calendar.current
        var wakeUpComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        wakeUpComponents.hour = 7
        wakeUpComponents.minute = 0
        let wakeUpTime = calendar.date(from: wakeUpComponents)!
        
        // Current time is 8:31 AM (91 minutes after wake up)
        var currentComponents = wakeUpComponents
        currentComponents.hour = 8
        currentComponents.minute = 31
        let currentTime = calendar.date(from: currentComponents)!
        
        // When: Checking if caffeine is locked at 8:31 AM
        let isLocked = DashboardViewModel.isCaffeineLocked(
            wakeUpTime: wakeUpTime,
            currentTime: currentTime
        )
        
        // Then: Caffeine should be unlocked
        #expect(isLocked == false)
    }
}

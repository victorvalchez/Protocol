//
//  DailyMetric.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
//

import Foundation
import SwiftData

@Model
final class DailyMetric {
    var id: UUID
    var date: Date
    var steps: Int
    var wakeUpTime: Date
    var caffeineUnlockedAt: Date?
    var solarExposureMinutes: Double
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        steps: Int = 0,
        wakeUpTime: Date = Date(),
        caffeineUnlockedAt: Date? = nil,
        solarExposureMinutes: Double = 0
    ) {
        self.id = id
        self.date = date
        self.steps = steps
        self.wakeUpTime = wakeUpTime
        self.caffeineUnlockedAt = caffeineUnlockedAt
        self.solarExposureMinutes = solarExposureMinutes
    }
}

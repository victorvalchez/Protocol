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
    
    // MARK: - Computed Properties
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
}

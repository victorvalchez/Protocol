//
//  CaffeineLockView.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI

struct CaffeineLockView: View {
    let isLocked: Bool
    let formattedCountdown: String
    let lockMessage: String
    let wakeUpTime: Date?
    
    private var formattedWakeUpTime: String {
        guard let wakeUpTime = wakeUpTime else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: wakeUpTime)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("CAFFEINE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(2)
            
            Spacer()
            
            if isLocked {
                // Locked state
                VStack(alignment: .leading, spacing: 12) {
                    // Wake-up time
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                        
                        Text("WOKE AT \(formattedWakeUpTime)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(1)
                    }
                    
                    // Lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.protocolText.opacity(0.4))
                    
                    // Countdown
                    Text(formattedCountdown)
                        .font(.system(size: 52, weight: .black, design: .monospaced))
                        .foregroundStyle(Color.protocolText.opacity(0.5))
                    
                    // Message
                    Text(lockMessage)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.protocolSecondary)
                        .tracking(1.5)
                }
            } else {
                // Unlocked state
                VStack(alignment: .leading, spacing: 12) {
                    // Wake-up time
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                        
                        Text("WOKE AT \(formattedWakeUpTime)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(1)
                    }
                    
                    // Check icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.protocolAccent)
                    
                    // Ready message
                    Text("READY")
                        .font(.system(size: 40, weight: .black))
                        .foregroundStyle(Color.protocolText)
                    
                    // Message
                    Text(lockMessage)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.protocolSecondary)
                        .tracking(1.5)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HStack(spacing: 20) {
        CaffeineLockView(
            isLocked: true,
            formattedCountdown: "45:30",
            lockMessage: "ADENOSINE CLEARING",
            wakeUpTime: Date()
        )
        .frame(width: 180, height: 200)
        
        CaffeineLockView(
            isLocked: false,
            formattedCountdown: "00:00",
            lockMessage: "READY FOR CAFFEINE",
            wakeUpTime: Date()
        )
        .frame(width: 180, height: 200)
    }
    .padding()
    .background(Color.protocolBackground)
}

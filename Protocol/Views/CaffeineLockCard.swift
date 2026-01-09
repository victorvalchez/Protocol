//
//  CaffeineLockCard.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI

struct CaffeineLockCard: View {
    let isLocked: Bool
    let formattedCountdown: String
    let lockMessage: String
    
    var body: some View {
        ZStack {
            // Base card
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("CAFFEINE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.protocolSecondary)
                    .tracking(1.2)
                
                if isLocked {
                    // Countdown timer
                    VStack(alignment: .leading, spacing: 8) {
                        Text(formattedCountdown)
                            .font(.system(size: 44, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.protocolText)
                        
                        Text(lockMessage)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(0.5)
                    }
                } else {
                    // Unlocked state
                    VStack(alignment: .leading, spacing: 8) {
                        Text("READY")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(Color.protocolAccent)
                        
                        Text(lockMessage)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(0.5)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Lock overlay when locked
            if isLocked {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(Color.protocolText.opacity(0.8))
                            
                            Text(formattedCountdown)
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.protocolText)
                        }
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CaffeineLockCard(
            isLocked: true,
            formattedCountdown: "45:30",
            lockMessage: "ADENOSINE CLEARING"
        )
        .frame(height: 180)
        
        CaffeineLockCard(
            isLocked: false,
            formattedCountdown: "00:00",
            lockMessage: "READY FOR CAFFEINE"
        )
        .frame(height: 180)
    }
    .padding()
    .background(Color.protocolBackground)
}

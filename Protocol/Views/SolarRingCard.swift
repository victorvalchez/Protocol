//
//  SolarRingCard.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI

struct SolarRingCard: View {
    let uvIndex: Int
    let progress: Double
    let requiredMinutes: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("SOLAR EXPOSURE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(1.2)
            
            HStack(spacing: 24) {
                // Progress Ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.protocolText.opacity(0.1), lineWidth: 12)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.protocolAccent,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    // UV Index in center
                    VStack(spacing: 0) {
                        Text("\(uvIndex)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(Color.protocolText)
                        
                        Text("UV")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Info
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REQUIRED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(1)
                        
                        Text("\(requiredMinutes) MIN")
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(Color.protocolText)
                    }
                    
                    Text(requiredMinutes > 10 ? "Overcast today" : "Clear skies")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.protocolAccent)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 16) {
        SolarRingCard(uvIndex: 7, progress: 0.65, requiredMinutes: 20)
        SolarRingCard(uvIndex: 3, progress: 0.3, requiredMinutes: 10)
    }
    .padding()
    .background(Color.protocolBackground)
}

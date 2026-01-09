//
//  SolarRingView.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI

struct SolarRingView: View {
    let uvIndex: Int
    let progress: Double
    let requiredMinutes: Int
    
    var body: some View {
        HStack(spacing: 32) {
            // Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Color.protocolText.opacity(0.08),
                        lineWidth: 14
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.protocolAccent,
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // UV Index in center
                VStack(spacing: 2) {
                    Text("\(uvIndex)")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(Color.protocolText)
                    
                    Text("UV")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.protocolSecondary)
                        .tracking(1.5)
                }
            }
            .frame(width: 140, height: 140)
            
            // Metrics
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("SOLAR EXPOSURE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.protocolSecondary)
                    .tracking(2)
                
                // Required minutes
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(requiredMinutes)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(Color.protocolText)
                    
                    Text("MINUTES NEEDED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.protocolSecondary)
                        .tracking(1.2)
                }
                
                // Condition indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.protocolAccent)
                        .frame(width: 6, height: 6)
                    
                    Text(requiredMinutes > 10 ? "OVERCAST" : "CLEAR SKIES")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.protocolText)
                        .tracking(1)
                }
            }
            
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        SolarRingView(uvIndex: 7, progress: 0.65, requiredMinutes: 20)
        SolarRingView(uvIndex: 3, progress: 0.3, requiredMinutes: 10)
    }
    .padding()
    .background(Color.protocolBackground)
}

//
//  WaterTrackerView.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI

struct WaterTrackerView: View {
    let currentIntake: String
    let dailyGoal: String
    let progress: Double
    @Binding var customAmount: String
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Header
            Text("HYDRATION")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Circular Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        Color.protocolText.opacity(0.08),
                        lineWidth: 10
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.protocolAccent,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // Current intake in center
                VStack(spacing: 0) {
                    Text(currentIntake)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(Color.protocolText)
                    
                    Text("/ \(dailyGoal)L")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.protocolSecondary)
                }
            }
            .frame(width: 100, height: 100)
            .onTapGesture {
                // Dismiss keyboard when tapping ring
                isInputFocused = false
            }
            
            // Increment controls
            HStack(spacing: 12) {
                // Minus button
                Button(action: {
                    isInputFocused = false
                    onDecrement()
                }) {
                    Circle()
                        .stroke(Color.protocolText.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.protocolText)
                        )
                }
                
                // Custom amount input
                HStack(spacing: 4) {
                    TextField("250", text: $customAmount)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.protocolText)
                        .multilineTextAlignment(.center)
                        .frame(width: 40)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isInputFocused = false
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isInputFocused = false
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.protocolText)
                            }
                        }
                    
                    Text("ML")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.protocolSecondary)
                        .tracking(1)
                }
                
                // Plus button
                Button(action: {
                    isInputFocused = false
                    onIncrement()
                }) {
                    Circle()
                        .fill(Color.protocolText)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.protocolBackground)
                        )
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    @Previewable @State var amount1 = "250"
    @Previewable @State var amount2 = "500"
    
    HStack(spacing: 20) {
        WaterTrackerView(
            currentIntake: "2.5",
            dailyGoal: "4",
            progress: 0.625,
            customAmount: $amount1,
            onIncrement: {},
            onDecrement: {}
        )
        .frame(width: 180, height: 200)
        
        WaterTrackerView(
            currentIntake: "0.0",
            dailyGoal: "4",
            progress: 0.0,
            customAmount: $amount2,
            onIncrement: {},
            onDecrement: {}
        )
        .frame(width: 180, height: 200)
    }
    .padding()
    .background(Color.protocolBackground)
}

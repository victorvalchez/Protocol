//
//  DashboardView.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
//

import SwiftUI
internal import Combine

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    welcomeHeader
                    bentoGrid
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.protocolBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileButton
                }
            }
        }
        .onReceive(timer) { _ in
            viewModel.currentDate = Date()
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(viewModel.formattedGreeting),")
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(Color.protocolText)
            
            Text(viewModel.userName)
                .font(.system(size: 32, weight: .black))
                .foregroundStyle(Color.protocolText)
            
            Text(viewModel.formattedDate)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.protocolSecondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Bento Grid
    private var bentoGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            // Solar Status - Hero Card (Full Width)
            solarStatusCard
                .gridCellColumns(2)
            
            // Steps Card
            stepsCard
            
            // Caffeine Lock Card
            caffeineLockCard
        }
    }
    
    // MARK: - Solar Status Card
    private var solarStatusCard: some View {
        MetricCard(title: "CIRCADIAN WINDOW", accentColor: .protocolAccent) {
            HStack(spacing: 24) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.protocolText.opacity(0.1), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.circadianProgress)
                        .stroke(
                            Color.protocolAccent,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.circadianProgress)
                    
                    VStack(spacing: 2) {
                        Text("\(Int(viewModel.circadianProgress * 100))")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(Color.protocolText)
                        
                        Text("%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                    }
                }
                .frame(width: 120, height: 120)
                
                // Stats
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OPTIMAL")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(1)
                        
                        Text(viewModel.circadianWindowText)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color.protocolText)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SOLAR EXPOSURE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(1)
                        
                        Text("\(Int(viewModel.solarExposureMinutes)) MIN")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.protocolAccent)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Steps Card
    private var stepsCard: some View {
        MetricCard(title: "STEPS", accentColor: .protocolAccent) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedSteps)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundStyle(Color.protocolText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                Text("\(6000 - viewModel.steps) TO GOAL")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.protocolAccent)
                    .tracking(0.5)
            }
        }
        .frame(minHeight: 140)
    }
    
    private var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: viewModel.steps)) ?? "\(viewModel.steps)"
    }
    
    // MARK: - Caffeine Lock Card
    private var caffeineLockCard: some View {
        ZStack {
            MetricCard(title: "CAFFEINE", accentColor: .protocolAccent) {
                VStack(alignment: .leading, spacing: 4) {
                    if viewModel.isCaffeineLocked {
                        Text(formattedCaffeineTime)
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                            .foregroundStyle(Color.protocolText)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        
                        Text("ADENOSINE CLEAR")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(0.5)
                    } else {
                        Text("UNLOCKED")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color.protocolAccent)
                        
                        Text("READY FOR CAFFEINE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.protocolSecondary)
                            .tracking(0.5)
                    }
                }
            }
            
            // Locked Overlay with Blur
            if viewModel.isCaffeineLocked {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.protocolText.opacity(0.8))
                            
                            Text(formattedCaffeineTime)
                                .font(.system(size: 24, weight: .black, design: .monospaced))
                                .foregroundStyle(Color.protocolText)
                        }
                    )
            }
        }
        .frame(minHeight: 140)
    }
    
    private var formattedCaffeineTime: String {
        let minutes = viewModel.caffeineLockRemainingMinutes
        let seconds = viewModel.caffeineLockRemainingSeconds
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Profile Button
    private var profileButton: some View {
        Button(action: {}) {
            Circle()
                .fill(Color.protocolText)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(viewModel.userName.prefix(1)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                )
        }
    }
}

#Preview {
    DashboardView()
}

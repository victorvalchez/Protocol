//
//  DashboardView.swift
//  Protocol
//
//  Created by Víctor Valencia on 9/1/26.
//

import SwiftUI
import Combine

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var weatherManager = WeatherManager()
    @State private var healthManager = HealthManager()
    @State private var caffeineViewModel = CaffeineViewModel()
    @State private var solarViewModel = SolarViewModel()
    @State private var waterViewModel = WaterViewModel()
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                // Welcome Header
                welcomeHeader
                
                // Thin separator
                Rectangle()
                    .fill(Color.protocolText.opacity(0.1))
                    .frame(height: 1)
                
                // Morning Briefing Section
                morningBriefingSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
        }
        .background(Color.protocolBackground)
        .scrollIndicators(.hidden)
        .onReceive(timer) { _ in
            viewModel.currentDate = Date()
        }
        .task {
            await refreshData()
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(viewModel.formattedGreeting),")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(Color.protocolText)
                .tracking(-0.5)
            
            Text(viewModel.userName)
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(Color.protocolText)
                .tracking(-0.5)
            
            Text(viewModel.formattedDate)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(1)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Morning Briefing Section
    private var morningBriefingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Solar Ring (full width)
            SolarRingView(
                uvIndex: solarViewModel.uvIndex,
                progress: solarViewModel.progress,
                requiredMinutes: solarViewModel.requiredMinutes
            )
            .frame(height: 180)
            
            // Thin separator
            Rectangle()
                .fill(Color.protocolText.opacity(0.08))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            // Grid with Caffeine Lock and Water Tracker
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                // Caffeine Lock (1x1)
                CaffeineLockView(
                    isLocked: caffeineViewModel.isLocked,
                    formattedCountdown: caffeineViewModel.formattedCountdown,
                    lockMessage: caffeineViewModel.lockMessage,
                    wakeUpTime: healthManager.wakeUpTime
                )
                .frame(height: 220)
                
                // Water Tracker (1x1)
                WaterTrackerView(
                    currentIntake: waterViewModel.currentIntakeText,
                    dailyGoal: waterViewModel.dailyGoalText,
                    progress: waterViewModel.progress,
                    customAmount: $waterViewModel.customAmount,
                    onIncrement: {
                        waterViewModel.addWater()
                    },
                    onDecrement: {
                        waterViewModel.removeWater()
                    }
                )
                .frame(height: 220)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Data Refresh
    @MainActor
    private func refreshData() async {
        print("🔄 Starting data refresh...")
        
        // Request HealthKit authorization if needed
        if !healthManager.isAuthorized {
            print("🔐 Requesting HealthKit authorization...")
            await healthManager.requestAuthorization()
        }
        
        // Fetch health data (sleep/wake-up time) FIRST
        print("😴 Fetching wake-up time...")
        await healthManager.fetchWakeUpTime()
        
        // Print wake-up time for debugging
        if let wakeTime = healthManager.wakeUpTime {
            print("✅ Wake-up time fetched: \(wakeTime)")
        } else {
            print("⚠️ No wake-up time available")
        }
        
        // THEN update caffeine viewmodel with the fetched wake-up time
        print("⏱️ Updating caffeine timer with wake-up time...")
        caffeineViewModel.updateWakeUpTime(healthManager.wakeUpTime)
        
        // Fetch weather data (can be async)
        print("🌤️ Fetching weather...")
        await weatherManager.fetchWeather()
        
        // Update solar viewmodel
        solarViewModel.updateFromWeather(
            uvIndex: weatherManager.uvIndex,
            requiredMinutes: weatherManager.sunlightRequiredMinutes
        )
        
        print("✅ Data refresh complete")
    }
}

#Preview {
    DashboardView()
}

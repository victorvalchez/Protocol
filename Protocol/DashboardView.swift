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
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Thin separator
                    Rectangle()
                        .fill(Color.protocolText.opacity(0.1))
                        .frame(height: 1)
                        .padding(.vertical, 8)
                    
                    // Morning Briefing Grid
                    morningBriefingGrid(in: geometry)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.protocolBackground)
            .scrollIndicators(.hidden)
            .refreshable {
                await refreshData()
            }
        }
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
    }
    
    // MARK: - Morning Briefing Grid
    @ViewBuilder
    private func morningBriefingGrid(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width - 48 // Account for horizontal padding
        let spacing: CGFloat = 16
        
        VStack(alignment: .leading, spacing: spacing) {
            // Section header
            Text("MORNING BRIEFING")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(2)
            
            // Solar Ring (2x2 equivalent - full width)
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
            
            // Caffeine Lock (1x2 - takes full width for visibility)
            CaffeineLockView(
                isLocked: caffeineViewModel.isLocked,
                formattedCountdown: caffeineViewModel.formattedCountdown,
                lockMessage: caffeineViewModel.lockMessage
            )
            .frame(height: 200)
        }
    }
    
    // MARK: - Data Refresh
    @MainActor
    private func refreshData() async {
        // Request HealthKit authorization if needed
        if !healthManager.isAuthorized {
            await healthManager.requestAuthorization()
        }
        
        // Fetch health data (sleep/wake-up time)
        await healthManager.fetchWakeUpTime()
        
        // Update caffeine viewmodel with wake-up time from HealthManager
        caffeineViewModel.updateWakeUpTime(healthManager.wakeUpTime)
        
        // Fetch weather data
        await weatherManager.fetchWeather()
        
        // Update solar viewmodel
        solarViewModel.updateFromWeather(
            uvIndex: weatherManager.uvIndex,
            requiredMinutes: weatherManager.sunlightRequiredMinutes
        )
    }
}

#Preview {
    DashboardView()
}

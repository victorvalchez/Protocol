//
//  DashboardView.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
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
            VStack(alignment: .leading, spacing: 20) {
                // Welcome Header
                welcomeHeader
                    .padding(.horizontal, 20)
                
                // Bento Grid - Fit to screen
                bentoGrid(in: geometry)
                
                Spacer()
            }
            .padding(.top, 20)
            .background(Color.protocolBackground)
            .refreshable {
                await refreshData()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(timer) { _ in
            viewModel.currentDate = Date()
        }
        .task {
            // Initial data load
            await refreshData()
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
    }
    
    // MARK: - Bento Grid
    @ViewBuilder
    private func bentoGrid(in geometry: GeometryProxy) -> some View {
        let width = geometry.size.width - 40 // Account for padding
        let spacing: CGFloat = 12
        let cardWidth = (width - spacing) / 2
        
        LazyVGrid(
            columns: [
                GridItem(.fixed(cardWidth), spacing: spacing),
                GridItem(.fixed(cardWidth), spacing: spacing)
            ],
            spacing: spacing
        ) {
            // Solar Ring Card (2x2 - spans both columns)
            SolarRingCard(
                uvIndex: solarViewModel.uvIndex,
                progress: solarViewModel.progress,
                requiredMinutes: solarViewModel.requiredMinutes
            )
            .gridCellColumns(2)
            .frame(height: 180)
            
            // Caffeine Lock Card (1x1)
            CaffeineLockCard(
                isLocked: caffeineViewModel.isLocked,
                formattedCountdown: caffeineViewModel.formattedCountdown,
                lockMessage: caffeineViewModel.lockMessage
            )
            .frame(height: 180)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Data Refresh
    @MainActor
    private func refreshData() async {
        // Request HealthKit authorization if needed
        if !healthManager.isAuthorized {
            await healthManager.requestAuthorization()
        }
        
        // Fetch health data
        await healthManager.fetchWakeUpTime()
        
        // Update caffeine viewmodel with wake-up time
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

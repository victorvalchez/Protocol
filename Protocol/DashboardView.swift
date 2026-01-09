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
    
    var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .background(Color.protocolBackground)
        .onReceive(timer) { _ in
            viewModel.currentDate = Date()
        }
    }
}

#Preview {
    DashboardView()
}

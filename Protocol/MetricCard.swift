//
//  MetricCard.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
//

import SwiftUI

// MARK: - MetricCard Component
struct MetricCard<Content: View>: View {
    let title: String
    let accentColor: Color
    let content: () -> Content
    
    init(
        title: String,
        accentColor: Color = .protocolAccent,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.accentColor = accentColor
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.protocolSecondary)
                .tracking(1.2)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Simple MetricCard Convenience
struct SimpleMetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let accentColor: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        accentColor: Color = .protocolAccent
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.accentColor = accentColor
    }
    
    var body: some View {
        MetricCard(title: title, accentColor: accentColor) {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(Color.protocolText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accentColor)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SimpleMetricCard(
            title: "STEPS",
            value: "4,827",
            subtitle: "1,173 TO GOAL"
        )
        
        MetricCard(title: "CUSTOM CARD") {
            Text("Custom Content Here")
                .font(.title)
        }
    }
    .padding()
    .background(Color.protocolBackground)
}

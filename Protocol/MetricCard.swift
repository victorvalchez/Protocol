//
//  MetricCard.swift
//  Protocol
//
//  Created by Víctor Valencia on 7/1/26.
//

import SwiftUI

// MARK: - Design System Colors
extension Color {
    static let protocolBackground = Color(hex: "F5F5F7")
    static let protocolAccent = Color(hex: "D0FF00")
    static let protocolText = Color(hex: "121212")
    static let protocolSecondary = Color(hex: "121212").opacity(0.6)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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

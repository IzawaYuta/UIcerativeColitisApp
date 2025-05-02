//
//  ViewStyleView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/01.
//

import SwiftUI

struct ViewStyleView: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var cornerRadius: CGFloat
    var darkShadowOpacity: Double
    var darkShadowRadius: CGFloat
    var darkShadowX: CGFloat
    var darkShadowY: CGFloat
    
    func body(content: Content) -> some View {
        if colorScheme == .dark {
            content
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.BG, .BR]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0)
                .shadow(color: .black.opacity(darkShadowOpacity), radius: darkShadowRadius, x: darkShadowX, y: darkShadowY)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(LinearGradient(gradient: Gradient(colors: [.white.opacity(0.1), .white.opacity(0.15), .BR, .black.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                }
        } else {
            content
                .foregroundStyle(.BG)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 10, y: 10)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(LinearGradient(gradient: Gradient(colors: [.TW, .BW, .BL]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        .padding(1)
                }
        }
    }
}

extension View {
    func viewStyleView(
        cornerRadius: CGFloat = 18,
        darkShadowOpacity: Double = 0.4,
        darkShadowRadius: CGFloat = 5,
        darkShadowX: CGFloat = 10,
        darkShadowY: CGFloat = 10
    ) -> some View {
        self.modifier(
            ViewStyleView(
                cornerRadius: cornerRadius,
                darkShadowOpacity: darkShadowOpacity,
                darkShadowRadius: darkShadowRadius,
                darkShadowX: darkShadowX,
                darkShadowY: darkShadowY
            )
        )
    }
}

#Preview {
    ZStack {
        Color.BG.ignoresSafeArea()
        RoundedRectangle(cornerRadius: 18)
            .frame(width: 150, height: 180)
            .viewStyleView()
    }
}

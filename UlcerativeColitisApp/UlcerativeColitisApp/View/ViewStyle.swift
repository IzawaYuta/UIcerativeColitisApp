//
//  ViewStyle.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/06/30.
//

import SwiftUI

struct ViewStyle: ViewModifier {
    
    
    
    func body(content: Content) -> some View {
        content
            .shadow(radius: 1)
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20)
        .frame(width: 300, height: 150)
}

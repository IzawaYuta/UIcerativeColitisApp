//
//  View2.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

struct View2: View {
    var body: some View {
        ZStack {
            Text("View2だよ")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
        .ignoresSafeArea()
    }
}

#Preview {
    View2()
}

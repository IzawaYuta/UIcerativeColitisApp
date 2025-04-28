//
//  View1.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

struct View1: View {
    var body: some View {
        ZStack {
            Text("View1だよ")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.gray)
        .ignoresSafeArea()
    }
}

#Preview {
    View1()
}

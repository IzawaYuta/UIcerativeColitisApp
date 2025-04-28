//
//  View1.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

struct View1: View {
    
    @State private var date = Date()
    
    var body: some View {
        ZStack {
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ja_JP"))
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.gray)
////        .ignoresSafeArea()
    }
}

#Preview {
    View1()
}

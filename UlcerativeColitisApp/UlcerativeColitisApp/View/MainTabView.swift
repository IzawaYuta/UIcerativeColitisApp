//
//  MainTabView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/02.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectTab = 0
    
    var body: some View {
        TabView {
            Tab("1", systemImage: "plus") {
                HomeView()
            }
            Tab("2", systemImage: "plus") {
                StoolsRecordView(selectedDate: Date())
            }
            Tab("3", systemImage: "plus") {
                UCCountView()
            }
        }
    }
}

#Preview {
    MainTabView()
}

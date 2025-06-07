//
//  MainTabView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/02.
//

import SwiftUI

//struct MainTabView: View {
//    
//    @State private var selectTab = 0
//    
//    var body: some View {
//        TabView {
//            Tab("1", systemImage: "plus") {
//                HomeView()
//            }
//            Tab("2", systemImage: "plus") {
//                StoolsRecordView(selectedDate: Date())
//            }
//            Tab("3", systemImage: "plus") {
//                MedicineInfoView()
//            }
//            Tab("4", systemImage: "plus") {
//                ChartsView()
//            }
//        }
//        .background(Color.red)
//    }
//}

enum SelectView: CaseIterable, Identifiable {
    case one
    case two
    
    var id: Self { self }
    var iconName: String {
        switch self {
        case .one: return "house"
        case .two: return "chart.bar"
        }
    }
}

struct MainTabView: View {
    @State private var selectView: SelectView = .one
    
    var body: some View {
        ZStack {
            // 背景色
            switch selectView {
            case .one:
                LinearGradient(gradient: Gradient(colors: [.green.opacity(0.3), .cyan.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            case .two:
                Color.white
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer() // コンテンツがタブバーに重ならないように調整
                
                // メインコンテンツ
                Group {
                    switch selectView {
                    case .one:
                        HomeView()
                    case .two:
                        ChartsView()
                    }
                }
                .frame(maxWidth: .infinity) // コンテンツの幅を全体に拡張
                
                // タブバー
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.red.opacity(0.3))
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .padding(.horizontal)
                    
                    HStack {
                        ForEach(SelectView.allCases) { view in
                            Button(action: {
                                withAnimation {
                                    selectView = view
                                }
                            }) {
                                Image(systemName: view.iconName)
                                    .font(.title)
                                    .foregroundColor(selectView == view ? .red : .gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
//                .padding(.horizontal) // タブバーのみに適用
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}


#Preview {
    MainTabView()
}

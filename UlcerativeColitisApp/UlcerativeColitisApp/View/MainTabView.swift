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
    case three
    
    var id: Self { self }
    var iconName: String {
        switch self {
        case .one:
            return "house"
        case .two:
            return "chart.bar"
        case .three:
            return "plus"
        }
    }
}

//struct MainTabView: View {
//    
//    @State private var selectView: SelectView = .one
//    
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            contentView
//            ZStack {
//                RoundedRectangle(cornerRadius: 18)
//                    .fill(Color.red.opacity(0.3))
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 70)
//                    .padding(.horizontal)
//                
//                HStack {
//                    ForEach(SelectView.allCases) { view in
//                        Button(action: {
//                            withAnimation {
//                                selectView = view
//                            }
//                        }) {
//                            Image(systemName: view.iconName)
//                                .font(.title)
//                                .foregroundColor(selectView == view ? .red : .gray)
//                        }
//                        .frame(maxWidth: .infinity)
//                    }
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var contentView: some View {
//        switch selectView {
//        case .one:
//            HomeView()
//        case .two:
//            ChartsView()
//        case .three:
//            MedicineInfoView()
//        }
//    }
//}

struct MainTabView: View {
    
    var body: some View {
        TabView {
            Tab("one", systemImage: "house") {
                HomeView()
            }
            Tab("one", systemImage: "house") {
                ChartsView()
            }
            Tab("one", systemImage: "house") {
                MedicineInfoView()
            }
            Tab("one", systemImage: "house") {
                MedicineListView()
            }
            Tab("one", systemImage: "house") {
                CertificateView3()
            }
        }
    }
}

#Preview {
    MainTabView()
}

//
//  HomeView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

enum SelectButton: String, CaseIterable {
    case toDay = "Today"
    case month = "Month"
}

struct HomeView: View {
    
    @State private var select: SelectButton = .toDay
    @Namespace private var segmentControl
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                Spacer()
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("", selection: $select) {
                        ForEach(SelectButton.allCases, id: \.self) { item in
                            Text(item.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch select {
        case .toDay:
            ToDayView(/*selectedDate: .constant(Date())*/)
        case .month:
            MonthView()
        }
    }
}

#Preview {
    HomeView()
}

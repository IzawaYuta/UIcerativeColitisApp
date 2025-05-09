//
//  HomeView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

enum SelectButton: String, CaseIterable {
    case option1 = "Today"
    case option2 = "Month"
}

struct HomeView: View {
    
    @State private var select: SelectButton = .option1
    @Namespace private var segmentControl
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                ForEach(SelectButton.allCases, id: \.self) { item in
                    Text(item.rawValue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .foregroundColor(select == item ? .black : .white)
                        .matchedGeometryEffect(id: item, in: segmentControl)
                        .onTapGesture {
                            withAnimation {
                                self.select = item
                            }
                        }
                }
            }
            .frame(height: 20)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white)
                            .matchedGeometryEffect(id: select, in: segmentControl,  isSource: false)
                    )
            )
            Spacer()
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch select {
        case .option1:
            ToDayView(selectedDate: .constant(Date()))
        case .option2:
            MonthView()
        }
    }
}

#Preview {
    HomeView()
}

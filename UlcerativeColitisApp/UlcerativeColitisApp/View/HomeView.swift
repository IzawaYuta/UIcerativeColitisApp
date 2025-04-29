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
        VStack {
            HStack {
                ForEach(SelectButton.allCases, id: \.self) { item in
                    Text(item.rawValue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .foregroundColor(select == item ? .white : .black)
                        .matchedGeometryEffect(id: item, in: segmentControl)
                        .onTapGesture {
                            withAnimation {
                                self.select = item
                            }
                        }
                }
            }
            .frame(height: 25)
            .padding(6)
            .background(
                Capsule()
                    .fill(Color.gray)
                    .overlay(
                        Capsule()
                            .fill(Color.black)
                            .matchedGeometryEffect(id: select, in: segmentControl,  isSource: false)
                    )
            )
            Spacer()
            contentView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch select {
        case .option1:
            View1()
        case .option2:
            View2()
        }
    }
}

#Preview {
    HomeView()
}

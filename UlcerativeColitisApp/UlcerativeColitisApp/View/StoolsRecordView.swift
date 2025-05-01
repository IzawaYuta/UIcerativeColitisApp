//
//  StoolsRecordView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI

struct StoolsRecordView: View {
    
    @State private var isSelected = false
    
    var body: some View {
        HStack(spacing: 40) {
            Image(systemName: "plus") //普通
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.black)
                        .frame(width: 50, height: 50)
                )
                .overlay {
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 3)
                        .frame(width: 50, height: 50)
                }
                .onTapGesture {
                    withAnimation {
                        isSelected.toggle()
                    }
                }
            Image(systemName: "plus") //下痢
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                )
            Image(systemName: "plus") //血便
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                )
            Image(systemName: "plus") //便秘
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                )
            Image(systemName: "plus") //硬便
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                )
            Image(systemName: "plus") //軟便
                .background(
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                )
        }
    }
}

#Preview {
    StoolsRecordView()
}

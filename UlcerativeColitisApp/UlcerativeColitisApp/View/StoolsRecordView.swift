//
//  StoolsRecordView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI

struct StoolsRecordView: View {
    
    @State private var isSelected = false
    @State private var date = Date()
    
    var body: some View {
        VStack(spacing: 50) {
            HStack(spacing: 40) {
                Image(systemName: "plus") //普通
                    .foregroundColor(.black)
                    .background(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                    )
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.yellow : Color.gray,lineWidth: 4)
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
            HStack {
                DatePicker("時間", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .pickerStyle(.menu)
                Text("追加")
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.green)
                    )
                    .onTapGesture {
                        
                    }
            }
        }
    }
}

#Preview {
    StoolsRecordView()
}

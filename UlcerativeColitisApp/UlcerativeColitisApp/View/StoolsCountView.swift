//
//  StoolsCountView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/29.
//

import SwiftUI

struct StoolsCountView: View {
    @State private var count: Int = 0
    @State private var isIncrementing: Bool = true
    
    let displayCount: Int
    var plusButton: () -> Void
    var minusButton: () -> Void
    
    var body: some View {
        HStack(spacing: 50) {
            
            
            
            HStack(spacing: 40) {
                Button {
                    minusButton()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isIncrementing = false
                    }
                } label: {
                    Image(systemName: "minus.square.fill")
                        .resizable().frame(width: 60, height: 60).foregroundColor(.red)
                }
                .disabled(displayCount <= 0)
                VStack {
                    Text("\(displayCount)")
                        .font(.system(size: 50, weight: .bold))
                        .id("count_\(count)")
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: isIncrementing ? .top : .bottom).combined(with: .opacity),
                                removal: .move(edge: isIncrementing ? .bottom : .top).combined(with: .opacity)
                            )
                        )
                }
                .frame(height: 110)
                .clipped()
                
                Button {
                    plusButton()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isIncrementing = true
                    }
                } label: {
                    Image(systemName: "plus.square.fill")
                        .resizable().frame(width: 60, height: 60).foregroundColor(.green)
                }
            }
            
            //            Button {
            //                // 0に向かうので、現在の値が0より大きければ減少アニメーション
            //                isIncrementing = count <= 0 // 0以下の場合は増加アニメ（0->0なので動かないが）
            //                withAnimation(.easeInOut(duration: 0.4)) {
            //                    count = 0
            //                }
            //            } label: {
            //                Text("リセット")
            //                    .font(.title2)
            //                    .padding(.horizontal, 30).padding(.vertical, 10)
            //                    .background(Color.gray.opacity(0.2))
            //                    .foregroundColor(.primary)
            //                    .cornerRadius(10)
            //            }
            //            .padding(.top, 20)
        }
        .padding()
    }
}


#Preview {
    StoolsCountView(displayCount: 0, plusButton: {}, minusButton: {})
}

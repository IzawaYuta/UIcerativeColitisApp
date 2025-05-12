//
//  View3.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI

struct View3: View {
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            // タップ可能な長方形
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: isExpanded ? 200 : 50) // 高さを変更
                .animation(.easeInOut, value: isExpanded) // アニメーション適用
                .onTapGesture {
                    isExpanded.toggle() // 状態を切り替え
                }
            
//            Spacer() // 下にスペースを追加
        }
        .padding()
    }
}

#Preview {
    View3()
}

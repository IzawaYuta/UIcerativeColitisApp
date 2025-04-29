//
//  View3.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/29.
//

import SwiftUI

struct View3: View {
    @State private var count: Int = 0
    // アニメーションの方向を管理するための状態変数
    // true: 増加アニメーション (下から入る), false: 減少アニメーション (上から入る)
    @State private var isIncrementing: Bool = true
    
    let displayCount: Int
    var plusButton: () -> Void
    var minusButton: () -> Void
    
    var body: some View {
        HStack(spacing: 50) {
            
            
            
            HStack(spacing: 40) {
                    Button {
                        // 減少アニメーションを設定
//                        isIncrementing = false
                        minusButton()
                        // アニメーションを伴ってカウントを減らす
                        withAnimation(.easeInOut(duration: 0.4)) {
                            isIncrementing = false
                        }
                    } label: {
                        Image(systemName: "minus.square.fill")
                            .resizable().frame(width: 60, height: 60).foregroundColor(.red)
                    }
                    .disabled(displayCount <= 0)
                // 0未満にならないように無効化も可能
                // .disabled(count <= 0)
                
                // 数字表示部分 (高さを固定し、はみ出た部分を隠す)
                VStack { // ZStackや他のコンテナでも可
                    Text("\(displayCount)")
                        .font(.system(size: 50, weight: .bold))
                    // ★ count が変わるたびに異なるViewとして認識させる
                        .id("count_\(count)")
                    // ★ トランジションを指定
                        .transition(
                            // asymmetric で挿入と削除のアニメーションを分ける
                            .asymmetric(
                                // 挿入: isIncrementingがtrueなら下から、falseなら上から
                                insertion: .move(edge: isIncrementing ? .top : .bottom).combined(with: .opacity),
                                // 削除: isIncrementingがtrueなら上へ、falseなら下へ
                                removal: .move(edge: isIncrementing ? .bottom : .top).combined(with: .opacity)
                            )
                        )
                }
                .frame(height: 110) // 数字の高さに合わせて調整 (重要)
                .clipped() // はみ出した古い数字を隠す (重要)
                
                Button {
                    // 増加アニメーションを設定
//                    isIncrementing = true
                    plusButton()
                    // アニメーションを伴ってカウントを増やす
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
        // .animation は非推奨になったため、withAnimation を使うのが一般的
        // .animation(.easeInOut(duration: 0.4), value: count) // ← VStack全体に適用する方法もある
    }
}


#Preview {
    View3(displayCount: 0, plusButton: {}, minusButton: {})
}

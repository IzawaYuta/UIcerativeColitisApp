//
//  CertificateView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/06/02.
//

import SwiftUI

struct CertificateView: View {
    @State private var applicableTextField: String = "一般Ⅰ" // サンプルデータ
    @State private var amountTextField: String = "10,000"  // サンプルデータ
    @State private var hierarchyTextField: String = "市町村民税課税世帯（一般Ⅱ）" // サンプルデータ
    @State private var deadlineTextField: String = "令和7年9月30日" // サンプルデータ
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) { // spacing 0 で Divider を密着させる
                // ヘッダータイトル (オプション)
                Text("特定医療費受給者証（指定難病）")
                    .font(.system(size: 18, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                
                ThickDivider() // タイトルの下に太い区切り線
                
                // --- 適用区分 ---
                FormRowHStack {
                    Text("適用区分")
                        .formLabelStyle()
                    TextField("", text: $applicableTextField, prompt: Text("適用区分を入力"))
                        .formTextFieldStyle()
                }
                
                ThinDivider()
                
                // --- 自己負担上限額 ---
                FormRowHStack {
                    Text("自己負担上限額") // 「自己負担上限」から変更
                        .formLabelStyle()
                    Spacer() // これで右寄せ
                    TextField("", text: $amountTextField, prompt: Text("金額"))
                        .formTextFieldStyle(width: 100, alignment: .trailing)
                        .keyboardType(.numberPad)
                    Text("円")
                        .formTextStyle()
                        .padding(.leading, -4) // TextFieldに近づける
                    Text("(月額)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
                
                ThinDivider()
                
                // --- 階層区分 ---
                FormRowHStack {
                    Text("階層区分")
                        .formLabelStyle()
                    Spacer() // TextFieldを右に寄せる
                    TextField("", text: $hierarchyTextField, prompt: Text("階層区分を入力"))
                        .formTextFieldStyle(width: 200, alignment: .trailing) // 幅を調整
                }
                
                ThinDivider()
                
                // --- 有効期間 ---
                FormRowHStack {
                    Text("有効期間") // 「有効期限」から変更
                        .formLabelStyle()
                    Spacer() // TextFieldを右に寄せる
                    TextField("", text: $deadlineTextField, prompt: Text("YYYY年MM月DD日"))
                        .formTextFieldStyle(width: 180, alignment: .trailing)
                }
                
                ThinDivider()
                
                // --- 申請受付期間と結果通知の時期 ---
                // この項目は入力ではなく表示が主なので、VStackでレイアウト
                VStack(alignment: .leading, spacing: 5) {
                    Text("申請受付期間と結果通知の時期")
                        .font(.system(size: 14, weight: .medium))
                    // ここに具体的なテキスト情報を記載します
                    Text("・申請受付期間： 随時受付\n・結果通知の時期： 申請受理後、概ね3か月程度（審査状況により前後することがあります）")
                        .font(.system(size: 12))
                        .foregroundColor(Color.black.opacity(0.8))
                        .lineSpacing(4) // 行間を調整
                        .frame(maxWidth: .infinity, alignment: .leading) // 左寄せ
                }
                .padding(.horizontal)
                .padding(.vertical, 10) // 上下の余白
                
                // (オプション) フッター部分（交付日、交付機関名、印など）
                ThickDivider()
                HStack {
                    Text("交付年月日：令和X年X月X日")
                        .font(.system(size: 12))
                    Spacer()
                }
                .padding()
                
                HStack {
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("○○県知事")
                            .font(.system(size: 14))
                        Text("公印省略") // またはハンコのイメージ
                            .font(.system(size: 10, weight: .light))
                        // .padding(5)
                        // .border(Color.red, width: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            // 全体のスタイル
            .background(Color(red: 0.99, green: 0.985, blue: 0.93)) // 薄いクリーム色
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5) // 全体を囲むしっかりとした枠線
            )
            .padding() // 画面の端からのマージン
        }
    }
}

// 各行の共通のHStackパディングを設定するコンポーネント
struct FormRowHStack<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        HStack {
            content
        }
        .padding(.horizontal)
        .padding(.vertical, 10) // 各行の上下の余白
    }
}


// --- スタイル定義のための拡張 ---

extension Text {
    /// フォームの項目ラベル用のスタイル
    func formLabelStyle() -> some View {
        self
            .font(.system(size: 14)) // フォントサイズ
            .frame(width: 110, alignment: .leading) // ラベルの幅を固定して左揃え
            .padding(.trailing, 5) // ラベルと入力欄の間のスペース
    }
    
    /// フォーム内の通常のテキスト表示用スタイル
    func formTextStyle(alignment: TextAlignment = .leading) -> some View {
        self
            .font(.system(size: 14))
            .multilineTextAlignment(alignment)
    }
}

extension TextField {
    /// フォームのTextField用のスタイル
    func formTextFieldStyle(width: CGFloat? = nil, alignment: TextAlignment = .leading) -> some View {
        self
            .font(.system(size: 14))
            .textFieldStyle(.plain) // 標準の枠線や背景を消す
            .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)) // 内側の余白
            .background(Color.white.opacity(0.9)) // TextFieldの背景色（少し透明な白）
            .overlay(
                Rectangle() // 細い枠線を追加
                    .stroke(Color.gray.opacity(0.6), lineWidth: 0.5)
            )
            .if(width != nil) { view in // 条件によって幅を指定
                view.frame(width: width)
            }
            .multilineTextAlignment(alignment) // テキストの寄せ
    }
}

// 条件付きモディファイアを使いやすくするためのヘルパー
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// --- 区切り線 ---
struct ThinDivider: View {
    var body: some View {
        Divider().background(Color.gray.opacity(0.8))
    }
}

struct ThickDivider: View {
    var body: some View {
        Divider().frame(height: 1.5).background(Color.black)
    }
}

struct CertificateView2: View {
    
    @State private var applicableTextField: String = "一般Ⅰ" // サンプルデータ
    @State private var amountTextField: String = "10,000"  // サンプルデータ
    @State private var hierarchyTextField: String = "市町村民税課税世帯（一般Ⅱ）" // サンプルデータ
    @State private var deadlineTextField: String = "令和7年9月30日" // サンプルデータ
    
    @State private var selectedStartDate: Date = Date()
    @State private var showStartDatePicker = false
    @State private var selectedEndDate: Date = Date()
    @State private var selectedDate: Date = Date()

    @State private var showEndDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // spacing 0 で Divider を密着させる
            // ヘッダータイトル (オプション)
            Text("特定医療費（指定難病）医療受給者証")
                .font(.system(size: 18, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            
            ThickDivider() // タイトルの下に太い区切り線
            
            // --- 適用区分 ---
            FormRowHStack {
                Text("適用区分")
                    .formLabelStyle()
                TextField("", text: $applicableTextField, prompt: Text("適用区分を入力"))
                    .formTextFieldStyle()
            }
            
            ThinDivider()
            
            // --- 自己負担上限額 ---
            FormRowHStack {
                Text("自己負担上限額") // 「自己負担上限」から変更
                    .formLabelStyle()
                Spacer() // これで右寄せ
                Text("月額")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
                TextField("", text: $amountTextField, prompt: Text("金額"))
                    .formTextFieldStyle(width: 100, alignment: .trailing)
                    .keyboardType(.numberPad)
                Text("円")
                    .formTextStyle()
                    .padding(.leading, -4) // TextFieldに近づける
            }
            
            ThinDivider()
            
            // --- 階層区分 ---
            FormRowHStack {
                Text("階層区分")
                    .formLabelStyle()
                Spacer() // TextFieldを右に寄せる
                TextField("", text: $hierarchyTextField, prompt: Text("階層区分を入力"))
                    .formTextFieldStyle(width: 200, alignment: .trailing) // 幅を調整
            }
            
            ThinDivider()
            
            // --- 有効期間 ---
            FormRowHStack {
                Text("有効期間") // 「有効期限」から変更
//                    .formLabelStyle()
                Spacer() // TextFieldを右に寄せる
//                TextField("", text: $deadlineTextField, prompt: Text("YYYY年MM月DD日"))
//                    .formTextFieldStyle(width: 130, alignment: .center)
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Button(action: {
                                showStartDatePicker.toggle()
                            }) {
                                Text(selectedDate, style: .date)
                                    .environment(\.locale, Locale(identifier: "ja_JP"))
                                    .environment(\.calendar, Calendar(identifier: .japanese)) // 和暦設定
                                    .foregroundColor(.primary)
                                    .font(.system(size: 13))
                            }
                            .sheet(isPresented: $showStartDatePicker) {
                                startDatePickerView()
                                    .presentationDetents([.height(300)])
                            }
                        }
                        .overlay(
                            Rectangle() // 細い枠線を追加
                                .stroke(Color.gray.opacity(0.6), lineWidth: 0.5)
                        )
                        .frame(width: 130,height: 30, alignment: .center)
                        Text("から")
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            Button(action: {
                                showEndDatePicker.toggle()
                            }) {
                                Text(selectedEndDate, style: .date)
                                    .environment(\.locale, Locale(identifier: "ja_JP"))
                                    .environment(\.calendar, Calendar(identifier: .japanese)) // 和暦設定
                                    .foregroundColor(.primary)
                                    .font(.system(size: 13))
                            }
                            .sheet(isPresented: $showEndDatePicker) {
                                endDatePickerView()
                                    .presentationDetents([.height(300)])
                            }
                        }
                        .overlay(
                            Rectangle() // 細い枠線を追加
                                .stroke(Color.gray.opacity(0.6), lineWidth: 0.5)
                        )
                        .frame(width: 130,height: 30, alignment: .center)
                    }
            }
            
            ThinDivider()
            
            // --- 申請受付期間と結果通知の時期 ---
            // この項目は入力ではなく表示が主なので、VStackでレイアウト
            VStack(alignment: .leading, spacing: 5) {
                Text("申請受付期間と結果通知の時期")
                    .font(.system(size: 14, weight: .medium))
                // ここに具体的なテキスト情報を記載します
                Text("・申請受付期間： 随時受付\n・結果通知の時期： 申請受理後、概ね3か月程度（審査状況により前後することがあります）")
                    .font(.system(size: 12))
                    .foregroundColor(Color.black.opacity(0.8))
                    .lineSpacing(4) // 行間を調整
                    .frame(maxWidth: .infinity, alignment: .leading) // 左寄せ
            }
            .padding(.horizontal)
            .padding(.vertical, 10) // 上下の余白
            
            // (オプション) フッター部分（交付日、交付機関名、印など）
            ThickDivider()
            HStack {
                Text("交付年月日：令和X年X月X日")
                    .font(.system(size: 12))
                Spacer()
            }
            .padding()
            
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 2) {
                    Text("○○県知事")
                        .font(.system(size: 14))
                    Text("公印省略") // またはハンコのイメージ
                        .font(.system(size: 10, weight: .light))
                    // .padding(5)
                    // .border(Color.red, width: 1)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
        }
            .background(Color(red: 0.99, green: 0.985, blue: 0.93))
            .overlay {
                Rectangle()
                .stroke(Color.black, lineWidth: 1.5)
            }
            .padding(.horizontal)
    }
    
    func startDatePickerView() -> some View {
        VStack {
            DatePicker("有効期限", selection: $selectedStartDate, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environment(\.calendar, Calendar(identifier: .japanese)) // 和暦設定
            HStack {
                Button("キャンセル", role: .cancel) {
                    showStartDatePicker = false
                }
                Spacer()
                Button("保存") {
                    showStartDatePicker = false
                }
            }
            .padding(.horizontal, 100)
        }
    }
    
    func endDatePickerView() -> some View {
        VStack {
            DatePicker("有効期限", selection: $selectedEndDate, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .environment(\.calendar, Calendar(identifier: .japanese)) // 和暦設定
            HStack {
                Button("キャンセル", role: .cancel) {
                    showEndDatePicker = false
                }
                Spacer()
                Button("保存") {
                    showEndDatePicker = false
                }
            }
            .padding(.horizontal, 100)
        }
    }
}

#Preview {
    CertificateView2()
}

#Preview {
    CertificateView()
}

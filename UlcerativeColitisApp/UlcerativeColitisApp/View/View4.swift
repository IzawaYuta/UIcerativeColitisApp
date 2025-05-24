//
//  View4.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/01.
//

import SwiftUI
import Foundation

struct Medication: Identifiable, Codable { // Codable はデータ保存時に便利
    var id = UUID()
    var name: String = ""
    var intakeTime: Date = Date() // 服用時間 (日付部分は無視して時間のみ使う想定)
    var quantity: Int = 1         // 1回の服用数量
    var unit: String = "錠"       // 単位 (錠, 包, ml, etc.)
    var stock: Int = 30          // 現在の在庫数
    var memo: String = ""        // メモ欄
}
struct MedicationListView: View {
    // サンプルデータ (実際は@StateObjectなどでViewModelを持つか、
    // @FetchRequestなどで永続化データを読み込む)
    @State private var medications: [Medication] = sampleMedications
    @State private var showingAddSheet = false // 新規追加シート表示用
    
    var body: some View {
        NavigationView {
            List {
                ForEach($medications) { $medication in // Bindingで渡すために$をつける
                    NavigationLink(destination: View4(medication: $medication, isNew: false)) {
                        MedicationRow(medication: medication)
                    }
                }
                .onDelete(perform: deleteMedication) // 削除機能
            }
            .navigationTitle("お薬リスト")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton() // 編集モード（削除用）
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            // 新規追加用のシート
            .sheet(isPresented: $showingAddSheet) {
                // 新しい Medication インスタンスを渡す
                NavigationView { // シート内にもNavigationViewを入れるとタイトルや保存/キャンセルボタンを配置しやすい
                    View4(
                        medication: .constant(Medication()), // 新規用の空データ Binding
                        isNew: true,
                        onSave: { newMed in // 保存時のコールバック
                            medications.append(newMed)
                            showingAddSheet = false
                        },
                        onCancel: { // キャンセル時のコールバック
                            showingAddSheet = false
                        }
                    )
                }
            }
        }
    }
    
    // リストの行の見た目
    struct MedicationRow: View {
        let medication: Medication
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(medication.name)
                        .font(.headline)
                    Text("時間: \(medication.intakeTime, style: .time)") // 時間のみ表示
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("数量: \(medication.quantity) \(medication.unit)")
                        .font(.subheadline)
                    Text("在庫: \(medication.stock)")
                        .font(.subheadline)
                        .foregroundColor(medication.stock < 10 ? .red : .secondary) // 在庫少で色変更
                }
            }
            .padding(.vertical, 4) // 行の上下に少し余白
        }
    }
    
    // 削除処理
    private func deleteMedication(at offsets: IndexSet) {
        medications.remove(atOffsets: offsets)
        // ここで永続化データの削除処理も行う
    }
}

// MARK: - Sample Data
let sampleMedications = [
    Medication(name: "痛み止めA", intakeTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!, quantity: 1, unit: "錠", stock: 25, memo: "食後に服用"),
    Medication(name: "胃薬B", intakeTime: Calendar.current.date(bySettingHour: 19, minute: 30, second: 0, of: Date())!, quantity: 1, unit: "包", stock: 50, memo: ""),
    Medication(name: "シロップC", intakeTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!, quantity: 5, unit: "ml", stock: 8, memo: "よく振ってから")
]

// MARK: - Preview
struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView()
    }
}

struct View4: View {
    @Binding var medication: Medication // リストから渡されるデータ (編集可能)
    let isNew: Bool // 新規追加モードかどうかのフラグ
    
    // コールバック関数 (シートで表示する場合に使う)
    var onSave: ((Medication) -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    @Environment(\.presentationMode) var presentationMode // 画面を閉じるため
    
    // 単位選択肢
    private let units = ["錠", "包", "カプセル", "ml", "g", "滴", "回", "個"]
    // 時間選択の表示制御
    @State private var showingTimePicker = false
    
    var body: some View {
        Form {
            Section("基本情報") {
                TextField("薬の名前", text: $medication.name)
                
                // 時間表示と編集ボタン
                HStack {
                    Text("飲む時間")
                    Spacer()
                    Text(medication.intakeTime, style: .time)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            withAnimation {
                                showingTimePicker.toggle()
                            }
                        }
                }
                
                // 時間ピッカー (タップで表示/非表示)
                if showingTimePicker {
                    DatePicker("時間選択", selection: $medication.intakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle()) // ホイールスタイル
                        .labelsHidden() // "時間選択"ラベルを非表示
                }
            }
            
            Section("服用量と在庫") {
                HStack {
                    Text("1回の数量")
                    Spacer()
                    // StepperとTextFieldを組み合わせる
                    TextField("数量", value: $medication.quantity, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                    Stepper("", value: $medication.quantity, in: 1...100) // 1以上の整数
                }
                
                HStack {
                    Text("単位")
                    Spacer()
                    Picker("単位", selection: $medication.unit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                        // Pickerだけだと幅が広すぎる場合があるのでTextFieldで自由入力も併用する手もある
                        // TextField("単位", text: $medication.unit).multilineTextAlignment(.trailing)
                    }
                    .pickerStyle(.menu) // ドロップダウンメニュー形式
                }
                
                
                HStack {
                    Text("現在の在庫数")
                    Spacer()
                    TextField("在庫", value: $medication.stock, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Stepper("", value: $medication.stock, in: 0...1000) // 0以上の整数
                }
            }
            
            Section("メモ") {
                // TextEditorは複数行入力に対応
                TextEditor(text: $medication.memo)
                    .frame(height: 100) // 高さを指定
            }
        }
        .navigationTitle(isNew ? "新しいお薬" : "詳細・編集")
        .navigationBarTitleDisplayMode(.inline) // タイトルをインライン表示
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // シート表示の場合はキャンセルボタン
                if isNew {
                    Button("キャンセル") {
                        onCancel?() // コールバック呼び出し
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveMedication()
                }
                // 名前が空の場合は保存ボタンを無効化
                .disabled(medication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
    
    private func saveMedication() {
        // 簡単なバリデーション (名前が空でないかなど)
        guard !medication.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // アラートなどを表示しても良い
            print("薬の名前が入力されていません。")
            return
        }
        
        print("保存する薬: \(medication)") // デバッグ用
        
        // 永続化処理 (CoreData, Realm, UserDefaultsなど) をここで行う
        // 例: viewModel.save(medication)
        
        if let onSave = onSave, isNew {
            // 新規追加モードで、コールバックが設定されていれば呼び出す
            onSave(medication)
        } else {
            // 既存データの編集の場合は、画面を閉じるだけで
            // @Binding によりリスト側のデータも更新されているはず
            presentationMode.wrappedValue.dismiss()
        }
    }
}

//// MARK: - Preview for Detail View
struct MedicationDetailView_Previews: PreviewProvider {
    // プレビュー用にダミーの @State を用意
    @State static var previewMedication = sampleMedications[0]
    @State static var newMedication = Medication()
    
    static var previews: some View {
        // 既存データ編集のプレビュー
        NavigationView {
            View4(medication: $previewMedication, isNew: false)
        }
        .previewDisplayName("Edit Existing")
        
        // 新規追加のプレビュー (シート表示を想定)
        NavigationView {
            View4(medication: $newMedication, isNew: true, onSave: { _ in }, onCancel: {})
        }
        .previewDisplayName("Add New")
    }
}

//#Preview {
//    View4()
//}

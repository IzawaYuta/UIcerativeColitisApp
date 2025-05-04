//
//  ToDayView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

struct ToDayView: View {
    
    @State private var date = Date()
    @State private var showDatePicker = false
    @State private var count: Int = 0
    @State private var showStoolsRecordView = false
    //    @ObservedResults(DateData.self) var dateDataList
    @ObservedResults(DateData.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var dateDataList
    
    private var stoolRecordCountForSelectedDate: Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return 0
        }
        let realm = try! Realm()
        // 選択された日付の範囲でフィルタリングしてカウント
        return realm.objects(StoolRecordModel.self)
            .filter("date >= %@ AND date < %@", startOfDay as NSDate, startOfNextDay as NSDate)
            .count
    }
    
    // --- UI ---
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Text(date, style: .date)
                    .padding(.horizontal)
                    .font(.system(size: 28, weight: .bold))
                    .onTapGesture { showDatePicker = true }
                    .sheet(isPresented: $showDatePicker) {
                        DatePickerSheet(selectedDate: $date)
                    }
                Spacer()
            }
            .padding(.top)
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
                
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button {
                        showStoolsRecordView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showStoolsRecordView) {
                        // StoolsRecordViewに選択中の日付を渡す
                        StoolsRecordView(selectedDate: date)
                            .presentationDetents([.medium, .large])
                    }
                    
                    Spacer() // 中央スペース
                    
                    // 回数表示
                    VStack {
                        Text("記録回数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(stoolRecordCountForSelectedDate)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .id(date)
                    }
                    
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .frame(height: 80)
            .padding(.horizontal)
            
            // --- (オプション) StoolsCountView を使う場合 ---
            /*
             ZStack {
             RoundedRectangle(cornerRadius: 15)
             .fill(Color.gray.secondary)
             HStack {
             // ... 追加ボタンなど ...
             StoolsCountView(
             displayCount: legacyCount, // DateData のカウント
             plusButton: {
             let newCount = legacyCount + 1
             saveDateDataCount(count: newCount)
             self.legacyCount = newCount
             },
             minusButton: {
             if legacyCount > 0 {
             let newCount = legacyCount - 1
             saveDateDataCount(count: newCount)
             self.legacyCount = newCount
             }
             }
             )
             }
             }
             .frame(height: 60)
             .padding(.horizontal)
             */
            
            // --- (オプション) 記録リスト表示 ---
            // List { ... }
            
            Spacer() // 全体を上に寄せる
        }
        // .onAppear {
        //     // DateDataのカウントをロードする場合
        //     // loadDateDataCount(for: date)
        // }
        .onChange(of: date) { newDate in
            // 日付が変わったときにDateDataのカウントを再ロードする場合
            // loadDateDataCount(for: newDate)
            // stoolRecordCountForSelectedDate は自動的に再計算される
            print("Date changed to: \(newDate)")
        }
        // StoolsRecordViewが閉じたときにカウントが更新されるように、
        // stoolRecordCountForSelectedDate の再評価をトリガーする必要がある場合がある
        // SwiftUIが自動で検知してくれることが多いが、もし更新されない場合は
        // ダミーのState変更などでViewの再描画を促す
        // .onChange(of: showStoolsRecordView) { isPresented in
        //     if !isPresented {
        //         // ここでダミーStateを更新するなどしてViewを再描画させる
        //     }
        // }
    }
    
    // --- (オプション) DateData用の関数 ---
    /*
     private func saveDateDataCount(count newCount: Int) {
     let targetDateStart = Calendar.current.startOfDay(for: date)
     let realm = try! Realm()
     let config = Realm.Configuration.defaultConfiguration // 必要に応じて設定を取得
     
     // メインスレッド以外から Realm を使う場合は明示的にインスタンス化
     // let realm = try! Realm(configuration: config)
     
     let existingData = realm.objects(DateData.self).filter("date == %@", targetDateStart).first
     
     try! realm.write {
     if let dataToUpdate = existingData?.thaw() { // thaw() で Frozen -> Live
     guard !dataToUpdate.isInvalidated else { return }
     dataToUpdate.stoolsCount = newCount
     } else {
     let newData = DateData()
     newData.date = targetDateStart
     newData.stoolsCount = newCount
     realm.add(newData, update: .modified) // 主キーがあるので modified を使う
     }
     }
     }
     
     private func loadDateDataCount(for targetDate: Date) {
     let targetDateStart = Calendar.current.startOfDay(for: targetDate)
     let realm = try! Realm()
     let specificData = realm.objects(DateData.self).filter("date == %@", targetDateStart).first
     
     DispatchQueue.main.async {
     self.legacyCount = specificData?.stoolsCount ?? 0
     }
     }
     */
}

// --- DatePickerを別Viewに分離 (推奨) ---
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView { // タイトルと完了ボタンのため
            VStack {
                DatePicker("日付選択", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                    .labelsHidden()
                    .padding()
                
                Spacer()
            }
            .navigationTitle("日付を選択")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完了") {
                dismiss()
            })
        }
    }
}

// --- DateData モデル (StoolsCountViewを使う場合に必要) ---
/*
 class DateData: Object, ObjectKeyIdentifiable {
 @Persisted(primaryKey: true) var date: Date = Calendar.current.startOfDay(for: Date()) // 主キーは日付の開始時刻
 @Persisted var stoolsCount: Int = 0
 }
 
 struct StoolsCountView: View {
 var displayCount: Int
 var plusButton: () -> Void
 var minusButton: () -> Void
 // ... (実装は前の回答と同じ) ...
 var body: some View {
 HStack { /* ... Button, Text, Button ... */ }
 }
 }
 */
#Preview {
    ToDayView()
}

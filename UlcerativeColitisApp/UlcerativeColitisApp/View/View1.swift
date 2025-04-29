//
//  View1.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

struct View1: View {
    
    @State private var date = Date()
    @State private var showDatePicker = false
    @State private var count: Int = 0
//    @ObservedResults(DateData.self) var dateDataList
    @ObservedResults(DateData.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var dateDataList // 必要に応じてソート
    
//    var filteredData: [DateData] {
//        // 選択した日付でフィルタリング
//        dateDataList.filter { isSameDay($0.date, date) }
//    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(formatDate(date))")
                    .padding(.horizontal)
                    .font(.system(size: 30, weight: .bold))
                    .onTapGesture {
                        showDatePicker = true
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            DatePicker("日付選択", selection: $date, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                                .labelsHidden()
                            Button("完了") {
                                showDatePicker = false
                            }
                        }
                        .presentationDetents([.medium])
                    }
                Spacer()
            }
//            View3(plusButton: {
//                count += 1
//                saveData(count: count)
//            },
//                  minusButton: {
//                count -= 1
//                saveData(count: count)
//            }
//            )
//            .onAppear {
//                loadCountForSelectedDate()
//            }
            View3( // View3の仮名
                displayCount: count, // 現在のカウントを渡す
                plusButton: {
                    let newCount = count + 1
                    // ★ 保存処理とUI状態更新を両方行う
                    saveData(count: newCount)
                    count = newCount // UIの状態を即時更新
                },
                minusButton: {
                    if count > 0 { // 0未満にならないように
                        let newCount = count - 1
                        // ★ 保存処理とUI状態更新を両方行う
                        saveData(count: newCount)
                        count = newCount // UIの状態を即時更新
                    }
                }
            )
            .onAppear {
                print("View1 appeared. Loading initial count for date: \(formatDate(date))")
                loadCountForSelectedDate(for: date)
            }
            // ★★★ date の値が変更されたら、カウントを再読み込みする ★★★
            .onChange(of: date) { newDate in
                print("Date changed to: \(formatDate(newDate))")
                loadCountForSelectedDate(for: newDate)
            }
            // ★ (オプション) Realmのデータリスト自体が変更されたときにも再読み込みを試みる
            //   (例: バックグラウンド同期など)
            .onChange(of: dateDataList.count) { _ in // もっと厳密にはリストの内容変更を監視したい
                print("dateDataList potentially changed. Reloading count for current date: \(formatDate(date))")
                // 現在選択中の日付に対するカウントを再読み込み
                loadCountForSelectedDate(for: date)
            }
            
//            List {
//                ForEach(filteredData) { data in
//                    VStack(alignment: .leading) {
//                        Text("日付: \(formatDate(data.date))")
//                        Text("メモ: \(data.note)")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .onDelete(perform: deleteData)
//            }
            Spacer()
        }
    }
//    private func saveData() {
//        
//        let newData = DateData()
//        newData.date = date
//        
//        let realm = try! Realm()
//        try! realm.write {
//            realm.add(newData, update: .modified)
//        }
//    }
    // データを保存する
//    private func saveData(count: Int) {
//        let realm = try! Realm()
//        
//        // フィルタリングされたデータが存在する場合は更新、なければ新規作成
//        if let existingData = filteredData.first {
//            // 凍結状態のオブジェクトを解凍
//            if let thawedData = existingData.thaw() {
//                try! realm.write {
//                    thawedData.stoolsCount = count // カウントを更新
//                }
//            }
//        } else {
//            let newData = DateData()
//            newData.date = date
//            newData.stoolsCount = count // カウントを設定
//            try! realm.write {
//                realm.add(newData, update: .modified)
//            }
//        }
//    }
//    private func loadCountForSelectedDate() {
//        if let existingData = dateDataList.first(where: { isSameDay($0.date, date) }) {
//            count = existingData.stoolsCount
//        } else {
//            count = 0 // 該当データがない場合は0にリセット
//        }
//    }
    private func saveData(count newCount: Int) {
        // 日付の時刻部分をクリア (年月日のみで比較・保存するため)
        let targetDateStart = Calendar.current.startOfDay(for: date)
        print("Attempting to save: Date=\(formatDate(targetDateStart)), Count=\(newCount)")
        
        let realm = try! Realm()
        
        // 選択された日付に一致する既存データを検索 (時刻部分を無視して比較)
        // @ObservedResults は凍結されているため、直接フィルタリングする
        let existingData = realm.objects(DateData.self).filter { Calendar.current.isDate($0.date, inSameDayAs: targetDateStart) }.first
        
        if let dataToUpdate = existingData {
            // 既存データが見つかった場合 -> 更新
            print("Found existing data (ID: \(dataToUpdate.id)). Updating count.")
            // thawedData を使わずに直接 realm.write 内で更新できる
            try! realm.write {
                // 再度オブジェクトを取得し直すか、そのまま更新を試みる
                // let freshData = realm.object(ofType: DateData.self, forPrimaryKey: dataToUpdate.id)
                // freshData?.stoolsCount = newCount
                if !dataToUpdate.isInvalidated { // オブジェクトが無効でないか確認
                    dataToUpdate.stoolsCount = newCount
                    print("Update successful. New count: \(dataToUpdate.stoolsCount)")
                } else {
                    print("Error: Object to update is invalidated.")
                }
            }
        } else {
            // 既存データが見つからない場合 -> 新規作成
            print("No existing data found for this date. Creating new data.")
            let newData = DateData()
            newData.date = targetDateStart // 時刻がクリアされた日付を保存
            newData.stoolsCount = newCount
            try! realm.write {
                realm.add(newData)
            }
            print("New data created successfully.")
        }
    }
    
    // 選択された日付に対応するカウントを読み込む
    private func loadCountForSelectedDate(for targetDate: Date) {
        // 日付の時刻部分をクリアして比較
        let targetDateStart = Calendar.current.startOfDay(for: targetDate)
        print("Loading count for date: \(formatDate(targetDateStart))")
        
        // @ObservedResults (dateDataList) は最新とは限らないため、直接Realmから検索
        let realm = try! Realm()
        let specificData = realm.objects(DateData.self).filter { Calendar.current.isDate($0.date, inSameDayAs: targetDateStart) }.first
        
        // 検索結果をログ出力
        if let data = specificData {
            print("Found data in Realm: Date=\(formatDate(data.date)), Count=\(data.stoolsCount)")
            // ★ UI状態(@State)の更新はメインスレッドで行う
            DispatchQueue.main.async {
                self.count = data.stoolsCount
                print("Loaded count into UI state: \(self.count)")
            }
        } else {
            print("No data found in Realm for \(formatDate(targetDateStart)). Resetting count to 0.")
            // ★ データがない場合もメインスレッドでUI状態を更新
            DispatchQueue.main.async {
                self.count = 0
                print("Loaded count into UI state: \(self.count)")
            }
        }
    }

//    
//    private func deleteData(at offsets: IndexSet) {
//        offsets.forEach { index in
//            let itemToDelete = dateDataList[index]
//            let realm = try! Realm()
//            try! realm.write {
//                realm.delete(itemToDelete)
//            }
//        }
//    }
    
    // 日付をフォーマットする
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

#Preview {
    View1()
}

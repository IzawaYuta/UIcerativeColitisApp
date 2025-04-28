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
    @State private var note = "" // メモの入力
    @ObservedResults(DateData.self) var dateDataList
    
    var filteredData: [DateData] {
        // 選択した日付でフィルタリング
        dateDataList.filter { isSameDay($0.date, date) }
    }
    
    var body: some View {
        VStack {
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ja_JP"))
            
            TextField("メモを入力", text: $note)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // 保存ボタン
            Button(action: saveData) {
                Text("データを保存")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            List {
                ForEach(filteredData) { data in
                    VStack(alignment: .leading) {
                        Text("日付: \(formatDate(data.date))")
                        Text("メモ: \(data.note)")
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteData)
            }
        }
    }
    
    // データを保存する
    private func saveData() {
        guard !note.isEmpty else { return }
        
        let newData = DateData()
        newData.date = date
        newData.note = note
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(newData, update: .modified)
        }
        //            print("保存成功: 日付 - \(formatDate(newData.date)), メモ - \(newData.note)")
        note = ""
    }
    
    private func deleteData(at offsets: IndexSet) {
        offsets.forEach { index in
            let itemToDelete = dateDataList[index]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(itemToDelete)
            }
        }
    }
    
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

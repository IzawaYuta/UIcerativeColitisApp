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
    
    var body: some View {
        VStack(spacing: 40) {
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
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.secondary)
                HStack {
                    Button("追加") {
                        showStoolsRecordView = true
                    }
                    .sheet(isPresented: $showStoolsRecordView, onDismiss: { showStoolsRecordView = false }) {
                            StoolsRecordView()
                            .presentationDetents([.height(300)])
                        }
                    StoolsCountView(
                        displayCount: count,
                        plusButton: {
                            let newCount = count + 1
                            saveData(count: newCount)
                            self.count = newCount
                        },
                        minusButton: {
                            if count > 0 {
                                let newCount = count - 1
                                saveData(count: newCount)
                                self.count = newCount
                            }
                        }
                    )
                    .onAppear {
                        loadCountForSelectedDate(for: date)
                    }
                    .onChange(of: date) { newDate in
                        loadCountForSelectedDate(for: newDate)
                    }
                    .onChange(of: dateDataList.count) {
                        loadCountForSelectedDate(for: date)
                    }
                }
            }
            .frame(width: 400, height: 40)
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
        let targetDateStart = Calendar.current.startOfDay(for: date)
        
        let realm = try! Realm()
        
        let existingData = realm.objects(DateData.self).filter { Calendar.current.isDate($0.date, inSameDayAs: targetDateStart) }.first
        
        if let dataToUpdate = existingData {
            try! realm.write {
                if !dataToUpdate.isInvalidated {
                    dataToUpdate.stoolsCount = newCount
                } else {
                    print("Error: Object to update is invalidated.")
                }
            }
        } else {
            let newData = DateData()
            newData.date = targetDateStart
            newData.stoolsCount = newCount
            try! realm.write {
                realm.add(newData)
            }
        }
    }
    
    private func loadCountForSelectedDate(for targetDate: Date) {
        let targetDateStart = Calendar.current.startOfDay(for: targetDate)
        
        let realm = try! Realm()
        let specificData = realm.objects(DateData.self).filter { Calendar.current.isDate($0.date, inSameDayAs: targetDateStart) }.first
        
        if let data = specificData {
            DispatchQueue.main.async {
                self.count = data.stoolsCount
            }
        } else {
            DispatchQueue.main.async {
                self.count = 0
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
    ToDayView()
}

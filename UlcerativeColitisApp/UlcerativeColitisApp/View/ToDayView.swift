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
    @State private var showMedicineInfo = false
    @State private var showMedicineList = false
    //    @State private var count: Int = 0
    @State private var showStoolsRecordView = false
    @State private var newMemoTextEditor: String = ""
//    @Binding var selectedDate: Date
    @State private var showMedicineListView = false
    @State private var selectedItems: Set<ObjectId> = [] // 選択された項目のIDを保持
    //    @ObservedResults(DateData.self) var dateDataList
    //    @ObservedResults(DateData.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var dateDataList
    @ObservedResults(
        StoolRecordModel.self,
        sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
    ) var allStoolRecords
    @ObservedResults(MemoModel.self) var memoModel
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @ObservedResults(TakingMedicineModel.self) var takingMedicineModel
    
    let stoolTypesInfo = [
        (id: 1, label: "硬便", image: "1"),
        (id: 2, label: "普通便", image: "2"),
        (id: 3, label: "軟便", image: "3"),
        (id: 4, label: "下痢", image: "4"),
        (id: 5, label: "便秘", image: "5"),
        (id: 6, label: "血便", image: "6")
    ]
    
    var filteredMemos: [MemoModel] {
        memoModel.filter { isSameDay($0.date, date) }
    }
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 30) {
                HStack {
                    Text(formattedDate)
                        .padding(.horizontal)
                        .font(.system(size: 28, weight: .bold))
                        .onTapGesture { showDatePicker = true }
                        .sheet(isPresented: $showDatePicker) {
                            DatePickerSheet(selectedDate: $date)
                                .presentationDetents([.height(450)])
                        }
                    Spacer()
                }
                //            .padding(.top)
                .onChange(of: date) { _ in // 日付が変更されたらメモをロード
                    loadMemoForSelectedDate()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            showStoolsRecordView = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .font(.system(size: 15))
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .sheet(isPresented: $showStoolsRecordView) {
                            StoolsRecordView(selectedDate: date)
                                .presentationDetents([.medium, .large])
                        }
                        //                        Divider().frame(height: 10)
                        VStack {
                            
                            Text("\(stoolRecordCountForSelectedDate)")
                                .font(.title.weight(.bold))
                                .foregroundColor(.primary)
                            //                            .id("total_\(date)")
                            Text("排便回数")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(minWidth: 60, alignment: .center)
                        
                        Divider().frame(height: 40)
                        
                        HStack(spacing: 8) {
                            let counts = stoolTypeCountsForSelectedDate
                            
                            ForEach(stoolTypesInfo, id: \.id) { typeInfo in
                                let count = counts[typeInfo.id] ?? 0
                                VStack(spacing: 3) {
                                    Image(typeInfo.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .opacity(count > 0 ? 1.0 : 0.3)
                                    
                                    Text("\(count)")
                                        .font(.footnote.weight(count > 0 ? .semibold : .regular))
                                        .foregroundColor(count > 0 ? .primary : .secondary)
                                }
                                .frame(minWidth: 30)
                            }
                        }
                        .id("types_\(date)")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .frame(height: 85)
                .padding(.horizontal)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                    
                    HStack {
                        Button(action: {
                            showMedicineInfo.toggle()
                        }) {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $showMedicineInfo) {
                            MedicineInfoView()
                        }
                        Button(action: {
                            showMedicineList.toggle()
                        }) {
                            Image(systemName: "arrow.up")
                        }
                        .sheet(isPresented: $showMedicineList) {
                            MedicineListView()
                        }
                    }
                }
                .frame(height: 85)
                .padding(.horizontal)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                    
                    Button(action: {
                        showMedicineListView.toggle()
                    }) {
                        Text("服用追加")
                    }
                    .sheet(isPresented: $showMedicineListView) {
                        medicineView()
                    }
                }
                .frame(height: 85)
                .padding(.horizontal)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.1))
                    
                    List {
                        ForEach(takingMedicineModel.filter { isSameDay($0.takingDate, date) }, id: \ .id) { list in
                            Text(list.medicine.map { $0.medicineName }.joined(separator: ", "))
                        }
                    }
                }
                //                .frame(height: 85)
                .padding(.horizontal)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $newMemoTextEditor)
                        .padding()
                        .frame(height: 100)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .padding(.horizontal, 20)
                        .onSubmit {
                            saveMemo()
                        }
                    
                    if newMemoTextEditor.isEmpty {
                        Text("メモ")
                            .foregroundColor(Color(.placeholderText))
                            .padding(.vertical, 22)
                            .padding(.horizontal, 40)
                    }
                }
                Spacer()
            }
        }
        .background(
            //            LinearGradient(gradient: Gradient(colors: [.green.opacity(0.3), .cyan.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            RadialGradient(colors: [.cyan.opacity(0.7), .white], center: .top, startRadius: 1, endRadius: 500)
                .ignoresSafeArea()
        )
        .onAppear { // ビューが最初に表示されたときにメモをロード
            loadMemoForSelectedDate()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func calculateStoolCounts() -> (total: Int, typeCounts: [Int: Int]) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return (total: 0, typeCounts: [:])
        }
        let realm = try! Realm()
        
        let records = realm.objects(StoolRecordModel.self)
            .filter("date >= %@ AND date < %@", startOfDay as NSDate, startOfNextDay as NSDate)
        
        var counts: [Int: Int] = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0]
        for record in records {
            for typeId in record.stoolTypes {
                if counts.keys.contains(typeId) {
                    counts[typeId]? += 1
                }
            }
        }
        return (total: records.count, typeCounts: counts)
    }
    
    private var recordsForSelectedDate: Results<StoolRecordModel> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        // 次の日の開始時刻を計算 (その日の終わりとするため < endOfDay で比較)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            // エラーケース: 空のResultsを返す (実際にはこのエラーは発生しにくい)
            // NSPredicate(value: false) を使うことで空のResultsを意図的に作る
            return allStoolRecords.filter(NSPredicate(value: false))
        }
        
        // Realmのwhere句を使ってフィルタリング
        return allStoolRecords.where {
            $0.date >= startOfDay && $0.date < endOfDay
        }
    }
    
    private var stoolRecordCountForSelectedDate: Int {
        if let recordForDay = recordsForSelectedDate.first {
            return recordForDay.times
        } else {
            return 0
        }
    }
    
    private var stoolTypeCountsForSelectedDate: [Int: Int] {
        var counts: [Int: Int] = Dictionary(uniqueKeysWithValues: stoolTypesInfo.map { ($0.id, 0) }) // 初期化
        for record in recordsForSelectedDate {
            for typeId in record.stoolTypes {
                if counts.keys.contains(typeId) {
                    counts[typeId]? += 1
                }
            }
        }
        return counts
    }
    
    func saveMemo() {
        // Realmに保存
        let realm = try! Realm()
        let thaw = memoModel.thaw()
        if let existingRecord = thaw?.filter({ isSameDay($0.date, date) }).first {
            // 既存データを更新
            try! realm.write {
                existingRecord.memo = newMemoTextEditor
            }
        } else {
            // 新規データを追加
            let newRecord = MemoModel()
            newRecord.date = date
            newRecord.memo = newMemoTextEditor
            
            try! realm.write {
                realm.add(newRecord)
            }
        }
    }
    
    func loadMemoForSelectedDate() {
        // selectedDate と同じ日付のメモを検索
        if let existingRecord = memoModel.filter({ isSameDay($0.date, date) }).first {
            // 既存のメモがあればTextFieldに表示
            newMemoTextEditor = existingRecord.memo
        } else {
            // なければTextFieldを空にする
            newMemoTextEditor = ""
        }
    }
    
    // 同じ日かどうかを判定
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func medicineView() -> some View {
        VStack {
            Button(action: {
                saveTakingMedicine()
                showMedicineListView = false
            }) {
                Image(systemName: "plus")
            }
            List {
                ForEach(medicineDataModel.filter{ !$0.medicineName.isEmpty }, id: \ .id) { list in
                    HStack {
                        Image(systemName: selectedItems.contains(list.id) ? "checkmark.circle.fill" : "circle")
                        Text(list.medicineName)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity) // HStackをリストの幅全体に広げる
                    .contentShape(Rectangle()) // タップ可能な領域を拡張
                    .onTapGesture {
                        toggleSelection(for: list.id)
                    }
                }
            }
        }
    }
    
    // 選択状態を切り替える
    private func toggleSelection(for id: ObjectId) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    func saveTakingMedicine() {
        let realm = try! Realm()
        let selectedMedicines = realm.objects(MedicineDataModel.self).filter("id IN %@", selectedItems)
        try! realm.write {
            let model = TakingMedicineModel()
            model.takingDate = date // selectedDateの日付で保存
            model.medicine.append(objectsIn: selectedMedicines)
            realm.add(model)
        }
        selectedItems = []
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
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
 */
#Preview {
    ToDayView()
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

//    private var stoolRecordCountForSelectedDate: Int {
//        calculateStoolCounts().total
//    }
//
//    // 選択日の各便タイプ別回数
//    private var stoolTypeCountsForSelectedDate: [Int: Int] {
//        calculateStoolCounts().typeCounts
//    }

//    private var stoolRecordCountForSelectedDate: Int {
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
//            return 0
//        }
//        let realm = try! Realm()
//        // 選択された日付の範囲でフィルタリングしてカウント
//        return realm.objects(StoolRecordModel.self)
//            .filter("date >= %@ AND date < %@", startOfDay as NSDate, startOfNextDay as NSDate)
//            .count
//    }

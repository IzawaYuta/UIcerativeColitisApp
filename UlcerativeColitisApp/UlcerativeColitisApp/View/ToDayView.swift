//
//  ToDayView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

enum DayPicker: String, CaseIterable {
    case morning = "朝"
    case noon = "昼"
    case night = "夜"
}

enum ColorSelection: String, CaseIterable {
    case blue = "blue"
    case red = "red"
    case pink = "pink"
    
    var backColor: Color {
        switch self {
        case .blue:
            return Color.blueBack
        case .red:
            return Color.redBack
        case .pink:
            return Color.pinkBack
        }
    }
    
    var flontColor: Color {
        switch self {
        case .blue:
            return Color.blueFlont
        case .red:
            return Color.redFlont
        case .pink:
            return Color.pinkFlont
        }
    }
}

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
    @State private var showMorningTakingMedicineListView = false
    @State private var showNoonTakingMedicineListView = false
    @State private var showNightTakingMedicineListView = false
    @State private var showMemo = false
    @State private var daySelectPicker: DayPicker = .morning
    @State private var colorSelection: ColorSelection = .blue
    @State private var selectedItems: Set<ObjectId> = [] // 選択された項目のIDを保持
    @State private var selectedGroupItems: Set<ObjectId> = [] // 選択された項目のIDを保持
    //    @ObservedResults(DateData.self) var dateDataList
    //    @ObservedResults(DateData.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var dateDataList
    @ObservedResults(
        StoolRecordModel.self,
        sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
    ) var allStoolRecords
    @ObservedResults(MemoModel.self) var memoModel
    @ObservedResults(MedicineDataModel.self) var medicineDataModel
    @ObservedResults(TakingMedicineModel.self) var takingMedicineModel
    @ObservedResults(UsualMedicineModel.self) var usualMedicineModel
    
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
//                Picker("", selection: $colorSelection) {
//                    ForEach(ColorSelection.allCases, id: \.self) { color in
//                        Text(color.rawValue)
//                    }
//                }
//                .pickerStyle(.segmented)
                HStack {
                    Text(formattedDate)
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .font(.system(size: 28, weight: .bold))
                        .onTapGesture { showDatePicker = true }
                        .sheet(isPresented: $showDatePicker) {
                            DatePickerSheet(selectedDate: $date)
                                .presentationDetents([.height(450)])
                        }
                    Spacer()
                    Button(action: {
                        showMemo.toggle()
                    }) {
                        Image(systemName: "book.pages")
                    }
                    .padding(.horizontal)
                    .sheet(isPresented: $showMemo) {
                        memoView()
                            .presentationDetents([.height(300)])
                    }
                }
                //            .padding(.top)
                .onChange(of: date) { _ in // 日付が変更されたらメモをロード
                    loadMemoForSelectedDate()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white)
                        .shadow(radius: 2, x: 5, y: 5)
                    
                    HStack/*(spacing: 10)*/ {
                        Button(action: {
                            showStoolsRecordView = true
                        }) {
                            Image(systemName: "plus")
                        }
                        .font(.system(size: 15))
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.75))
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
                                .foregroundColor(.black)
                        }
                        .frame(minWidth: 60, alignment: .center)
                        
                        Divider().frame(height: 40)
                            .background(.white)
                        
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
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white)
                        .shadow(radius: 2, x: 5, y: 5)

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
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.white)
                        .shadow(radius: 2, x: 5, y: 5)
                    
                    HStack {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.blue.opacity(0.75))
                                .frame(width: 100, height: 55)
                            Button(action: {
                                showMedicineListView.toggle()
                            }) {
                                Text("服用追加")
                                    .foregroundColor(.white)
                                //                                .frame(width: 100, height: )
                                //                                .background(
                                //                                    Color.blue.opacity(0.75)
                                //                                        .clipShape(.capsule)
                                //                                )
                            }
                            .sheet(isPresented: $showMedicineListView) {
                                medicineView()
                            }
                        }
                        
                        Spacer()
                            .frame(width: 30)
                        
                        Text("朝")
                            .modifier(CustomView())
                            .onTapGesture {
                                showMorningTakingMedicineListView.toggle()
                            }
                            .sheet(isPresented: $showMorningTakingMedicineListView) {
                                morningTakingMedicineListView()
                            }
                        Text("昼")
                            .modifier(CustomView(backgroundColor: .init(red: 0.345, green: 0.888, blue: 0.692, alpha: 1)))
                            .onTapGesture {
                                showNoonTakingMedicineListView.toggle()
                            }
                            .sheet(isPresented: $showNoonTakingMedicineListView) {
                                noonTakingMedicineListView()
                            }
                        Text("夜")
                            .modifier(CustomView(backgroundColor: .init(red: 0.695, green: 0.486, blue: 0.888, alpha: 1)))
                            .onTapGesture {
                                showNightTakingMedicineListView.toggle()
                            }
                            .sheet(isPresented: $showNightTakingMedicineListView) {
                                nightTakingMedicineListView()
                            }
                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal)
                }
                .frame(height: 85)
                .padding(.horizontal)
                
//                ZStack {
//                    RoundedRectangle(cornerRadius: 15)
//                        .fill(Color.blue.opacity(0.1))
//                    List {
//                        ForEach(takingMedicineModel.filter {isSameDay($0.takingDate, date)}, id: \.id) { list in
//                            ForEach(list.medicine, id: \.id) { medicine in
//                                Text(medicine.medicineName)
//                            }
//                        }
//                    }
//                }
//                //                .frame(height: 85)
//                .padding(.horizontal)
                
                
                
//                if !filteredMemos.isEmpty {
//                    Text(filteredMemos.first?.memo ?? "")
//                }
                Spacer()
            }
        }
        .background(
//            colorSelection.backColor // colorSelection変数が持つプロパティを直接使用
            Color.colorBack
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
            Picker("", selection: $daySelectPicker) {
                ForEach(DayPicker.allCases, id: \.self) { picker in
                    Text(picker.rawValue)
                }
            }
            .pickerStyle(.segmented)
            HStack {
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
                List {
                    ForEach(usualMedicineModel, id: \.id) { usual in
                        HStack {
                            Image(systemName: selectedGroupItems.contains(usual.id) ? "checkmark.circle.fill" : "circle")
                            VStack(alignment: .leading) {
                                Text(usual.groupName)
                                Text(usual.medicines.map { $0.medicineName }.joined(separator: "\n"))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity) // HStackをリストの幅全体に広げる
                        .contentShape(Rectangle()) // タップ可能な領域を拡張
                        .onTapGesture {
                            toggleGroupSelection(for: usual.id)
                        }
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
    
    private func toggleGroupSelection(for id: ObjectId) {
        if selectedGroupItems.contains(id) {
            selectedGroupItems.remove(id)
        } else {
            selectedGroupItems.insert(id)
        }
    }
    
    func saveTakingMedicine() {
        let realm = try! Realm()
        let selectedMedicines = realm.objects(MedicineDataModel.self).filter("id IN %@", selectedItems)
        // 追加: selectedGroupItemsで選択されたUsualMedicineModelのmedicinesも取得
        let selectedGroups = realm.objects(UsualMedicineModel.self).filter("id IN %@", selectedGroupItems)
        var allMedicines = Array(selectedMedicines)
        for group in selectedGroups {
            allMedicines.append(contentsOf: group.medicines)
        }
        try! realm.write {
            let model = TakingMedicineModel()
            model.takingDate = date // selectedDateの日付で保存
            model.dayPicker = daySelectPicker.rawValue // DayPickerを保存
            model.medicine.append(objectsIn: allMedicines)
            realm.add(model)
        }
        selectedItems = []
        selectedGroupItems = []
    }
    
    private func deleteTakingMedicine(at offsets: IndexSet) {
        let items = takingMedicineModel.filter { isSameDay($0.takingDate, date) }
        let realm = try! Realm()
        try! realm.write {
            offsets.map { items[$0] }
                .compactMap { $0.thaw() }
                .filter { !$0.isInvalidated }
                .forEach { realm.delete($0) }
        }
    }
    
    func morningTakingMedicineListView() -> some View {
        List {
            ForEach(takingMedicineModel.filter {
                isSameDay($0.takingDate, date) && $0.dayPicker == DayPicker.morning.rawValue
            }, id: \.id) { list in
                ForEach(list.medicine, id: \.id) { medicine in
                    Text(medicine.medicineName)
                }
            }
        }
    }
    
    func noonTakingMedicineListView() -> some View {
        List {
            ForEach(takingMedicineModel.filter {
                isSameDay($0.takingDate, date) && $0.dayPicker == DayPicker.noon.rawValue
            }, id: \.id) { list in
                ForEach(list.medicine, id: \.id) { medicine in
                    Text(medicine.medicineName)
                }
            }
        }
    }
    
    func nightTakingMedicineListView() -> some View {
        let nightData = Array(takingMedicineModel.filter {
            isSameDay($0.takingDate, date) && $0.dayPicker == DayPicker.night.rawValue
        })
        
        return List {
            if nightData.isEmpty {
                Text("No Data")
            } else {
                ForEach(nightData, id: \.id) { list in
                    ForEach(list.medicine, id: \.id) { medicine in
                        Text(medicine.medicineName)
                    }
                }
            }
        }
    }
    
    func memoView() -> some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("メモ")
                Button(action: {
                    saveMemo()
                }) {
                    Image(systemName: "plus")
                }
                TextEditor(text: $newMemoTextEditor)
//                    .padding()
                    .frame(height: 200)
                //                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
                    .font(.system(size: 16, weight: .regular, design: .default))
//                    .padding(.horizontal, 20)
//                    .onSubmit {
//                        saveMemo()
//                    }
                
                //            if newMemoTextEditor.isEmpty {
                //                Text("メモ")
                //                    .foregroundColor(Color(.placeholderText))
                //                    .padding(.vertical, 22)
                //                    .padding(.horizontal, 40)
                //            }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.gray.gradient
        )
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

struct CustomView: ViewModifier {
    
    var backgroundColor: CGColor = .init(red: 1, green: 0.797, blue: 0.464, alpha: 1)
    
    func body(content: Content) -> some View {
        content
//            .font(.custom("Kei_Ji", size: 30))
            .font(.system(size: 30))
            .foregroundColor(.black.opacity(0.7))
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(Color(backgroundColor))
            )
//            .padding(.horizontal)
//            .padding(.vertical)
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


//                    List {
//                        ForEach(takingMedicineModel.filter { isSameDay($0.takingDate, date) }, id: \ .id) { list in
//                            Text(list.medicine.map { $0.medicineName }.joined(separator: "\n"))
//                        }
//                        .onDelete(perform: deleteTakingMedicine)
//                    }
//                    List {
//                        ForEach(takingMedicineModel.filter { isSameDay($0.takingDate, date) }, id: \ .id) { list in
//                            Text(list.medicine.map { $0.medicineName }.joined(separator: "\n"))
//                        }
//                    }

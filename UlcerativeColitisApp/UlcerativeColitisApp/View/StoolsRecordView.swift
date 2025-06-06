//
//  StoolsRecordView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI
import RealmSwift

struct StoolsRecordView: View {
    
    @State private var selectedStoolTypes: Set<Int> = []
    @State private var date = Date()
    @State private var recordTime = Date()
    @State private var showRecordList = false
    
    @ObservedResults(StoolRecordModel.self) var stoolRecordModel
    @Environment(\.dismiss) var dismiss
    
    let selectedDate: Date
    
    let stoolTypes = [
        (id: 1, label: "硬便", image: "1"),
        (id: 2, label: "普通便", image: "2"),
        (id: 3, label: "軟便", image: "3"),
        (id: 4, label: "下痢", image: "4"),
        (id: 5, label: "便秘", image: "5"),
        (id: 6, label: "血便", image: "6")
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 22) {
                ForEach(stoolTypes, id: \.id) { type in
                    VStack(spacing: 8) {
                        Image(type.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .background(Circle().fill(Color.white).frame(width: 55, height: 55))
                            .overlay(
                                Circle()
                                    .stroke(selectedStoolTypes.contains(type.id) ? Color.cyan : Color.gray.opacity(0.5), lineWidth: 3)
                                    .frame(width: 55, height: 55)
                            )
                            .shadow(color: selectedStoolTypes.contains(type.id) ? Color.cyan.opacity(0.4) : Color.clear, radius: 8)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    if selectedStoolTypes.contains(type.id) {
                                        selectedStoolTypes.remove(type.id)
                                    } else {
                                        selectedStoolTypes.insert(type.id)
                                    }
                                }
                            }
                        Text(type.label)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack(spacing: 20) {
                Button {
                    showRecordList.toggle()
                } label: {
                    Label("履歴", systemImage: "list.bullet")
                }
                .sheet(isPresented: $showRecordList) {
                    StoolRecordListView(selectedDate: selectedDate)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    DatePicker("時間", selection: $recordTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .frame(maxWidth: 120)
                    Button("現在") {
                        recordTime = Date()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                Button {
                    saveStoolRecord()
//                    dismiss()
                } label: {
                    Text("追加")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedStoolTypes.isEmpty ? Color.gray : Color.green)
                        )
                }
                .disabled(selectedStoolTypes.isEmpty)
                
            }
            .padding(.horizontal)
            
             Button("全データリセット", role: .destructive) { resetAllStoolData() }
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            recordTime = Date()
        }
    }
    
    private func saveStoolRecord() {
        guard !selectedStoolTypes.isEmpty else {
            print("No stool types selected.")
            return
        }
        
        let realm = try! Realm()
        let calendar = Calendar.current
        
        // 1. 記録対象の日付の開始時刻を特定
        let startOfDayForSelectedDate = calendar.startOfDay(for: selectedDate)
        
        // 今回の記録時刻 (finalRecordDateTime) を準備
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: recordTime)
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second // 秒も記録する場合
        guard let finalRecordDateTime = calendar.date(from: combinedComponents) else {
            print("Error: Could not combine date and time for the record.")
            return
        }
        
        guard let endOfDayForSelectedDate = calendar.date(byAdding: .day, value: 1, to: startOfDayForSelectedDate) else {
            print("Error: Could not calculate end of day.")
            return
        }
        
        let existingRecordForDay = realm.objects(StoolRecordModel.self)
            .filter("date >= %@ AND date < %@",
                    startOfDayForSelectedDate as NSDate,
                    endOfDayForSelectedDate as NSDate)
            .first
        
        try! realm.write {
            if let recordToUpdate = existingRecordForDay {
                print("Updating existing record for \(formatDate(recordToUpdate.date))")
                recordToUpdate.stoolTimes.append(finalRecordDateTime)
                
                let sortedSelectedTypes = Array(selectedStoolTypes).sorted()
                recordToUpdate.stoolTypes.append(objectsIn: sortedSelectedTypes)
                recordToUpdate.times = recordToUpdate.stoolTimes.count
                
                print("Record updated. New times: \(recordToUpdate.times), Stool times count: \(recordToUpdate.stoolTimes.count)")
                
            } else {
                print("Creating new record for \(formatDate(startOfDayForSelectedDate))")
                let newRecord = StoolRecordModel()
                newRecord.date = startOfDayForSelectedDate
                newRecord.stoolTimes.append(finalRecordDateTime)
                
                let sortedSelectedTypes = Array(selectedStoolTypes).sorted()
                newRecord.stoolTypes.append(objectsIn: sortedSelectedTypes)
                
                newRecord.times = 1
                
                realm.add(newRecord)
                print("New record saved. Times: \(newRecord.times), Stool times count: \(newRecord.stoolTimes.count)")
            }
        }
        selectedStoolTypes = []
    }
    
    // 全データ削除 (必要に応じて)
    private func resetAllStoolData() {
        let realm = try! Realm()
        try! realm.write {
            let allRecords = realm.objects(StoolRecordModel.self)
            realm.delete(allRecords)
        }
        print("All StoolRecordModel data have been deleted.")
//        dismiss() // 削除後シートを閉じる
    }
    
    // 日付フォーマット (デバッグ用)
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// --- 履歴表示用View (StoolRecordListView) ---
// (前の回答の StoolRecordListView を参照してください。
// selectedDate を受け取り、その日付でフィルタリングする実装が必要です)
// 例:
struct StoolRecordListView: View {
    let selectedDate: Date
    @ObservedResults(
        StoolRecordModel.self,
        filter: NSPredicate(value: false), // 初期フィルタ（下で上書き）
        sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
    ) var recordsForDate
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            fatalError("Could not calculate start of next day.")
        }
        // Filter を動的に設定
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, startOfNextDay as NSDate)
        _recordsForDate = ObservedResults(
            StoolRecordModel.self,
            filter: predicate,
            sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
        )
    }
    
    let stoolTypes = [
        (id: 1, label: "硬便", image: "1"),
        (id: 2, label: "普通便", image: "2"),
        (id: 3, label: "軟便", image: "3"),
        (id: 4, label: "下痢", image: "4"),
        (id: 5, label: "便秘", image: "5"),
        (id: 6, label: "血便", image: "6")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(recordsForDate) { record in
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.black, lineWidth: 0.5)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 80)
                            HStack(spacing: -3) {
                                Text("\(record.times)")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(width: 45, alignment: .leading)
                                    .padding(.horizontal)
                                ForEach(stoolTypes, id: \.id) { types in
                                    VStack {
                                        Image(types.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                        Text(types.label)
                                            .font(.system(size: 10))
                                    }
                                    .padding(.horizontal, 6)
                                }
                                Text(record.date, style: .time)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .onDelete(perform: deleteRecord)
                }
                .padding()
            }
            .navigationTitle("\(formatDateOnly(selectedDate)) の記録")
            .navigationBarItems(trailing: EditButton())
        }
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        // 削除処理 (前の回答と同様)
        guard let realm = recordsForDate.realm else { return }
        try? realm.write {
            let objectsToDelete = offsets.map { recordsForDate[$0] }
            realm.delete(objectsToDelete)
        }
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short // "yyyy/MM/dd" 形式 (ロケール依存)
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

#Preview {
    StoolsRecordView(selectedDate: Date())
}
#Preview {
    StoolRecordListView(selectedDate: Date())
}

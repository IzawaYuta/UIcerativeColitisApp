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
            HStack(spacing: 15) {
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
                    dismiss()
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
            
            // データリセットボタン (必要なら)
            // Button("全データリセット", role: .destructive) { resetAllStoolData() }
            //    .padding(.top)
            
            Spacer()
        }
        .padding(.top, 20)
        .onAppear {
            recordTime = Date()
        }
    }
    
    // --- 関数 ---
    
    private func saveStoolRecord() {
        guard !selectedStoolTypes.isEmpty else { return }
        
        let realm = try! Realm()
        
        // ToDayViewから渡された日付(年月日)と、このViewで選択された時間(時分秒)を組み合わせる
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: recordTime)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second // 秒も保持する場合
        
        guard let finalRecordDateTime = calendar.date(from: combinedComponents) else {
            print("Error: Could not combine date and time.")
            return
        }
        
        // 新しいレコードを作成
        let newRecord = StoolRecordModel()
        newRecord.date = finalRecordDateTime // 組み合わせた日時を保存
        newRecord.stoolTypes.append(objectsIn: Array(selectedStoolTypes).sorted()) // タイプIDをソートして保存推奨
        // newRecord.stoolTimes は使わないので削除 or コメントアウト
        
        // Realmに保存
        try! realm.write {
            realm.add(newRecord)
        }
        
        print("Saved new stool record for \(formatDate(finalRecordDateTime)) with types: \(selectedStoolTypes)")
        // 保存後、選択状態をリセット (dismissでViewが閉じるので不要かも)
        // selectedStoolTypes = []
    }
    
    // 全データ削除 (必要に応じて)
    private func resetAllStoolData() {
        let realm = try! Realm()
        try! realm.write {
            let allRecords = realm.objects(StoolRecordModel.self)
            realm.delete(allRecords)
        }
        print("All StoolRecordModel data have been deleted.")
        dismiss() // 削除後シートを閉じる
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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordsForDate) { record in
                    HStack {
                        Text(record.date, style: .time) // 時間表示
                        Spacer()
                        Text(record.readableStoolTypes().joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteRecord)
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

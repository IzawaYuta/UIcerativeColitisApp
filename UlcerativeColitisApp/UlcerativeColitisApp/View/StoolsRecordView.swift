//
//  StoolsRecordView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/30.
//

import SwiftUI
import RealmSwift

struct StoolsRecordView: View {
    
    @State private var selectedStoolTypes: Set<Int> = [] // 複数選択可能にするためのSet
    @State private var date = Date()
    @State private var showRecordList = false
    
    @ObservedResults(StoolRecordModel.self) var stoolRecordModel
    
    let stoolTypes = [
        (id: 1, label: "硬便", image: "1"),
        (id: 2, label: "普通便", image: "2"),
        (id: 3, label: "軟便", image: "3"),
        (id: 4, label: "下痢", image: "4"),
        (id: 5, label: "便秘", image: "5"),
        (id: 6, label: "血便", image: "6")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            HStack(spacing: 20) {
                ForEach(stoolTypes, id: \.id) { type in
                    VStack(spacing: 10) {
                        Image(type.image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 60, height: 60)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedStoolTypes.contains(type.id) ? Color.cyan : Color.gray, lineWidth: 4)
                                    .frame(width: 60, height: 60)
                            )
                            .shadow(color: selectedStoolTypes.contains(type.id) ? Color.cyan.opacity(0.5) : Color.clear, radius: 10)

                            .onTapGesture {
                                withAnimation {
                                    if selectedStoolTypes.contains(type.id) {
                                        selectedStoolTypes.remove(type.id)
                                    } else {
                                        selectedStoolTypes.insert(type.id)
                                    }
                                }
                            }
                        Text(type.label)
                            .font(.system(size: 12))
                    }
                }
            }
            HStack {
                Button("履歴") {
                    showRecordList.toggle()
                }
                    .sheet(isPresented: $showRecordList) {
                        StoolRecordListView()
                    }
                VStack {
                    DatePicker("時間", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .onAppear {
                            date = Date()
                        }
                    Button(action: {
                        date = Date()
                    }) {
                        Text("現在")
                    }
                }
                Text("追加")
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.green)
                    )
                    .onTapGesture {
                        saveStool(date: date, stoolTypes: Array(selectedStoolTypes)) // 保存
                    }
                Button(action: {
                    resetStoolData() // データをリセット
                }, label: {
                    Text("データリセット")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                })
            }
        }
    }
    
    private func saveStool(date: Date, stoolTypes: [Int]) {
        let realm = try! Realm()
        
        // 現在のデータ数を取得して、次のtimesを計算
        let currentCount = realm.objects(StoolRecordModel.self).count
        let nextTimes = currentCount + 1
        
        // 新しいレコードを作成
        let newRecord = StoolRecordModel()
        newRecord.date = date
        newRecord.times = nextTimes // 保存されているデータ数に基づいて +1
        newRecord.stoolTimes.append(objectsIn: Array(repeating: date, count: stoolTypes.count))
        newRecord.stoolTypes.append(objectsIn: stoolTypes)
        
        // Realmに保存
        try! realm.write {
            realm.add(newRecord)
        }
        withAnimation {
            selectedStoolTypes = []
        }
//        print("Saved new record: \(newRecord)")
    }

    
    private func resetStoolData() {
        let realm = try! Realm()
        try! realm.write {
            let allRecords = realm.objects(StoolRecordModel.self)
            realm.delete(allRecords) // StoolRecordModelのすべてのデータを削除
        }
//        print("All records have been deleted.")
    }

    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct StoolRecordListView: View {
    
    @ObservedResults(StoolRecordModel.self) var stoolRecordModel
    
    var body: some View {
        List(stoolRecordModel) { list in
            HStack {
                Text(formatDate(list.date)) // 日付をフォーマットして表示
                Spacer()
                Text("\(list.stoolTypes)") // 回数の表示
                Text("\(list.times)")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    StoolsRecordView()
}
#Preview {
    StoolRecordListView()
}

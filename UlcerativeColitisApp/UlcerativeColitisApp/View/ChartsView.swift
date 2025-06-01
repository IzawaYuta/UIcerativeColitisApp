//
//  ChartsView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/10.
//

import SwiftUI
import RealmSwift
import Charts

struct ChartsView: View {
    
    @ObservedResults(
        StoolRecordModel.self,
        sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
    ) var stoolRecords
    
    @State private var selectedMonth: Date = Date() // 選択された月
    
    // 選択された月のデータをフィルタリング
    private var filteredRecords: [StoolRecordModel] {
        stoolRecords.filter {
            let recordDateComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
            let selectedDateComponents = Calendar.current.dateComponents([.year, .month], from: selectedMonth)
            return recordDateComponents.year == selectedDateComponents.year &&
            recordDateComponents.month == selectedDateComponents.month
        }
    }
    
    var body: some View {
        VStack {
            // 月選択用DatePicker
            DatePicker(
                "月を選択",
                selection: $selectedMonth,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            // チャート表示
            if filteredRecords.isEmpty {
                Text("選択された月のデータがありません")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .frame(height: 300)
            } else {
                Chart {
                    ForEach(filteredRecords) { record in
                        LineMark(
                            x: .value("日付", record.date, unit: .day),
                            y: .value("回数", record.times)
                        )
                        .foregroundStyle(Color.blue)
                        .annotation(position: .top) {
                            Text("\(record.times)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(preset: .automatic, position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic)
                }
                .frame(height: 300)
                .padding()
            }
        }
        .navigationTitle("排便記録チャート")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    ChartsView()
}

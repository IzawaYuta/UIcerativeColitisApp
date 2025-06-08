//
//  ChartsView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/10.
//

import SwiftUI
import UIKit
import RealmSwift
import Charts

enum SegmentPicker: String, CaseIterable {
    case year = "年"
    case month = "月"
}

struct ChartsView: View {
    
    @ObservedResults(
        StoolRecordModel.self,
        sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)
    ) var stoolRecords
    
    @State private var selectedMonth: Date = Date() // 選択された年月
    @State private var segmentPicker: SegmentPicker = .month
    @State private var pickerIsPresented = false
    @State private var yearSelection: Int = {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: currentDate)
    }()
    @State private var monthSelection: Int = {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.component(.month, from: currentDate)
    }()
    @State private var displayedDate: String = {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年"
        return formatter.string(from: currentDate)
    }()
    
    // 選択に応じたフィルタリング
    private var filteredRecords: [StoolRecordModel] {
        switch segmentPicker {
        case .year:
            return stoolRecords.filter {
                let recordYear = Calendar.current.component(.year, from: $0.date)
                return recordYear == yearSelection
            }
        case .month:
            return stoolRecords.filter {
                let recordYear = Calendar.current.component(.year, from: $0.date)
                let recordMonth = Calendar.current.component(.month, from: $0.date)
                return recordYear == yearSelection && recordMonth == monthSelection
            }
        }
    }
    
    // Pickerの選択値を反映する関数
    func updateDisplayedDate() {
        switch segmentPicker {
        case .year:
            displayedDate = "\(yearSelection)年"
        case .month:
            displayedDate = "\(yearSelection)年\(monthSelection)月"
        }
    }
    
    private var aggregatedStoolTypes: [(type: String, count: Int)] {
        var counts: [Int: Int] = [:]
        for record in filteredRecords {
            for typeCode in record.stoolTypes {
                counts[typeCode, default: 0] += 1
            }
        }
        return counts.sorted { $0.key < $1.key }.compactMap { (typeCode, count) in
            guard let typeName = StoolRecordModel.typeDescriptions[typeCode] else { return nil }
            return (type: typeName, count: count)
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // 年月の選択
                    Button(action: {
                        pickerIsPresented.toggle()
                    }) {
                        Text(displayedDate)
                            .font(.headline)
                    }
                    .sheet(isPresented: $pickerIsPresented) {
                        VStack {
                            if segmentPicker == .year {
                                CustomDatePicker(selectedYear: $yearSelection, selectedMonth: $monthSelection)
                            } else {
                                CustomDatePicker(selectedYear: $yearSelection, selectedMonth: $monthSelection)
                            }
                            Button("決定") {
                                updateDisplayedDate()
                                pickerIsPresented = false
                            }
                            .padding()
                            .foregroundColor(.blue)
                        }
                        .presentationDetents([.height(400)])
                    }
                    Spacer()
                    // SegmentPicker
                    Picker("範囲", selection: $segmentPicker) {
                        ForEach(SegmentPicker.allCases, id: \.self) { picker in
                            Text(picker.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                .padding(.horizontal, 30)
                
                // グラフ表示
                ZStack {
                    if filteredRecords.isEmpty {
                        Text("データがありません")
                            .foregroundColor(.gray)
                            .font(.headline)
                    } else {
                        VStack {
                            ZStack {
                                Chart {
                                    ForEach(filteredRecords) { record in
                                        BarMark(
                                            x: .value("日付", segmentPicker == .year ? Calendar.current.component(.month, from: record.date) : Calendar.current.component(.day, from: record.date)),
                                            y: .value("回数", record.times)
                                        )
                                        .foregroundStyle(Color.cyan)
                                        .annotation(position: .top) {
                                            if segmentPicker == .month {
                                                Text("\(Calendar.current.component(.day, from: record.date))")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            } else {
                                                Text("\(Calendar.current.component(.month, from: record.date))")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(preset: .automatic, position: .leading) { value in
                                        if let yValue = value.as(Int.self) {
                                            AxisValueLabel {
                                                Text("\(yValue) 回") // `回` を付けて説明を加える
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        AxisTick() // 目盛りを描画
                                        AxisGridLine() // グリッドラインを描画
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks(values: segmentPicker == .year ? Array(1...12) : Array(1...31)) { value in
                                        AxisValueLabel {
                                            if let day = value.as(Int.self) {
                                                Text("\(day)")
                                                    .font(.caption)
                                                    .foregroundColor(.clear)
                                                    .rotationEffect(.degrees(90)) // 縦書き
                                            }
                                        }
                                        //                            AxisGridLine()
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .frame(height: 300)
                            
                            ZStack {
                                Chart(aggregatedStoolTypes, id: \.type) { item in
                                    BarMark(
                                        x: .value("種類", item.type),
                                        y: .value("回数", item.count)
                                    )
                                    .foregroundStyle(by: .value("種類", item.type)) // 種類ごとに色分け
                                    .annotation(position: .top) {
                                        Text("\(item.count)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .frame(height: 300)
                        }
                    }
                }
                
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("排便記録チャート")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(gradient: Gradient(colors: [.green.opacity(0.3), .cyan.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .onChange(of: segmentPicker) { _ in
            updateDisplayedDate()
        }
    }
}

struct CustomDatePicker: UIViewRepresentable {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    
    let years: [Int] = Array(1900...2100)
    let months: [Int] = Array(repeating: Array(1...12), count: 100).flatMap { $0 }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = context.coordinator
        pickerView.dataSource = context.coordinator
        
        
        if let yearRow = years.firstIndex(of: selectedYear), let monthRow = months.firstIndex(of: selectedMonth) {
            
            pickerView.selectRow(yearRow, inComponent: 0, animated: false)
            
            // 初期位置を中央に設定することで、ループをシミュレート
            pickerView.selectRow(monthRow + 12 * 49, inComponent: 1, animated: false)
        }
        return pickerView
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.reloadAllComponents()
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: CustomDatePicker
        
        init(_ parent: CustomDatePicker) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if component == 0 {
                return parent.years.count
            } else {
                return parent.months.count
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if component == 0 {
                return "\(parent.years[row])年"
            } else {
                return "\(parent.months[row])月"
            }
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.selectedYear = parent.years[row]
            } else {
                parent.selectedMonth = parent.months[row]
            }
        }
    }
}

#Preview {
    ChartsView()
}

//                        Chart {
//                            ForEach(filteredRecords) { record in
//                                let dateValue = segmentPicker == .year
//                                ? Calendar.current.component(.month, from: record.date)
//                                : Calendar.current.component(.day, from: record.date)
//
//                                ForEach(record.stoolTypes, id: \.self) { type in
//                                    BarMark(
//                                        x: .value("日付", dateValue),
//                                        y: .value("種類", type)
//                                    )
//                                    .foregroundStyle(Color.red)
//                                    .annotation(position: .top) {
//                                        Text("種類: \(type)")
//                                            .font(.caption2)
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                            }
//                        }

//
//  UCCountView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/05/24.
//

import SwiftUI
import RealmSwift

struct UCCountView: View {
    
    @ObservedResults(StoolRecordModel.self) var stoolRecordModel
    @ObservedResults(UCCountModel.self) var ucCountModel
    
    @State private var date: Date = Date()
    @State private var daysDifference: Int?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: .black, radius: 10)
                .frame(width: 360, height: 800)
            
            VStack(spacing: 20) {
                HStack {
                    Text("潰瘍性大腸炎になって")
                        .foregroundColor(.gray)
                    Text("\(daysDifference ?? 0)")
                        .font(.system(size: 50, design: .rounded))
                        .baselineOffset(20)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.default, value: daysDifference)
                    Text("日")
                }
                .padding(.horizontal)
//                DatePicker("", selection: $date, displayedComponents: .date)
//                    .labelsHidden()
//                    .onChange(of: date) { newDate in
//                        calculateDaysDifference(from: newDate)
//                    }
                // 便の合計回数
                let times = stoolRecordModel.map{ $0.times}
                let totalTimes = times.reduce(0, +) // 配列の合計を計算
                HStack {
                    Text("過去の排便回数")
                    Spacer()
                        .frame(width: 50)
                    Text("\(totalTimes)")
                        .font(.system(size: 50, design: .rounded))
                        .baselineOffset(20)
                }
                // 現在の年の合計回数を計算
                let currentYear = Calendar.current.component(.year, from: Date())
                let currentMonth = Calendar.current.component(.month, from: Date())
                let currentWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())
                
                let currentYearTotal = stoolRecordModel
                    .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
                    .map { $0.times }
                    .reduce(0, +)
                
                let currentMonthTotal = stoolRecordModel
                    .filter {
                        let date = $0.date
                        return Calendar.current.component(.year, from: date) == currentYear &&
                        Calendar.current.component(.month, from: date) == currentMonth
                    }
                    .map { $0.times }
                    .reduce(0, +)
                
                let currentWeekTotal = stoolRecordModel
                    .filter { record in
                        if let weekInterval = currentWeek {
                            return weekInterval.contains(record.date)
                        }
                        return false
                    }
                    .map { $0.times }
                    .reduce(0, +)
                
                VStack(alignment: .trailing) {
                    Text("\(currentYear.formatted(.number.grouping(.never)))年の総便回数: \(currentYearTotal) 回")
                        .monospacedDigit()
                    Text("\(currentMonth.formatted(.number.grouping(.never)))月の総便回数: \(currentMonthTotal) 回")
                        .monospacedDigit()
                    Text("今週の総便回数: \(currentWeekTotal) 回")
                        .monospacedDigit()
                    ForEach(Array(stoolTypeCounts.keys).sorted(), id: \.self) { type in
                        HStack {
                            Text("種類 \(type):")
                                .monospacedDigit()
                            Text("\(stoolTypeCounts[type] ?? 0) 回")
                                .monospacedDigit()
                        }
                    }
                }
            }
        }
        .onAppear {
            
        }
    }
    
    private func calculateDaysDifference(from date: Date) {
        let calendar = Calendar.current
        let today = Date()
        
        if let difference = calendar.dateComponents([.day], from: date, to: today).day {
            daysDifference = difference + 1
        } else {
            daysDifference = nil
        }
    }
    
    func saveSelectedDate() {
        guard let daysDifference = daysDifference else {
            print("daysDifference is nil")
            return
        }
        
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .day, value: daysDifference, to: Date()) {
            let realm = try! Realm()
            try! realm.write {
                let model = UCCountModel()
                model.date = newDate // 変換後のDate型を設定
                realm.add(model)
            }
        } else {
            print("Failed to calculate date from daysDifference")
        }
    }
    
    var stoolTypeCounts: [Int: Int] {
        // 全ての便の種類を集計
        let allTypes = stoolRecordModel.flatMap { $0.stoolTypes }
        return allTypes.reduce(into: [:]) { counts, type in
            counts[type, default: 0] += 1
        }
    }

}

#Preview {
    UCCountView()
}

//
//  MonthView.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

struct MonthView: View {
    
    @ObservedResults(StoolRecordModel.self)  var stoolRecordModel
    
//    var filteredData: [StoolRecordModel] {
//        stoolRecordModel.filter { isSameDay($0.date, selectedDate ?? Date()) }
//    }
    
    @State private var currentDate: Date = Date()
    @State private var selectedDate: Date? = Date()
    @State private var displayedMonths: [Int] = [-1, 0, 1]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 20) {
            
            CalendarHeaderView(currentDate: $currentDate)
            WeekdayLabelsView()
            
            TabView(selection: $currentDate) {
                ForEach(displayedMonths, id: \.self) { monthOffset in
                    let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: startOfMonth(date: Date()))!
                    MonthDaysGridView(
                        monthDate: monthDate,
                        selectedDate: $selectedDate
                    )
                    .tag(monthDate)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentDate) { newDate in
                withAnimation {
                    // 前後の月にスライドしたらリストを更新
                    let currentMonthOffset = calendar.dateComponents([.month], from: startOfMonth(date: Date()), to: newDate).month ?? 0
                    displayedMonths = [currentMonthOffset - 1, currentMonthOffset, currentMonthOffset + 1]
                }
            }
            .frame(height: 200)
            
            Divider()
                .background(Color.red)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 45)
            //            ↑どちらか使う↓
            //            Rectangle()
            //                .fill(Color.red)
            //                .frame(maxWidth: .infinity)
            //                .frame(height: 0.5)
            //                .padding(.horizontal, 45)
            
            HStack(spacing: 50) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 150, height: 150)
                        .viewStyleView()
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                            Image("Image")
                                .resizable()
                        }
                        .frame(width: 40, height: 40)
                        .offset(x: -3, y: 32)
                        if let stoolsCount = stoolRecordModel.filter({ isSameDay($0.date, selectedDate ?? Date()) }).first?.times {
                            Text("\(stoolsCount)")
                                .font(.system(size: 70))
                                .bold()
                                .offset(x: -5, y: -35)
                        } else {
                            Text("0")
                                .font(.system(size: 70))
                                .bold()
                                .offset(x: -5, y: -35)
                        }
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.secondary)
                    .frame(width: 150, height: 150)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .onAppear {
            currentDate = startOfMonth(date: Date())
        }
    }
    
    private func startOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

// MARK: - Header View
struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        dateFormatter.dateFormat = "yyyy　MM"
        dateFormatter.locale = Locale(identifier: "ja_JP")
    }
    
    var body: some View {
        HStack {
            Text(currentDate, formatter: dateFormatter)
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Weekday Labels View
struct WeekdayLabelsView: View {
    private let weekdays: [String] = ["日", "月", "火", "水", "木", "金", "土"]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(weekdayColor(weekday))
                    .padding(.vertical, -10)
            }
        }
    }
    
    private func weekdayColor(_ weekday: String) -> Color {
        switch weekday {
        case "日": return .red.opacity(0.8)
        case "土": return .blue.opacity(0.8)
        default: return .primary
        }
    }
}

// MARK: - Month Days Grid View
struct MonthDaysGridView: View {
    let monthDate: Date
    @Binding var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    // この月の日付の配列
    private var days: [Date] {
        generateDaysInMonth(for: monthDate)
    }
    // 月の初日の曜日 (日曜日=1, ..., 土曜日=7)
    private var startingWeekday: Int {
        calendar.component(.weekday, from: startOfMonth())
    }
    // 月の初日の前に表示する空のスペースの数
    private var startingSpaces: Int {
        startingWeekday - 1 // weekdayは1始まりなので調整
    }
    
    // グリッドの列定義 (7列)
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: daysInWeek)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            // 1. 月の初日までの空スペース
            ForEach(0..<startingSpaces, id: \.self) { _ in
                Color.clear // 透明なViewでスペースを埋める
            }
            
            // 2. 月の日付
            ForEach(days, id: \.self) { date in
                DayCell(date: date, selectedDate: $selectedDate)
            }
        }
        .padding(.horizontal, 5) // グリッド全体の左右パディング
        // .id(monthDate) // Viewの識別子 (TabViewがこれを認識するために重要)
    }
    
    // MARK: - Helper Functions for Grid
    
    // 指定された月の最初の日を返す
    private func startOfMonth() -> Date {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        return calendar.date(from: components)!
    }
    
    // 指定された月の日付（Dateオブジェクト）の配列を生成する
    private func generateDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) // endは次の月なので1秒引く
        else {
            return []
        }
        
        // 月の全日数を取得
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return [] }
        
        // 月の最初の日を取得
        let firstOfMonth = startOfMonth()
        
        // 各日のDateオブジェクトを生成
        return range.compactMap { day -> Date? in
            var components = calendar.dateComponents([.year, .month], from: firstOfMonth)
            components.day = day
            return calendar.date(from: components)
        }
    }
}

// MARK: - Day Cell View
struct DayCell: View {
    let date: Date
    @Binding var selectedDate: Date?
    private let calendar = Calendar.current
    
    // このセルが選択されているかどうか
    private var isSelected: Bool {
        guard let selected = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selected)
    }
    
    // このセルが今日の日付かどうか
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    // 日付番号の文字列
    private var dayString: String {
        let day = calendar.component(.day, from: date)
        return String(day)
    }
    
    var body: some View {
        Button {
            if isSelected {
            } else {
                selectedDate = date
            }
        } label: {
            Text(dayString)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .font(.system(size: 17))
                .foregroundColor(textColor)
                .background(backgroundView)
                .clipShape(Circle())
                .background(
                    Circle()
                        .fill(isToday ? Color.gray : Color.clear)
                )
        }
    }
    
    // テキストの色を決定
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .white
        } else {
            return .primary
        }
    }
    
    // 背景を決定
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            Circle().fill(Color.red)
        } else {
            Color.clear
        }
    }
}
#Preview {
    MonthView()
}



//    private let dateFormatter = DateFormatter()

//            TextField("メモを入力", text: $note)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            // 保存ボタン
//            Button(action: saveData) {
//                Text("データを保存")
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(8)
//            }

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

// Dateを指定したフォーマットの文字列に変換するための静的フォーマッタ
//    static var itemFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "ja_JP") // 日本語表示
//        return formatter
//    }

//    private func saveData() {
//        guard !note.isEmpty else { return }
//
//        let newData = DateData()
//        newData.date = selectedDate ?? Date()
//        newData.note = note
//
//        let realm = try! Realm()
//        try! realm.write {
//            realm.add(newData, update: .modified)
//        }
//        //            print("保存成功: 日付 - \(formatDate(newData.date)), メモ - \(newData.note)")
//        note = ""
//    }
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

//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        return formatter.string(from: date)
//    }



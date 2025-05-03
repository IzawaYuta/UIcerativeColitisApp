//
//  View2.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI
import RealmSwift

struct View2: View {
    
    @ObservedResults(DateData.self) var dateDataList
    var filteredData: [DateData] {
        // 選択した日付でフィルタリング
        dateDataList.filter { isSameDay($0.date, selectedDate ?? Date()) }
    }
    
    // 現在表示している月 (初期値は現在日時)
    @State private var currentDate: Date = Date()
    // ユーザーが選択した日付 (最初は何も選択されていない)
    @State private var selectedDate: Date? = nil
    
    // カレンダー関連の処理で使用
    private let calendar = Calendar.current
    // 日付フォーマッター
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. ヘッダー (年月表示と月移動ボタン)
            CalendarHeaderView(currentDate: $currentDate)
            
            // 2. 曜日ラベル
            WeekdayLabelsView()
            
            // 3. 日付グリッド (TabViewで横スワイプを実現)
            TabView(selection: $currentDate) {
                // 前月、当月、次月を事前に描画してスムーズなスワイプを実現
                // (パフォーマンスのために、もっと多くの月を描画することも検討可能)
                ForEach([-1, 0, 1], id: \.self) { monthOffset in
                    let monthDate = calendar.date(byAdding: .month, value: monthOffset, to: startOfMonth(date: Date()))!
                    MonthDaysGridView(
                        monthDate: monthDate,
                        selectedDate: $selectedDate
                    )
                    // TabViewの各ページにタグを設定し、currentDateと連動させる
                    // .tag() には Date をそのまま使うのがシンプル
                    .tag(monthDate)
                }
            }
            // 横スクロール（ページング）スタイルにする
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // 高さを日付グリッドに合わせて調整 (環境によって調整が必要な場合あり)
            .frame(height: 200) // 高さは適宜調整してください
            
            
            HStack(spacing: 50) {
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                        .fill(Color.gray.secondary)
                        .frame(width: 150, height: 150)
                    HStack {
                        VStack(alignment: .trailing, spacing: -3) {
                            Text("ToDay")
                                .font(.system(size: 20))
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                Image("Image")
                                    .resizable()
                            }
                            .frame(width: 40, height: 40)
                        }
                        .offset(x: -3, y: 32)
                        if let stoolsCount = dateDataList.filter({ isSameDay($0.date, selectedDate ?? Date()) }).first?.stoolsCount {
                            Text("\(stoolsCount)") // stoolsCount を表示
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
            
            Spacer() // 上部に寄せる
        } // VStack
        .padding(.vertical, 4)
        // currentDateがプログラム的に変更されたときにTabViewも追従するようにする
        .onChange(of: currentDate) { newDate in
            // ここで明示的にTabViewの選択を更新する必要はないことが多い
            // TabViewのselectionが$currentDateにバインドされているため
            // 必要であれば、ここで追加のロジックを実行
            print("CurrentDate changed to: \(newDate)")
        }
        // 最初の月を設定するために onAppear を使う
        .onAppear {
            // TabViewの初期表示月を設定
            currentDate = startOfMonth(date: Date())
        }
    }
    
    // MARK: - Helper Functions
    
    // Dateを指定したフォーマットの文字列に変換するための静的フォーマッタ
    static var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP") // 日本語表示
        return formatter
    }
    
    // 指定された日付の月の最初の日を返す
    private func startOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
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

// MARK: - Header View
struct CalendarHeaderView: View {
    @Binding var currentDate: Date
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        dateFormatter.dateFormat = "yyyy　MM" // 年月表示フォーマット
        dateFormatter.locale = Locale(identifier: "ja_JP")
    }
    
    var body: some View {
        HStack {
            // 年月表示
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
    let monthDate: Date // このビューが表示する月の日付（月の初日でなくても良い）
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
        // -> TabViewの.tag()を使うのでここでは不要かも
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
            // 日付を選択/選択解除
            if isSelected {
                // selectedDate = nil // 再タップで選択解除する場合
            } else {
                selectedDate = date
            }
        } label: {
            Text(dayString)
                .frame(maxWidth: .infinity)
                .frame(height: 30) // セルの高さを固定
                .font(.system(size: 17)) // フォントサイズ調整
                .foregroundColor(textColor)
                .background(backgroundView)
                .clipShape(Circle()) // 円形にする
                .overlay(
                    // 今日の日付にだけ枠線をつける
                    Circle()
                        .stroke(isToday ? Color.blue : Color.clear, lineWidth: 1.5)
                )
        }
    }
    
    // テキストの色を決定
    private var textColor: Color {
        if isSelected {
            return .white // 選択されている場合は白
        } else if isToday {
            return .blue // 今日の日付は青 (選択されていなければ)
        } else {
            return .primary // 通常の日付
        }
    }
    
    // 背景を決定
    @ViewBuilder
    private var backgroundView: some View {
        if isSelected {
            Circle().fill(Color.red) // 選択されている場合は赤い円
        } else {
            Color.clear // 通常は透明
        }
    }
}
#Preview {
    View2()
}

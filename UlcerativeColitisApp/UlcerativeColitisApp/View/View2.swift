//
//  View2.swift
//  UlcerativeColitisApp
//
//  Created by Engineer MacBook Air on 2025/04/27.
//

import SwiftUI

struct CalendarDates: Identifiable {
    var id = UUID()
    var date: Date?
}

struct View2: View {
    
    // 年
    let year = Calendar.current.year(for: Date()) ?? 0
    // 月
    let month = Calendar.current.month(for: Date()) ?? 0
    // 日付配列
    let calendarDates = createCalendarDates(Date())
    // 曜日
    let weekdays = Calendar.current.shortWeekdaySymbols
    // グリッドアイテム
    let columns: [GridItem] = Array(repeating: .init(.fixed(40)), count: 7)
    
    var body: some View {
        VStack {
            // yyyy/MM
            Text(String(format: "%04d/%02d", year, month))
                .font(.system(size: 24))
            
            // 曜日
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday).frame(width: 40, height: 40, alignment: .center)
                }
            }
            
            // カレンダー
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(calendarDates) { calendarDates in
                    if let date = calendarDates.date, let day = Calendar.current.day(for: date) {
                        Text("\(day)")
                    } else {
                        Text("")
                    }
                }
            }
        }
        .frame(width: 400, height: 400, alignment: .center)
    }
}

extension Calendar {
    /// 今月の開始日を取得する
    /// - Parameter date: 対象日
    /// - Returns: 開始日
    func startOfMonth(for date:Date) -> Date? {
        let comps = dateComponents([.month, .year], from: date)
        return self.date(from: comps)
    }
    
    /// 今月の日数を取得する
    /// - Parameter date: 対象日
    /// - Returns: 日数
    func daysInMonth(for date:Date) -> Int? {
        return range(of: .day, in: .month, for: date)?.count
    }
    
    /// 今月の週数を取得する
    /// - Parameter date: 対象日
    /// - Returns: 週数
    func weeksInMonth(for date:Date) -> Int? {
        return range(of: .weekOfMonth, in: .month, for: date)?.count
    }
    
    func year(for date: Date) -> Int? {
        let comps = dateComponents([.year], from: date)
        return comps.year
    }
    
    func month(for date: Date) -> Int? {
        let comps = dateComponents([.month], from: date)
        return comps.month
    }
    
    func day(for date: Date) -> Int? {
        let comps = dateComponents([.day], from: date)
        return comps.day
    }
    
    func weekday(for date: Date) -> Int? {
        let comps = dateComponents([.weekday], from: date)
        return comps.weekday
    }
}

/// カレンダー表示用の日付配列を取得
/// - Parameter date: カレンダー表示の対象日
/// - Returns: 日付配列
func createCalendarDates(_ date: Date) -> [CalendarDates] {
    var days = [CalendarDates]()
    
    // 今月の開始日
    let startOfMonth = Calendar.current.startOfMonth(for: date)
    // 今月の日数
    let daysInMonth = Calendar.current.daysInMonth(for: date)
    
    guard let daysInMonth = daysInMonth, let startOfMonth = startOfMonth else { return [] }
    
    // 今月の全ての日付
    for day in 0..<daysInMonth {
        // 今月の開始日から1日ずつ加算
        days.append(CalendarDates(date: Calendar.current.date(byAdding: .day, value: day, to: startOfMonth)))
    }
    
    guard let firstDay = days.first, let lastDay = days.last,
          let firstDate = firstDay.date, let lastDate = lastDay.date,
          let firstDateWeekday = Calendar.current.weekday(for: firstDate),
          let lastDateWeekday = Calendar.current.weekday(for: lastDate) else { return [] }
    
    // 初週のオフセット日数
    let firstWeekEmptyDays = firstDateWeekday - 1
    // 最終週のオフセット日数
    let lastWeekEmptyDays = 7 - lastDateWeekday
    
    // 初週のオフセットを追加
    for _ in 0..<firstWeekEmptyDays {
        days.insert(CalendarDates(date: nil), at: 0)
    }
    
    // 最終週のオフセットを追加
    for _ in 0..<lastWeekEmptyDays {
        days.append(CalendarDates(date: nil))
    }
    
    return days
}

#Preview {
    View2()
}

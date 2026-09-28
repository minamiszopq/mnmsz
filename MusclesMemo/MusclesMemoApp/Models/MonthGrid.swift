import Foundation

/// カレンダー1ヶ月分のマス目（前後月の余白日を含む）を計算するユーティリティ。
enum MonthGrid {
    /// `month` を含む月について、週の先頭（日曜）からの6週間分（42日）の日付配列を返す。
    /// 表示対象月に属さない日付は前後の月の日付で埋められる。
    static func days(for month: Date, calendar: Calendar = .current) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let firstDay = firstWeekInterval.start
        return (0..<42).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: firstDay)
        }
    }

    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        calendar.shortWeekdaySymbols
    }
}

import Foundation

extension Date {
    /// その日の 0時0分に正規化した日付を返す。
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other)
            && calendar.component(.month, from: self) == calendar.component(.month, from: other)
    }
}

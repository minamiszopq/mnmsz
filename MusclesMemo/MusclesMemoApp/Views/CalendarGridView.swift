import SwiftUI

/// 月表示のカレンダーグリッド。今日をハイライトし、記録がある日にドットを表示する。
struct CalendarGridView: View {
    let displayedMonth: Date
    let recordedDays: Set<Date>
    let onSelectDate: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(Array(MonthGrid.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(MonthGrid.days(for: displayedMonth), id: \.self) { day in
                    DayCellView(
                        day: day,
                        isInDisplayedMonth: day.isSameMonth(as: displayedMonth),
                        isToday: day.isToday,
                        hasRecord: recordedDays.contains(day.startOfDay)
                    )
                    .onTapGesture {
                        onSelectDate(day.startOfDay)
                    }
                }
            }
        }
    }
}

private struct DayCellView: View {
    let day: Date
    let isInDisplayedMonth: Bool
    let isToday: Bool
    let hasRecord: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .frame(width: 32, height: 32)
                .background {
                    if isToday {
                        Circle().fill(AppTheme.accent)
                    }
                }
                .foregroundStyle(foregroundColor)

            Circle()
                .fill(AppTheme.accentTertiary)
                .frame(width: 5, height: 5)
                .opacity(hasRecord ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        if isToday { return .black }
        if !isInDisplayedMonth { return AppTheme.textSecondary.opacity(0.4) }
        return AppTheme.textPrimary
    }
}

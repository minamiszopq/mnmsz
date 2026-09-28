import SwiftUI

/// 「◀ 2026年9月 ▶」のような月切り替えヘッダー。
struct CalendarHeaderView: View {
    @Binding var displayedMonth: Date

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: displayedMonth)
    }

    var body: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(monthTitle)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .overlay(alignment: .trailing) {
            if !displayedMonth.isSameMonth(as: .now) {
                Button("今日") {
                    withAnimation(.snappy) {
                        displayedMonth = Date().startOfDay
                    }
                }
                .font(.subheadline)
                .padding(.trailing, 44)
            }
        }
    }

    private func changeMonth(by value: Int) {
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.snappy) {
            displayedMonth = newMonth
        }
    }
}

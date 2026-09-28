import SwiftUI
import SwiftData

/// カレンダーから別の日を選び、その日の全種目・全セットをそのまま対象日にコピーする画面。
struct CopyFromDayScreen: View {
    let targetDate: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutSet.date) private var allSets: [WorkoutSet]

    @State private var displayedMonth: Date
    @State private var dayPendingConfirmation: Date?

    init(targetDate: Date) {
        self.targetDate = targetDate
        _displayedMonth = State(initialValue: targetDate.startOfDay)
    }

    private var recordedDays: Set<Date> {
        Set(allSets.map { $0.date.startOfDay })
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("記録のある日をタップしてコピーします")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.top, 8)

                CalendarHeaderView(displayedMonth: $displayedMonth)
                    .padding(.horizontal)

                CalendarGridView(
                    displayedMonth: displayedMonth,
                    recordedDays: recordedDays,
                    onSelectDate: { date in
                        guard recordedDays.contains(date), date != targetDate.startOfDay else { return }
                        dayPendingConfirmation = date
                    }
                )
                .padding(.horizontal)

                Spacer()
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("別の日からコピー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .confirmationDialog(
                confirmationTitle,
                isPresented: Binding(
                    get: { dayPendingConfirmation != nil },
                    set: { if !$0 { dayPendingConfirmation = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("コピーする") {
                    if let source = dayPendingConfirmation {
                        WorkoutRepository.copyWorkout(from: source, to: targetDate, context: modelContext)
                    }
                    dismiss()
                }
                Button("キャンセル", role: .cancel) { dayPendingConfirmation = nil }
            }
        }
    }

    private var confirmationTitle: String {
        guard let day = dayPendingConfirmation else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return "\(formatter.string(from: day))の記録を\(formatter.string(from: targetDate))にコピーしますか？"
    }

}

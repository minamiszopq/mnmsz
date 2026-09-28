import SwiftUI
import SwiftData

/// アプリのルート画面。全面カレンダーと「今日のトレーニングを追加」ボタンを表示する。
struct CalendarScreen: View {
    @Query(sort: \WorkoutSet.date) private var allSets: [WorkoutSet]

    @State private var displayedMonth: Date = Date().startOfDay
    @State private var navigationPath: [Date] = []
    @State private var slideEdge: Edge = .trailing
    @GestureState private var dragOffset: CGFloat = 0

    private var recordedDays: Set<Date> {
        Set(allSets.map { $0.date.startOfDay })
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                CalendarHeaderView(displayedMonth: $displayedMonth)
                    .padding(.horizontal)
                    .padding(.top, 8)

                CalendarGridView(
                    displayedMonth: displayedMonth,
                    recordedDays: recordedDays,
                    onSelectDate: { date in
                        navigationPath.append(date)
                    }
                )
                .id(displayedMonth)
                .transition(.asymmetric(
                    insertion: .move(edge: slideEdge).combined(with: .opacity),
                    removal: .move(edge: slideEdge == .trailing ? .leading : .trailing).combined(with: .opacity)
                ))
                .offset(x: dragOffset * 0.25)
                .padding(.horizontal)
                .padding(.top, 12)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(swipeGesture)

                addTodayButton
                    .padding()
            }
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("筋トレメモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: Date.self) { date in
                DayDetailScreen(date: date)
            }
        }
    }

    /// 左右スワイプで前月・翌月に切り替えるジェスチャー。
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.width <= -threshold {
                    changeMonth(by: 1)
                } else if value.translation.width >= threshold {
                    changeMonth(by: -1)
                }
            }
    }

    private func changeMonth(by value: Int) {
        slideEdge = value > 0 ? .trailing : .leading
        guard let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.snappy) {
            displayedMonth = newMonth
        }
    }

    private var addTodayButton: some View {
        Button {
            navigationPath.append(Date().startOfDay)
        } label: {
            Label("今日のトレーニングを追加", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.black)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accent)
    }
}

#Preview {
    CalendarScreen()
        .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
        .preferredColorScheme(.dark)
}

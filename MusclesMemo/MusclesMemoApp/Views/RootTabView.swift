import SwiftUI

/// アプリのルート。カレンダーとグラフをタブで切り替える。
struct RootTabView: View {
    var body: some View {
        TabView {
            CalendarScreen()
                .tabItem { Label("カレンダー", systemImage: "calendar") }

            StatsScreen()
                .tabItem { Label("グラフ", systemImage: "chart.xyaxis.line") }
        }
        .tint(AppTheme.accent)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
        .preferredColorScheme(.dark)
}
